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
      
      // Also load data from Firestore if available
      if (userCredential.user != null) {
        await _loadUserFromFirestore(userCredential.user!.uid);
      }
      
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
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    String profileImageUrl = '', // Provide default empty string
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
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });

      // 4. Update state lokal
      _isLoggedIn = true;
      _user = User(
        name: name, 
        email: email, 
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

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

  // Fungsi Sign-Up untuk Nomor Telepon
  Future<User?> signUpWithPhone({
    required String phone,
    required String name,
    String email = '', // Provide default value
    String password = '', // Make password optional since we're using OTP
  }) async {
    _isAttemptingLogin = true;
    notifyListeners();

    try {
      // Kirim OTP ke nomor telepon
      await sendOTP(phone);

      // Important: Create a temporary user record
      // Final user record should be created after OTP verification
      // We'll use phone number as temporary ID and update it after verification
      String tempDocId = 'temp_' + phone.replaceAll('+', '').replaceAll(' ', ''); 
      
      // Store temp user record with registration timestamp
      try {
        await _firestore.collection('temp_users').doc(tempDocId).set({
          'name': name,
          'phone': phone,
          'email': email,
          // Hash or omit password in production
          'registrationTimestamp': FieldValue.serverTimestamp(),
        });
      } catch (firestoreError) {
        debugPrint('Warning: Could not save temporary user data: $firestoreError');
        // Continue even if temp storage fails
      }
      
      // Note: We don't set _isLoggedIn = true here because OTP verification isn't complete
      // We'll do that in verifyOTP method instead
      
      // Store pending user data temporarily
      _user = User(name: name, email: email, phone: phone);
      
      // Return user object but don't save login state yet
      return _user;  
    } catch (e) {
      debugPrint('Phone signup error: $e');
      throw Exception('Pendaftaran dengan nomor telepon gagal: $e');
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
      final fb_auth.User? fbUser = userCredential.user;
      
      if (fbUser == null) {
        throw Exception('Verifikasi berhasil tetapi user tidak ditemukan');
      }

      // Check if user document exists in Firestore
      final userDocRef = _firestore.collection('users').doc(fbUser.uid);
      final userDocSnapshot = await userDocRef.get();
      
      String userName = fbUser.displayName ?? 'User';
      String userEmail = fbUser.email ?? '';
      String userPhone = fbUser.phoneNumber ?? phoneNumber;
      String userProfileImageUrl = '';
      
      // If the document exists, get the existing data
      if (userDocSnapshot.exists && userDocSnapshot.data() != null) {
        final userData = userDocSnapshot.data()!;
        userName = userData['name'] ?? userName;
        userEmail = userData['email'] ?? userEmail;
        userPhone = userData['phone'] ?? userPhone;
        userProfileImageUrl = userData['profileImageUrl'] ?? '';
        
        // Update the document with latest info
        await userDocRef.update({
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // Document doesn't exist, create it
        await userDocRef.set({
          'name': userName,
          'email': userEmail, 
          'phone': userPhone,
          'profileImageUrl': userProfileImageUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      // Simpan data user
      _isLoggedIn = true;
      _user = User(
        name: userName,
        email: userEmail,
        phone: userPhone,
        profileImageUrl: userProfileImageUrl,
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
          'profileImageUrl': fbUser.photoURL ?? '',
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

  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        _user = User(
          name: data['name'] ?? 'User',
          email: data['email'] ?? 'No email',
          phone: data['phone'] ?? '',
          profileImageUrl: data['profileImageUrl'] ?? '',
        );
        await _saveUserData();
        notifyListeners();
      } else {
        // If user document doesn't exist but Firebase auth user exists,
        // create the document with basic info from Firebase Auth
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          debugPrint('Creating missing user document for ${firebaseUser.uid}');
          await _firestore.collection('users').doc(uid).set({
            'name': firebaseUser.displayName ?? 'User',
            'email': firebaseUser.email ?? '',
            'phone': firebaseUser.phoneNumber ?? '',
            'profileImageUrl': firebaseUser.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'emailVerified': firebaseUser.emailVerified,
          });
          
          _user = User(
            name: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? '',
            phone: firebaseUser.phoneNumber ?? '',
            profileImageUrl: firebaseUser.photoURL ?? '',
          );
          await _saveUserData();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading user from Firestore: $e');
    }
  }

  // Ambil data user yang tersimpan
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('userData');
      
      if (userJson != null) {
        _user = User.fromJson(Map<String, dynamic>.from(json.decode(userJson)));
      } else {
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          await _loadUserFromFirestore(firebaseUser.uid);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Save user data ke local storage
  Future<void> _saveUserData() async {
    if (_user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(_user!.toJson()));
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Fungsi update profile user
  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      // Update local state
      _user = User(
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl ?? _user?.profileImageUrl ?? '',
      );
      
      // Save to SharedPreferences
      await _saveUserData();
      
      // Update in Firestore if user is logged in
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        // First check if the document exists
        final docRef = _firestore.collection('users').doc(firebaseUser.uid);
        final docSnapshot = await docRef.get();
        
        final userData = {
          'name': name,
          'email': email,
          'phone': phone,
          'profileImageUrl': profileImageUrl ?? _user?.profileImageUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        if (docSnapshot.exists) {
          // Document exists, update it
          await docRef.update(userData);
        } else {
          // Document doesn't exist, create it
          userData['createdAt'] = FieldValue.serverTimestamp(); // Add creation timestamp
          await docRef.set(userData);
        }
        
        // Update email in Firebase Auth if it's changed
        if (email != firebaseUser.email && email.isNotEmpty) {
          await firebaseUser.updateEmail(email);
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Profile update error: $e');
      throw Exception('Gagal memperbarui profil: $e');
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _user = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');
      
      await _firebaseAuth.signOut(); // Logout Firebase Auth
      await _googleSignIn.signOut(); // Logout Google SignIn
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      notifyListeners();
    }
  }
}