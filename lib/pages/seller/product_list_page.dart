import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/pages/seller/add_product_page.dart';
import 'package:goodbooks_flutter/pages/seller/edit_product_page.dart';

// DIUBAH: Menjadi StatefulWidget untuk mengelola state data dan refresh
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // Gunakan Future untuk menampung proses pengambilan data
  late Future<List<ProductModel>> _sellerProductsFuture;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Fungsi untuk mengambil data produk milik seller
  void _loadProducts() {
    // listen: false karena kita hanya butuh data userId sekali di sini
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sellerId = authProvider.user?.id; 

    if (sellerId != null) {
      setState(() {
        _sellerProductsFuture = _productService.getProductsBySeller(sellerId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Produk Anda",
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // BARU: Untuk menengahkan judul
        // BARU: Untuk mengubah warna ikon panah kembali
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(54, 105, 201, 1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Color.fromRGBO(54, 105, 201, 1),),
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          ).then((_) => _loadProducts());
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: !authProvider.isLoggedIn
              ? const Center(child: Text("Silakan login untuk mengelola produk Anda."))
              : FutureBuilder<List<ProductModel>>(
                  future: _sellerProductsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Anda belum menambahkan buku untuk dijual."));
                    }

                    // Tampilkan daftar produk jika data berhasil dimuat
                    final products = snapshot.data!;
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final book = products[index];
                        return Dismissible(
                          key: Key(book.id), // Kunci unik untuk setiap item
                          direction: DismissDirection.endToStart, // Arah geser dari kanan ke kiri
                          
                          // Widget yang muncul di belakang saat item digeser
                          background: Container(
                            color: Colors.red[700],
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
                          ),
                          
                          // BARU: Logika konfirmasi sebelum item benar-benar hilang dari layar
                          confirmDismiss: (direction) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Produk?'),
                                content: Text('Apakah Anda yakin ingin menghapus "${book.title}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            // Jika user menekan "Hapus" pada dialog
                            if (confirm == true) {
                              try {
                                await _productService.deleteProduct(book.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Produk berhasil dihapus.')),
                                );
                                // Kembalikan true agar item hilang dari layar
                                return true; 
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal menghapus produk: $e')),
                                );
                                // Kembalikan false agar item tidak hilang jika gagal
                                return false; 
                              }
                            }
                            // Jika user menekan "Batal", kembalikan false
                            return false; 
                          },
                          
                          // Setelah konfirmasi dan animasi selesai, refresh daftar produk
                          onDismissed: (direction) {
                             _loadProducts();
                          },

                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: book.imageBase64.isNotEmpty
                                    ? Image.memory(
                                        base64Decode(book.imageBase64),
                                        width: 50,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 40),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.book, size: 40, color: Colors.grey),
                                      ),
                                ),
                              title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${book.author}\nRp${book.price.toStringAsFixed(0)}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Color.fromRGBO(54, 105, 201, 1)),
                                    // DIUBAH: Implementasi navigasi ke halaman Edit Produk
                                    onPressed: () {
                                      // Navigasi ke EditProductPage dengan membawa data 'book'
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditProductPage(product: book),
                                        ),
                                      ).then((_) {
                                        // Setelah kembali dari halaman edit, refresh daftarnya
                                        // untuk menampilkan data yang mungkin sudah berubah.
                                        _loadProducts();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}