import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/book_detail.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Login Diperlukan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan login untuk melihat dan mengelola wishlist Anda.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(54, 105, 201, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Login Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Wishlist Anda Kosong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk ikon hati pada buku yang Anda sukai untuk menambahkannya ke sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(ProductModel book, WishlistProvider wishlistProvider) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailPage(product: book),
            ),
          );
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: double.infinity,
                    // DIUBAH: Logika untuk menampilkan gambar dari Base64
                    child: book.imageBase64.isNotEmpty
                        ? Image.memory(
                            base64Decode(book.imageBase64), // Decode string
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.book, size: 40, color: Colors.grey),
                            ),
                          )
                        : Container( // Fallback jika string Base64 kosong
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.book, size: 40, color: Colors.grey),
                            ),
                          ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () {
                    wishlistProvider.toggleWishlist(book);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${book.title} dihapus dari wishlist.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Wishlist', style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1), fontWeight: FontWeight.bold, fontSize: 25)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            // DIUBAH: Ikon burger diganti menjadi panah kembali
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(54, 105, 201, 1)),
              onPressed: () => Navigator.of(context).pop(), // Aksi untuk kembali
            ),
          ),
          // DIHAPUS: Properti drawer dihilangkan
          body: authProvider.isLoggedIn ? _buildWishlistContent() : _buildLoginPrompt(context),
        );
      },
    );
  }

  Widget _buildWishlistContent() {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        if (wishlistProvider.items.isEmpty) {
          return _buildEmptyWishlist();
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: wishlistProvider.items.length,
            itemBuilder: (context, index) {
              final book = wishlistProvider.items[index];
              return _buildWishlistItem(book, wishlistProvider);
            },
          ),
        );
      },
    );
  }
}