import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodbooks_flutter/models/best_product_models.dart';

class WishlistProvider with ChangeNotifier {
  List<BestproductModels> _wishlistItems = [];

  List<BestproductModels> get items => _wishlistItems;

  bool isInWishlist(String bookId) {
    return _wishlistItems.any((book) => book.bookId == bookId);
  }

  void toggleWishlist(BestproductModels book) {
    if (isInWishlist(book.bookId)) {
      _wishlistItems.removeWhere((item) => item.bookId == book.bookId);
    } else {
      _wishlistItems.add(book);
    }
    _saveWishlist();
    notifyListeners();
  }

  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList('wishlist');
      
      if (savedIds != null) {
        final allProducts = BestproductModels.getProducts();
        final List<BestproductModels> loadedItems = [];
        
        for (String id in savedIds) {
          try {
            final book = allProducts.firstWhere(
              (book) => book.bookId == id,
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

  BestproductModels _createDefaultBook(String bookId) {
    return BestproductModels(
      imagePath: 'assets/images/default_book.jpg',
      title: 'Book Not Available',
      bookId: bookId,
      price: 0,
      rating: 0,
      reviews: 0,
      author: 'Unknown',
      pageCount: 0,
      publisher: 'Unknown',
      publishedDate: 'N/A',
      description: 'This book is no longer available',
      isBestseller: false,
    );
  }

  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'wishlist',
        _wishlistItems.map((book) => book.bookId).toList(),
      );
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  Future<void> clearCorruptedWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wishlist');
    _wishlistItems = [];
    notifyListeners();
  }
}