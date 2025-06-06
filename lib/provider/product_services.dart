import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:flutter/foundation.dart'; 
import 'package:goodbooks_flutter/config/supabase_config.dart'; 
import 'dart:io';

class ProductService {
  final String productsUrl = '${SupabaseConfig.supabaseUrl}/rest/v1/products';
  final String anonKey = SupabaseConfig.supabaseAnonKey;

  Map<String, String> get headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };

  // 🔥 Add new product
  Future<void> addProduct(ProductModel product) async {
    final response = await http.post(
      Uri.parse(productsUrl),
      headers: headers,
      body: json.encode(product.toMap()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal menambahkan produk: ${response.body}');
    }
  }

  // 🔍 Get all products
  Future<List<ProductModel>> getProducts({int limit = 10}) async {
    final url = '$productsUrl?select=*&limit=$limit';
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ProductModel.fromMap(item)).toList();
    } else {
      throw Exception('Gagal mengambil produk: ${response.body}');
    }
  }

  // ⬇️ Get bestsellers
  Future<List<ProductModel>> getBestsellers({int limit = 5}) async {
    final url = '$productsUrl?select=*&isBestseller=eq.true&limit=$limit';
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ProductModel.fromMap(item)).toList();
    } else {
      throw Exception('Gagal memuat bestsellers: ${response.body}');
    }
  }

  // 🧾 Get user's purchased books
  Future<List<ProductModel>> getPurchasedBooks(String userId) async {
    final url = '$productsUrl?select=*&isPurchased=eq.true&userId=eq.$userId';
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ProductModel.fromMap(item)).toList();
    } else {
      throw Exception('Gagal memuat buku pembelian: ${response.body}');
    }
  }

  // 🖊️ Update product
  Future<void> updateProduct(ProductModel product) async {
    final url = '$productsUrl?id=eq.${product.id}';
    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: json.encode(product.toMap()),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Gagal memperbarui produk: ${response.body}');
    }
  }

  // 🗑️ Delete product
  Future<void> deleteProduct(String productId) async {
    final url = '$productsUrl?id=eq.$productId';
    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Gagal menghapus produk: ${response.body}');
    }
  }

  // 📤 Upload sample products
  Future<void> uploadSampleProducts(List<ProductModel> products) async {
    for (var product in products) {
      final response = await http.post(
        Uri.parse(productsUrl),
        headers: headers,
        body: json.encode(product.toMap()),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        debugPrint('Gagal upload: ${product.title}');
      }
    }
  }

  Future<String?> uploadImageToSupabase(String filePath, String fileName) async {
    final url = '${SupabaseConfig.supabaseUrl}/storage/v1/object/products/$fileName';

    final imageFile = File(filePath);
    final headers = {
      'apikey': SupabaseConfig.supabaseAnonKey,
      'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
      'Content-Type': 'image/jpeg', // Atau 'image/png'
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: await imageFile.readAsBytes(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return '${SupabaseConfig.supabaseUrl}/storage/v1/object/public/products/$fileName';
      } else {
        debugPrint('Upload gagal: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error saat upload: $e');
      return null;
    }
  }
}