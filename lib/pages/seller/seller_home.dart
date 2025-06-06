import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/pages/seller/add_product_page.dart';
import 'package:goodbooks_flutter/pages/seller/product_list_page.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Home"),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromRGBO(54, 105, 201, 1),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductPage()),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selamat datang, Penjual!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text("Kelola Produk"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart),
                title: const Text("Statistik Penjualan"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Nanti bisa arahkan ke halaman statistik
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur belum tersedia')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text("Pesan Pembeli"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Nanti bisa arahkan ke halaman chat
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur pesan belum tersedia')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}