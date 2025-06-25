import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/pages/book_detail.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';

class BookSearchDelegate extends SearchDelegate<ProductModel?> {
  final ProductService productService = ProductService();

  // Aksi di sebelah kanan (misal: tombol hapus teks)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Hapus teks di search bar
          showSuggestions(context); // Tampilkan ulang saran
        },
      ),
    ];
  }

  // Tombol di sebelah kiri (misal: tombol kembali)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Tutup halaman pencarian
      },
    );
  }

  // Tampilan yang muncul saat pengguna menekan "enter" atau "search"
  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Ketik judul buku untuk mencari.'));
    }

    return FutureBuilder<List<ProductModel>>(
      future: productService.searchProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan saat mencari.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Buku dengan judul "$query" tidak ditemukan.'));
        }

        final results = snapshot.data!;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final book = results[index];
            return ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: book.imageBase64.isNotEmpty
                    ? Image.memory(base64Decode(book.imageBase64), fit: BoxFit.cover)
                    : const Icon(Icons.book),
              ),
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () {
                close(context, book); // Tutup search dan kirim hasil
                Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailPage(product: book)));
              },
            );
          },
        );
      },
    );
  }

  // Tampilan yang muncul saat pengguna mengetik
  @override
  Widget buildSuggestions(BuildContext context) {
    // Kita bisa buat agar hasil langsung muncul saat mengetik
    return buildResults(context);
  }
}