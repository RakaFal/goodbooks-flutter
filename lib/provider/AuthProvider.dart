import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class User {
  final String name;
  final String email;
  final String phone;

  User({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? 'John Doe',
      email: json['email'] ?? 'johndoe@example.com',
      phone: json['phone'] ?? '+6281234567890',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };
}

class AuthProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoggedIn = false;
  bool _isAttemptingLogin = false;
  User? _user;
  String? _verificationId;
  int? _resendToken;

  bool get isLoggedIn => _isLoggedIn;
  bool get isAttemptingLogin => _isAttemptingLogin;
  User? get user => _user;

  Future<void> initialize() async {
    await checkLoginStatus();
    if (_isLoggedIn) {
      await loadUserData();
    }
  }

  // Fungsi login dengan email dan password
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
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _saveUserData();
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
        case 'user-disabled':
          errorMessage = 'Akun dinonaktifkan';
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

  // Check status login user
  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firebaseUser = _firebaseAuth.currentUser;
      
      // Sync antara Firebase Auth dan local storage
      if (firebaseUser != null) {
        _isLoggedIn = true;
        await prefs.setBool('isLoggedIn', true);
        await loadUserData();
      } else {
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        if (_isLoggedIn) {
          // Force logout jika local storage mengatakan logged in tapi Firebase tidak
          await logout();
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      _isLoggedIn = false;
    } finally {
      notifyListeners();
    }
  }

  // Fungsi Sign-Up yang Lengkap
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      // 1. Buat user di Firebase Authentication
      final fb_auth.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      // 2. Kirim email verifikasi
      await userCredential.user?.sendEmailVerification();

      // 3. Simpan data tambahan ke Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
            'name': name,
            'email': email,
            'phone': phone,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'emailVerified': false,
          });

      // 4. Update state lokal
      _isLoggedIn = true;
      _user = User(name: name, email: email, phone: phone);

      // 5. Simpan ke SharedPreferences
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
  
  // Method untuk mengirim OTP
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

  // Method untuk verifikasi OTP
  Future<User?> verifyOTP(String smsCode, String phoneNumber) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      if (_verificationId == null) {
        throw Exception('Verifikasi ID tidak ditemukan');
      }

      final fb_auth.AuthCredential credential = fb_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final fb_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Simpan data user
      _isLoggedIn = true;
      _user = User(
        name: userCredential.user?.displayName ?? 'User',
        email: userCredential.user?.email ?? '',
        phone: userCredential.user?.phoneNumber ?? phoneNumber,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _saveUserData();

      return _user;
    } catch (e) {
      throw Exception('Verifikasi gagal: $e');
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login dengan Google dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final fb_auth.User? fbUser = userCredential.user;
      if (fbUser == null) {
        throw Exception('Gagal login dengan Google');
      }

      // Save or update user data in Firestore
      final userDoc = _firestore.collection('users').doc(fbUser.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'name': fbUser.displayName ?? 'Google User',
          'email': fbUser.email,
          'phone': fbUser.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'emailVerified': fbUser.emailVerified,
        });
      } else {
        await userDoc.update({
          'updatedAt': FieldValue.serverTimestamp(),
          'emailVerified': fbUser.emailVerified,
        });
      }

      _isLoggedIn = true;
      _user = User(
        name: fbUser.displayName ?? 'Google User',
        email: fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? '',
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

  // Mapping error code ke pesan yang lebih user-friendly
  String _mapVerificationError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Nomor telepon tidak valid';
      case 'too-many-requests':
        return 'Terlalu banyak permintaan. Coba lagi nanti';
      case 'quota-exceeded':
        return 'Kuota verifikasi habis. Hubungi developer';
      case 'operation-not-allowed':
        return 'Verifikasi OTP tidak diaktifkan';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }

  // Ambil data user yang tersimpan
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('userData');
    if (userJson != null) {
      _user = User.fromJson(Map<String, dynamic>.from(json.decode(userJson)));
    } else {
      _user = User(
        name: 'John Doe',
        email: 'johndoe@example.com',
        phone: '+6281234567890',
      );
    }
    notifyListeners();
  }

  // Save user data ke local storage
  Future<void> _saveUserData() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(_user!.toJson()));
  }

  // Fungsi update profile user
  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _user = User(
      name: name,
      email: email,
      phone: phone,
    );
    await _saveUserData();
    notifyListeners();
  }

  // Fungsi logout
  Future<void> logout() async {
    _isLoggedIn = false;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userData');
    await _firebaseAuth.signOut(); // Logout Firebase Auth
    await _googleSignIn.signOut(); // Logout Google SignIn
    notifyListeners();
  }
}

