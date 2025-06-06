import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodbooks_flutter/config/supabase_config.dart';
import 'dart:io';

class User {
  final String name;
  final String email;
  final String phone;
  final String profileImageUrl;

  User({
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? 'John Doe',
      email: json['email'] ?? 'johndoe@example.com',
      phone: json['phone'] ?? '+6281234567890',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'profileImageUrl': profileImageUrl,
      };
}

class AuthProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoggedIn = false;
  bool _isAttemptingLogin = false;
  User? _user;

  String? _verificationId; 
  int? _resendToken;

  File? _coverImage; 

  String get supabaseUrl => SupabaseConfig.supabaseUrl;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAttemptingLogin => _isAttemptingLogin;
  User? get user => _user;

  Future<void> initialize() async {
    await checkLoginStatus();
    if (_isLoggedIn) {
      await loadUserData();
    }
  }

  // --- Login/Signup ---
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      final fb_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      _isLoggedIn = true;
      _user = User(
        name: userCredential.user?.displayName ?? 'User',
        email: userCredential.user?.email ?? email,
        phone: userCredential.user?.phoneNumber ?? '',
        profileImageUrl: userCredential.user?.photoURL ?? '',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _saveUserData();

      // Simpan ke Supabase
      await _syncUserToSupabase(userCredential.user!.uid);

      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah';
          break;
        default:
          errorMessage = 'Login gagal: ${e.message}';
      }
      throw Exception(errorMessage);
    } on TimeoutException {
      throw Exception('Timeout. Cek koneksi internet Anda');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  Future<void> bypassLogin() async {
    _isLoggedIn = true;
    _user = User(
      name: 'Test User',
      email: 'test@example.com',
      phone: '+6281234567890',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await _saveUserData();
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        _isLoggedIn = true;
        final userId = firebaseUser.uid;
        final url = '$supabaseUrl/users?id=eq.$userId';
        await prefs.setBool('isLoggedIn', true);
        await loadUserData();
      } else {
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        if (_isLoggedIn) {
          await logout(); // Force logout jika local menyimpan status tapi Firebase tidak
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      _isLoggedIn = false;
    } finally {
      notifyListeners();
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    String profileImageUrl = '',
  }) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      final fb_auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password);

      // Kirim email verifikasi
      await userCredential.user?.sendEmailVerification();

      // Simpan ke Supabase
      await _syncUserToSupabase(
        userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

      _isLoggedIn = true;
      _user = User(
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _saveUserData();

      return _user;
    } on fb_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email sudah terdaftar';
          break;
        case 'weak-password':
          errorMessage = 'Password terlalu lemah';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        default:
          errorMessage = 'Pendaftaran gagal: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  Future<User?> signUpWithPhone({
    required String phone,
    required String name,
    String email = '',
    String password = '',
  }) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      await sendOTP(phone);

      String tempDocId = 'temp_' + phone.replaceAll('+', '').replaceAll(' ', '');
      try {
        // Simpan sementara ke Supabase
        await http.post(
          Uri.parse('$supabaseUrl/temp_users'),
          headers: SupabaseConfig.headers,
          body: json.encode({
            'id': tempDocId,
            'name': name,
            'phone': phone,
            'email': email,
            'registrationTimestamp': DateTime.now().toIso8601String(),
          }),
        );
      } catch (e) {
        debugPrint('Gagal simpan ke Supabase: $e');
      }

      _user = User(name: name, email: email, phone: phone);
      return _user;
    } catch (e) {
      debugPrint('Phone signup error: $e');
      throw Exception('Pendaftaran dengan nomor telepon gagal: $e');
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  Future<void> sendOTP(String phoneNumber) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (fb_auth.FirebaseAuthException e) {
          throw Exception(_mapVerificationError(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      throw Exception('Gagal mengirim OTP: $e');
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  Future<User?> verifyOTP(String smsCode, String phoneNumber) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      if (_verificationId == null) {
        throw Exception('Verifikasi ID tidak ditemukan');
      }

      final fb_auth.AuthCredential credential =
          fb_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final fb_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final fb_auth.User? fbUser = userCredential.user;

      if (fbUser == null) {
        throw Exception('Verifikasi berhasil tetapi user tidak ditemukan');
      }

      // Sync ke Supabase
      await _syncUserToSupabase(
        fbUser.uid,
        name: _user?.name ?? 'User',
        email: _user?.email ?? fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? phoneNumber,
        profileImageUrl: fbUser.photoURL ?? '',
      );

      _isLoggedIn = true;
      _user = User(
        name: fbUser.displayName ?? _user?.name ?? 'User',
        email: fbUser.email ?? _user?.email ?? '',
        phone: fbUser.phoneNumber ?? phoneNumber,
        profileImageUrl: fbUser.photoURL ?? '',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _saveUserData();

      return _user;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      throw Exception('Verifikasi gagal: $e');
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  Future<User?> signInWithGoogle() async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login dengan Google dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final fb_auth.User? fbUser = userCredential.user;

      if (fbUser == null) {
        throw Exception('Gagal login dengan Google');
      }

      // Simpan ke Supabase
      await _syncUserToSupabase(
        fbUser.uid,
        name: fbUser.displayName ?? 'Google User',
        email: fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? '',
        profileImageUrl: fbUser.photoURL ?? '',
      );

      _isLoggedIn = true;
      _user = User(
        name: fbUser.displayName ?? 'Google User',
        email: fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? '',
        profileImageUrl: fbUser.photoURL ?? '',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _saveUserData();

      return _user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception('Login dengan Google gagal: ${e.message}');
    } catch (e) {
      throw Exception('Login dengan Google gagal: $e');
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  Future<void> _syncUserToSupabase(String userId, {String? name, String? email, String? phone, String? profileImageUrl}) async {
    final url = '$supabaseUrl/users';
    
    final body = json.encode({
      'id': userId,
      'name': name ?? 'User',
      'email': email ?? '',
      'phone': phone ?? '',
      'profileImageUrl': profileImageUrl ?? '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'email_verified': true,
    });

    // Check apakah user sudah ada di Supabase
    final response = await http.get(
      Uri.parse('$url?id=eq.$userId'),
      headers: SupabaseConfig.headers,
    );

    if (response.statusCode == 200 && json.decode(response.body).isNotEmpty) {
      // Update jika sudah ada
      await http.patch(
        Uri.parse('$url?id=eq.$userId'),
        headers: SupabaseConfig.headers,
        body: body,
      );
    } else {
      // Insert baru jika belum ada
      await http.post(Uri.parse(url), headers: SupabaseConfig.headers, body: body);
    }
  }

  Future<void> _loadUserFromSupabase(String userId) async {
    final url = '$supabaseUrl/users?id=eq.$userId';

    final response = await http.get(Uri.parse(url), headers: SupabaseConfig.headers);

    if (response.statusCode == 200 && json.decode(response.body).isNotEmpty) {
      final userData = json.decode(response.body).first;
      _user = User(
        name: userData['name'] ?? 'User',
        email: userData['email'] ?? 'No email',
        phone: userData['phone'] ?? '',
        profileImageUrl: userData['profileImageUrl'] ?? '',
      );
      await _saveUserData();
      notifyListeners();
    } else {
      // Jika user tidak ditemukan di Supabase, buat baru
      _user = User(
        name: 'User',
        email: 'No email',
        phone: '',
        profileImageUrl: '',
      );
    }
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('userData');

      if (userJson != null) {
        _user = User.fromJson(json.decode(userJson));
      } else {
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          await _loadUserFromSupabase(firebaseUser.uid);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      _user = User(
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl ?? _user?.profileImageUrl ?? '',
      );

      await _saveUserData();

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        // Update ke Supabase
        await http.patch(
          Uri.parse('$supabaseUrl/users?id=eq.${firebaseUser.uid}'),
          headers: SupabaseConfig.headers,
          body: json.encode({
            'name': name,
            'email': email,
            'phone': phone,
            'profileImageUrl': profileImageUrl ?? _user?.profileImageUrl ?? '',
            'updated_at': DateTime.now().toIso8601String(),
          }),
        );
      }

      if (email.isNotEmpty && email != _firebaseAuth.currentUser?.email) {
        await _firebaseAuth.currentUser?.updateEmail(email);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Profile update error: $e');
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  Future<void> _saveUserData() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(_user!.toJson()));
  }

  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      notifyListeners();
    }
  }

  String _mapVerificationError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Nomor telepon tidak valid';
      case 'too-many-requests':
        return 'Terlalu banyak permintaan. Coba lagi nanti';
      case 'quota-exceeded':
        return 'Kuota habis. Hubungi developer';
      case 'operation-not-allowed':
        return 'Verifikasi tidak diaktifkan';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
