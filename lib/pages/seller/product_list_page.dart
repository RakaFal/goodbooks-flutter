import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/provider/seller_product_provider.dart';
import 'package:provider/provider.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Produk Anda")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/add-product');
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: sellerProvider.products.isEmpty
              ? const Center(child: Text("Belum ada buku dijual"))
              : ListView.builder(
                  itemCount: sellerProvider.products.length,
                  itemBuilder: (context, index) {
                    final book = sellerProvider.products[index];
                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            book.imagePath,
                            width: 60,
                            height: 90,
                            errorBuilder: (_, __, ___) => const Icon(Icons.book),
                          ),
                        ),
                        title: Text(book.title),
                        subtitle: Text("${book.author} • Rp${book.price.toStringAsFixed(0)}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            sellerProvider.removeProduct(book.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}