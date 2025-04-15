import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/data/dummy_data.dart'; // Pastikan ini adalah path untuk dummy data

class WishlistProvider with ChangeNotifier {
  List<ProductModel> _wishlistItems = [];

  List<ProductModel> get items => _wishlistItems;

  bool isInWishlist(String bookId) {
    return _wishlistItems.any((book) => book.id == bookId);
  }

  void toggleWishlist(ProductModel book) {
    if (isInWishlist(book.id)) {
      _wishlistItems.removeWhere((item) => item.id == book.id);
    } else {
      _wishlistItems.add(book);
    }
    _saveWishlist();
    notifyListeners();
  }

  // Load wishlist from SharedPreferences
  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList('wishlist');
      
      if (savedIds != null && savedIds.isNotEmpty) {
        final List<ProductModel> loadedItems = [];

        for (String id in savedIds) {
          try {
            // Cari book dari dummyProducts atau data produk lain
            final book = dummyProducts.firstWhere(
              (book) => book.id == id, 
              orElse: () => _createDefaultBook(id),
            );
            loadedItems.add(book);
          } catch (e) {
            debugPrint('Error loading book $id: $e');
          }
        }

        _wishlistItems = loadedItems;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
      await clearCorruptedWishlist();
    }
  }

  ProductModel _createDefaultBook(String bookId) {
    // Ini untuk handle jika book tidak ditemukan
    return ProductModel(
      imagePath: 'assets/images/default_book.jpg',
      title: 'Book Not Available',
      id: bookId,
      price: 0.0,
      rating: 0.0,
      reviews: 0,
      author: 'Unknown',
      pageCount: 0,
      genre: 'Unknown',
      publisher: 'Unknown',
      publishedDate: 'N/A',
      description: 'This book is no longer available.',
      isBestseller: false,
      isPurchased: false, // Menambahkan ini untuk konsistensi dengan model
    );
  }

  // Save wishlist ke SharedPreferences
  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'wishlist',
        _wishlistItems.map((book) => book.id).toList(),
      );
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  // Clear wishlist yang corrupt (jika ada masalah)
  Future<void> clearCorruptedWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wishlist');
    _wishlistItems = [];
    notifyListeners();
  }
}
