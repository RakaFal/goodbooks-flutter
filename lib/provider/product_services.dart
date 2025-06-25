import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:goodbooks_flutter/models/banner_models.dart';
import 'package:goodbooks_flutter/models/category_models.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductService {
  // Inisialisasi instance Firestore dan Storage
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Nama koleksi untuk produk
  final String _productsCollection = 'products';

  Future<User> getSellerInfo(String sellerId) async {
    try {
      // Ambil dokumen user dari koleksi 'users'
      final docSnapshot = await _db.collection('users').doc(sellerId).get();

      if (docSnapshot.exists) {
        // Ubah dokumen menjadi objek UserModel
        return User.fromFirestore(docSnapshot);
      } else {
        // Kembalikan user 'tidak ditemukan' jika ID tidak valid
        return User(id: sellerId, name: 'Penjual Tidak Ditemukan', email: '');
      }
    } catch (e) {
      debugPrint("Error getting seller info: $e");
      throw Exception('Gagal memuat info penjual');
    }
  }
  
  // 🔥 Tambah produk baru ke Firestore
  Future<void> addProduct(ProductModel product) async {
    try {
      // Menggunakan .toJson() yang sudah kita buat di model
      await _db.collection(_productsCollection).add(product.toJson());
    } catch (e) {
      debugPrint('Error adding product: $e');
      throw Exception('Gagal menambahkan produk');
    }
  }

  // 🖊️ Perbarui produk yang ada di Firestore
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _db.collection(_productsCollection).doc(product.id).update(product.toJson());
    } catch (e) {
      debugPrint('Error updating product: $e');
      throw Exception('Gagal memperbarui produk');
    }
  }

  // 🗑️ Hapus produk dari Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection(_productsCollection).doc(productId).delete();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      throw Exception('Gagal menghapus produk');
    }
  }

  // 🔍 Dapatkan semua produk
  Future<List<ProductModel>> getProducts({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _db.collection(_productsCollection).limit(limit).get();
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      throw Exception('Gagal mengambil produk');
    }
  }

  //  bestseller
  Future<List<ProductModel>> getBestsellers({int limit = 5}) async {
    try {
      // Query dengan filter 'where'
      QuerySnapshot snapshot = await _db
          .collection(_productsCollection)
          .where('isBestseller', isEqualTo: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting bestsellers: $e');
      // Error ini sering terjadi jika Anda belum membuat Index di Firestore.
      // Firebase akan memberikan link di log error untuk membuatnya secara otomatis.
      throw Exception('Gagal memuat bestsellers. Pastikan Index sudah dibuat di Firestore.');
    }
  }

  // 🧾 Dapatkan buku yang sudah dibeli pengguna (Struktur Baru)
  Future<List<ProductModel>> getPurchasedBooks(String userId) async {
    try {
      // Ambil ID buku dari sub-koleksi pengguna
      final purchaseSnapshot = await _db.collection('users').doc(userId).collection('purchased_books').get();
      
      if (purchaseSnapshot.docs.isEmpty) {
        return []; // Kembalikan list kosong jika tidak ada pembelian
      }

      // Ekstrak semua ID buku yang dibeli
      final bookIds = purchaseSnapshot.docs.map((doc) => doc.id).toList();

      // Ambil detail lengkap dari setiap buku berdasarkan ID-nya
      final productsSnapshot = await _db.collection(_productsCollection).where(FieldPath.documentId, whereIn: bookIds).get();

      return productsSnapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
      
    } catch (e) {
      debugPrint('Error getting purchased books: $e');
      throw Exception('Gagal memuat buku pembelian');
    }
  }

    // 🖼️ Dapatkan semua banner yang aktif
  Future<List<BannerModel>> getBanners() async {
    try {
      final snapshot = await _db
          .collection('banners')
          .where('active', isEqualTo: true) // Hanya ambil banner yang aktif
          .orderBy('order') // Urutkan berdasarkan field 'order'
          .get();
      return snapshot.docs.map((doc) => BannerModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting banners: $e');
      throw Exception('Gagal memuat banners. Pastikan Index sudah dibuat.');
    }
  }

  // 📚 Dapatkan semua kategori
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _db
          .collection('categories')
          .orderBy('order') // Urutkan kategori jika ada field 'order'
          .get();
      return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      throw Exception('Gagal memuat kategori.');
    }
  }


  // 📤 Upload gambar ke Firebase Storage
  Future<String> uploadImage(File imageFile, String productId) async {
    try {
      // Membuat path unik di Firebase Storage, misal: 'product_images/xyz123.jpg'
      final ref = _storage.ref().child('product_images').child('$productId.jpg');
      
      // Mengupload file secara langsung, tidak perlu membuat objek File lagi.
      final uploadTask = await ref.putFile(imageFile);
      
      // Mendapatkan URL download setelah upload selesai
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;

    } on FirebaseException catch (e) {
      debugPrint('Error saat upload ke Firebase Storage: $e');
      throw Exception('Gagal mengupload gambar');
    }
  }

  // Helper untuk upload banyak produk (jika masih diperlukan)
  Future<void> uploadSampleProducts(List<ProductModel> products) async {
    for (var product in products) {
      try {
        await addProduct(product);
      } catch (e) {
        debugPrint('Gagal upload sample: ${product.title}');
      }
    }
  }

    // 👤 Dapatkan semua produk berdasarkan ID penjual
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _db
          .collection(_productsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .get();
      
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting products by seller: $e');
      throw Exception('Gagal memuat produk Anda.');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // Query ini akan mencari dokumen yang field 'title'-nya
      // lebih besar atau sama dengan query, dan lebih kecil dari query + karakter "aneh".
      // Ini adalah trik standar untuk "starts with" di Firestore.
      final snapshot = await _db
          .collection(_productsCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10) // Batasi hasil pencarian agar tidak terlalu banyak
          .get();
      
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      throw Exception('Gagal melakukan pencarian');
    }
  }
}