import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodbooks_flutter/models/user_model.dart'; 

class AuthProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // BARU: Instance Firestore

  static const String _usersCollection = 'users'; // BARU: Konstanta untuk nama koleksi

  bool _isLoggedIn = false;
  User? _user;
  String? _verificationId;
  int? _resendToken;

  bool _isAttemptingLogin = false;
  bool get isAttemptingLogin => _isAttemptingLogin;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;

  Future<void> initialize() async {
    await checkLoginStatus();
  }

  Future<void> _syncUserToFirestore(
    String userId, {
    required String name,
    required String email,
    required String phone,
    String? profileImageBase64,
  }) async {
    final userDocRef = _firestore.collection(_usersCollection).doc(userId);

    final userData = {
      'uid': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageBase64': profileImageBase64 ?? '',
      'updated_at': FieldValue.serverTimestamp(), 
    };

    await userDocRef.set(userData, SetOptions(merge: true));

    final docSnapshot = await userDocRef.get();
    if (!docSnapshot.data()!.containsKey('created_at')) {
      await userDocRef.update({'created_at': FieldValue.serverTimestamp()});
    }
  }

  Future<void> _loadUserFromFirestore(String userId) async {
    final docSnapshot = await _firestore.collection(_usersCollection).doc(userId).get();

    if (docSnapshot.exists) {
      final userData = docSnapshot.data()!;
      _user = User(
        id: userId,
        name: userData['name'] ?? 'User',
        email: userData['email'] ?? 'No email',
        phone: userData['phone'] ?? '',
        profileImageBase64: userData['profileImageBase64'] ?? '',
      );
      await _saveUserData();
      notifyListeners();
    } else {
      debugPrint('User with UID $userId not found in Firestore.');
    }
  }

  // --- Fungsi yang Dimodifikasi ---

  /// DIUBAH: Logika pengecekan status login disederhanakan.
  Future<void> checkLoginStatus() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      _isLoggedIn = true;
      await loadUserData(); // loadUserData akan memuat dari Firestore
    } else {
      _isLoggedIn = false;
      _user = null;
      // Membersihkan cache jika user tidak lagi login di Firebase
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');
    }
    notifyListeners();
  }

  /// DIUBAH: Mengganti sinkronisasi ke Supabase dengan Firestore.
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      final fbUser = userCredential.user!;

      // Muat data dari Firestore setelah login berhasil
      await _loadUserFromFirestore(fbUser.uid);

      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

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

  /// DIUBAH: Mengganti sinkronisasi ke Supabase dengan Firestore.
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    String profileImageBase64 = '',
  }) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbUser = userCredential.user!;
      await fbUser.sendEmailVerification();

      // Sinkronisasi data user baru ke Firestore
      await _syncUserToFirestore(
        fbUser.uid,
        name: name,
        email: email,
        phone: phone,
        profileImageBase64: profileImageBase64,
      );

      _isLoggedIn = true;
      _user = User(
        id: fbUser.uid,
        name: name,
        email: email,
        phone: phone,
        profileImageBase64: profileImageBase64,
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
  
  /// DIUBAH: Tidak ada lagi penyimpanan sementara ke database.
  /// Data disimpan di state provider sampai verifikasi OTP berhasil.
  Future<void> signUpWithPhone({
    required String phone,
    required String name,
    String email = '',
  }) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      // Simpan data sementara di state provider, bukan di database.
      _user = User(id: '', name: name, email: email, phone: phone);

      await sendOTP(phone); // Lanjutkan dengan mengirim OTP
    } catch (e) {
      _user = null; // Hapus data sementara jika gagal
      debugPrint('Phone signup error: $e');
      throw Exception('Pendaftaran dengan nomor telepon gagal: $e');
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  /// DIUBAH: Mengganti sinkronisasi ke Supabase dengan Firestore.
  Future<User?> verifyOTP(String smsCode, String phoneNumber) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      if (_verificationId == null) {
        throw Exception('Verifikasi ID tidak ditemukan. Kirim ulang OTP.');
      }

      final credential = fb_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;

      if (fbUser == null) {
        throw Exception('Verifikasi berhasil tetapi user tidak ditemukan');
      }

      // Ambil data sementara dari state (_user) yang di-set di `signUpWithPhone`
      final tempUser = _user;
      if (tempUser == null) {
        throw Exception('Data pendaftaran tidak ditemukan. Mohon ulangi proses.');
      }

      // Sinkronisasi ke Firestore setelah verifikasi berhasil
      await _syncUserToFirestore(
        fbUser.uid,
        name: tempUser.name,
        email: tempUser.email,
        phone: fbUser.phoneNumber ?? phoneNumber, 
        profileImageBase64: '',
      );

      _isLoggedIn = true;
      _user = User(
        id: fbUser.uid, 
        name: tempUser.name,
        email: tempUser.email,
        phone: fbUser.phoneNumber ?? phoneNumber,
        profileImageBase64: '',
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
  
  /// DIUBAH: Mengganti sinkronisasi ke Supabase dengan Firestore.
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

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;

      if (fbUser == null) {
        throw Exception('Gagal login dengan Google');
      }

      // Sinkronisasi ke Firestore
      await _syncUserToFirestore(
        fbUser.uid,
        name: fbUser.displayName ?? 'Google User',
        email: fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? '',
        profileImageBase64: '',
      );

      _isLoggedIn = true;
      _user = User(
        id: fbUser.uid, // <-- TAMBAHKAN INI
        name: fbUser.displayName ?? 'Google User',
        email: fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? '',
        profileImageBase64: '',
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

  /// DIUBAH: Memuat data dari cache, jika tidak ada, muat dari Firestore.
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('userData');

      if (userJson != null) {
        _user = User.fromJson(json.decode(userJson));
      } else {
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          // Ganti _loadUserFromSupabase menjadi _loadUserFromFirestore
          await _loadUserFromFirestore(firebaseUser.uid);
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
    String? profileImageBase64,
  }) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw Exception('User tidak login, tidak dapat memperbarui profil.');
    }

    try {
      _user = User(
        id: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        profileImageBase64: profileImageBase64 ?? _user?.profileImageBase64 ?? '',
      );
      await _saveUserData(); 
      notifyListeners();

      await _firestore.collection(_usersCollection).doc(firebaseUser.uid).update({
        'name': name,
        'email': email,
        'phone': phone,
        'profileImageBase64': profileImageBase64 ?? _user?.profileImageBase64 ?? '',
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      if (email.isNotEmpty && email != firebaseUser.email) {
        await firebaseUser.updateEmail(email);
      }
      await firebaseUser.updateDisplayName(name);

    } catch (e) {
      debugPrint('Profile update error: $e');
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  Future<void> bypassLogin() async {
    _isLoggedIn = true;
    _user = User(
      id: 'bypass_user', 
      name: 'Test User',
      email: 'test@example.com',
      phone: '+6281234567890',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await _saveUserData();
    notifyListeners();
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

  Future<void> _saveUserData() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(_user!.toJson()));
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoggedIn = false;
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');
      notifyListeners();
    }
  }

  String _mapVerificationError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Nomor telepon tidak valid';
      case 'too-many-requests':
        return 'Terlalu banyak permintaan. Coba lagi nanti';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}