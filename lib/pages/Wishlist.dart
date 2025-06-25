import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goodbooks_flutter/base/navbar.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/book_detail.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailPage(product: book))),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5, // Beri lebih banyak ruang untuk gambar
                  child: SizedBox(
                    width: double.infinity,
                    child: book.imageBase64.isNotEmpty
                        ? Image.memory(base64Decode(book.imageBase64), fit: BoxFit.cover, gaplessPlayback: true)
                        : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.book, size: 40, color: Colors.grey))),
                  ),
                ),
                Expanded(
                  flex: 4, // Ruang untuk teks, harga, dan rating
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
                        const SizedBox(height: 2),
                        Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const Spacer(), // Pendorong ke bawah
                        // BARU: Tampilkan rating
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(book.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // BARU: Tampilkan harga
                        Text(
                          'Rp${book.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  wishlistProvider.toggleWishlist(book);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${book.title} dihapus dari wishlist.'), duration: const Duration(seconds: 2)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Wishlist', style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1), fontWeight: FontWeight.bold, fontSize: 25)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/menu-svgrepo-com.svg',
          height: 30,
          width: 30,
          colorFilter: const ColorFilter.mode(Color.fromRGBO(54, 105, 201, 1), BlendMode.srcIn),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    // Navigasi di dalam drawer diubah sedikit agar lebih sesuai dengan konteks NavBar
    void navigateTo(int index) {
      Navigator.pop(context); // Tutup drawer
      // Cara terbaik adalah dengan memberitahu NavBar untuk pindah index
      // Untuk sementara kita gunakan pushReplacement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavBar(initialIndex: index)),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color.fromRGBO(54, 105, 201, 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: authProvider.isLoggedIn && authProvider.user?.profileImageBase64.isNotEmpty == true
                        ? MemoryImage(base64Decode(authProvider.user!.profileImageBase64))
                        : const AssetImage('assets/images/download.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(authProvider.isLoggedIn ? authProvider.user?.name ?? 'User' : 'Guest', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(authProvider.isLoggedIn ? authProvider.user?.email ?? 'Not logged in' : '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => navigateTo(0), // Ke Home
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            selected: true,
            selectedTileColor: Colors.blue[50],
            title: const Text('Wishlist'),
            onTap: () => Navigator.pop(context), // Cukup tutup drawer
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Library'),
            onTap: () => authProvider.isLoggedIn ? navigateTo(2) : _showLoginDialog(context), // Ke Library
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Profile'),
            onTap: () => authProvider.isLoggedIn ? navigateTo(3) : _showLoginDialog(context), // Ke Library
          ),
          const Divider(),
          if (authProvider.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // BARU: Halaman dibungkus dengan Scaffold
        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(),
          drawer: _buildDrawer(context, authProvider), // Sesuaikan dengan drawer Anda
          body: authProvider.isLoggedIn
              ? _buildWishlistContent()
              : _buildLoginPrompt(context),
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
              childAspectRatio: 0.6, // DIUBAH: Sedikit lebih tinggi
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
  
  void _showLoginDialog(BuildContext context) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (dialogContext) => LoginDialog( 
        onLoginPressed: (ctx) { 
          Navigator.pop(ctx); 
          if (mounted) { 
             Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
      ),
    );
  }


}