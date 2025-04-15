import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoggedIn = false;
  bool _isAttemptingLogin = false;
  User? _user;

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
      // Firebase Authentication - Sign In
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan user data setelah login berhasil
      _isLoggedIn = true;
      _user = User(
        name: userCredential.user?.displayName ?? 'John Doe',
        email: userCredential.user?.email ?? email,
        phone: userCredential.user?.phoneNumber ?? '+6281234567890',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _saveUserData();
      return true;
    } on FirebaseAuthException catch (e) {
      // Tangani error yang terjadi saat login
      debugPrint('Login failed: ${e.message}');
      return false;
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  // Check status login user
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
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
    notifyListeners();
  }
}
