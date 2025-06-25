import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodbooks_flutter/models/product_models.dart';

class WishlistProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<ProductModel> _wishlistItems = [];
  String? _userId; // Untuk menyimpan ID pengguna yang sedang login

  List<ProductModel> get items => _wishlistItems;

  // DIUBAH: Update provider dengan userId dari AuthProvider
  void update(String? userId) {
    if (userId != null && userId.isNotEmpty) {
      _userId = userId;
      loadWishlist(); // Muat wishlist saat user login
    } else {
      // Jika user logout, bersihkan wishlist
      _userId = null;
      _wishlistItems = [];
      notifyListeners();
    }
  }

  bool isInWishlist(String bookId) {
    return _wishlistItems.any((book) => book.id == bookId);
  }

  // DIUBAH: Logika toggle sekarang berinteraksi dengan Firestore
  Future<void> toggleWishlist(ProductModel book) async {
    if (_userId == null) {
      debugPrint("Tidak bisa toggle wishlist, user tidak login.");
      return;
    }

    final wishlistItemRef = _db
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .doc(book.id);

    if (isInWishlist(book.id)) {
      // Hapus dari Firestore
      await wishlistItemRef.delete();
      // Hapus dari state lokal
      _wishlistItems.removeWhere((item) => item.id == book.id);
    } else {
      // Tambahkan ke Firestore
      await wishlistItemRef.set({
        'addedAt': FieldValue.serverTimestamp(), // Simpan waktu ditambahkannya
      });
      // Tambahkan ke state lokal
      _wishlistItems.add(book);
    }
    
    notifyListeners();
  }

  // DIUBAH: Memuat wishlist dari Firestore, bukan SharedPreferences
  Future<void> loadWishlist() async {
    if (_userId == null) {
      debugPrint("Tidak bisa memuat wishlist, user tidak login.");
      _wishlistItems = [];
      notifyListeners();
      return;
    }

    try {
      // 1. Ambil semua ID buku dari sub-koleksi wishlist pengguna
      final wishlistSnapshot = await _db
          .collection('users')
          .doc(_userId)
          .collection('wishlist')
          .get();
      
      if (wishlistSnapshot.docs.isEmpty) {
        _wishlistItems = [];
        notifyListeners();
        return;
      }

      final bookIds = wishlistSnapshot.docs.map((doc) => doc.id).toList();

      // 2. Ambil detail lengkap dari setiap buku berdasarkan ID-nya dari koleksi 'products'
      final productsSnapshot = await _db
          .collection('products')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      // 3. Ubah dokumen produk menjadi objek ProductModel
      _wishlistItems = productsSnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      notifyListeners();

    } catch (e) {
      debugPrint('Error loading wishlist from Firestore: $e');
      _wishlistItems = []; // Bersihkan jika terjadi error
      notifyListeners();
    }
  }

  // DIHAPUS: Semua fungsi terkait SharedPreferences dan data dummy
  // _saveWishlist(), loadWishlist() (versi lama), _createDefaultBook(), clearCorruptedWishlist()
}