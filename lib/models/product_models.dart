import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String imageBase64; 
  final String title;
  final String author;
  final String genre;
  final String publisher;
  final String publishedDate;
  final String description;
  final double price;
  final double rating;
  final int reviews;
  final int pageCount;
  final bool isBestseller;
  final bool isPurchased;
  final String sellerId; 

  ProductModel({
    required this.id,
    required this.imageBase64,
    required this.title,
    required this.author,
    required this.genre,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.pageCount,
    required this.isBestseller,
    required this.isPurchased,
    required this.sellerId, 
  });

  // BARU: Factory constructor untuk membuat objek dari dokumen Firestore.
  // Ini adalah pengganti utama untuk fromJson/fromMap dalam konteks Firestore.
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    // Ambil data dari dokumen sebagai Map
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id, // ID diambil dari ID dokumen itu sendiri
      // Gunakan 'imageUrl' sesuai dengan perubahan dan praktik terbaik
      imageBase64: data['imageBase64'] ?? '',
      title: data['title'] ?? 'No Title',
      author: data['author'] ?? 'No Author',
      genre: data['genre'] ?? 'N/A',
      publisher: data['publisher'] ?? 'N/A',
      publishedDate: data['publishedDate'] ?? 'N/A',
      description: data['description'] ?? 'No Description',
      // Konversi number (bisa int atau double) dari Firestore ke double
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: data['reviews'] ?? 0,
      pageCount: data['pageCount'] ?? 0,
      isBestseller: data['isBestseller'] ?? false,
      isPurchased: data['isPurchased'] ?? false,
      sellerId: data['sellerId'] ?? '', 
    );
  }

  // Method toJson untuk mengubah objek Dart kembali menjadi Map.
  // Berguna jika Anda ingin mengirim data ke Firestore.
  Map<String, dynamic> toJson() {
    return {
      // 'id' tidak perlu dimasukkan di sini karena sudah menjadi ID dokumen
      'imageBase64': imageBase64,
      'title': title,
      'author': author,
      'genre': genre,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'pageCount': pageCount,
      'isBestseller': isBestseller,
      'isPurchased': isPurchased,
      'sellerId': sellerId,
    };
  }
}