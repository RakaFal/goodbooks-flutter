import 'package:flutter/foundation.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SellerProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedProducts = prefs.getString('seller_products');
    if (savedProducts != null) {
      final List<dynamic> productJson = json.decode(savedProducts);
      _products = productJson.map((item) => ProductModel.fromJson(item)).toList();
    }
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    _products.add(product);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> removeProduct(String productId) async {
    _products.removeWhere((product) => product.id == productId);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'seller_products',
      json.encode(_products.map((p) => p.toJson()).toList(),
    ));
  }
}