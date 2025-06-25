import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageBase64; // DIUBAH
  final int order;
  final bool active;

  BannerModel({
    required this.id,
    required this.imageBase64, // DIUBAH
    required this.order,
    required this.active,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      imageBase64: data['imageBase64'] ?? '', // DIUBAH
      order: data['order'] ?? 99,
      active: data['active'] ?? false,
    );
  }
  
  // Method untuk mengubah objek menjadi Map, berguna untuk upload
  Map<String, dynamic> toJson() {
    return {
      'imageBase64': imageBase64,
      'order': order,
      'active': active,
    };
  }
}