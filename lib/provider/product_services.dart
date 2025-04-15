import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_models.dart';
import '../data/dummy_data.dart';

class ProductService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Add new product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).set(product.toMap());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _productsCollection.doc(id).get();
      return doc.exists ? ProductModel.fromMap(doc.data() as Map<String, dynamic>) : null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Get all products with pagination
  Future<List<ProductModel>> getProducts({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _productsCollection.limit(limit);
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get bestseller products
  Future<List<ProductModel>> getBestsellers({int limit = 5}) async {
    try {
      final snapshot = await _productsCollection
          .where('isBestseller', isEqualTo: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bestsellers: $e');
    }
  }

  Future<List<ProductModel>> getPurchasedBooks() async {
    final snapshot = await _productsCollection
        .where('isPurchased', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }


  // Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Upload sample products (for development)
  Future<void> uploadSampleProducts(List<ProductModel> products) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final product in products) {
        batch.set(_productsCollection.doc(product.id), product.toMap());
      }
      await batch.commit();
      debugPrint('Sample products uploaded successfully');
    } catch (e) {
      throw Exception('Failed to upload sample products: $e');
    }
  }

  Future<void> uploadDummyProductsToFirebase() async {
  final productService = ProductService();
  
  try {
    await productService.uploadSampleProducts(dummyProducts);
    print('Products successfully uploaded to Firebase!');
  } catch (e) {
    print('Error uploading products: $e');
  }
}
}