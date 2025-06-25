import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/base/navbar.dart'; // BARU: Import untuk navigasi ke NavBar
import 'package:goodbooks_flutter/pages/seller/add_product_page.dart';
import 'package:goodbooks_flutter/pages/seller/product_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // BARU: Import untuk simpan state mode

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  // BARU: Fungsi untuk kembali ke mode pembeli
  Future<void> _switchToBuyerMode(BuildContext context) async {
    // 1. Simpan state bahwa mode penjual sudah tidak aktif
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSellerMode', false);

    // 2. Arahkan pengguna kembali ke NavBar, tepatnya ke halaman Profile (index 3)
    // Pastikan widget masih terpasang (mounted) sebelum navigasi
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavBar(initialIndex: 3)),
        (Route<dynamic> route) => false, // Hapus semua halaman sebelumnya
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // DIUBAH: Tambahkan style pada title
        title: const Text(
          "Seller Home",
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontWeight: FontWeight.bold,
            fontSize: 25
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        
        // BARU: Menambahkan tombol kembali di kiri (leading)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(54, 105, 201, 1)),
          onPressed: () => _switchToBuyerMode(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color.fromRGBO(54, 105, 201, 1)),
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
              _buildMenuTile(
                context,
                icon: Icons.inventory_2_outlined,
                title: "Kelola Produk",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListPage()),
                  );
                },
              ),
              _buildMenuTile(
                context,
                icon: Icons.bar_chart_outlined,
                title: "Statistik Penjualan",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur belum tersedia')));
                },
              ),
              _buildMenuTile(
                context,
                icon: Icons.chat_bubble_outline,
                title: "Pesan Pembeli",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur pesan belum tersedia')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BARU: Helper widget untuk membuat ListTile agar lebih rapi
  Widget _buildMenuTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}