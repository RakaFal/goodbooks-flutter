import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id; 
  final String name;
  final String email;
  final String phone;
  final String profileImageBase64;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.profileImageBase64 = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Guest',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImageBase64: json['profileImageBase64'] ?? '',
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    // Ambil semua data dari dokumen sebagai Map
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id, // ID diambil dari ID dokumen itu sendiri, bukan dari field
      name: data['name'] ?? 'Guest',
      email: data['email'] ?? 'No Email',
      phone: data['phone'] ?? '',
      profileImageBase64: data['profileImageBase64'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'profileImageBase64': profileImageBase64,
      };
}