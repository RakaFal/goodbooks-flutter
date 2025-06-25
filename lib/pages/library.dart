import 'dart:convert'; // BARU: Untuk Base64
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goodbooks_flutter/base/navbar.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart'; 
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<ProductModel>>? _purchasedBooksFuture;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk memuat data saat halaman pertama kali dibuka
    // Diletakkan di didChangeDependencies agar context bisa diakses dengan aman
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Muat data hanya jika future belum diinisialisasi
    if (_purchasedBooksFuture == null) {
      _loadPurchasedBooks();
    }
  }

  // BARU: Fungsi untuk mengambil data buku yang sudah dibeli dari Firestore
  void _loadPurchasedBooks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null && userId.isNotEmpty) {
      setState(() {
        _purchasedBooksFuture = _productService.getPurchasedBooks(userId);
      });
    }
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

  // BARU: Widget untuk ditampilkan jika pengguna belum login
  Widget _buildLoginPrompt() {
    // Anda bisa menggunakan widget login prompt yang sama dari WishlistPage
    return const Center(child: Text("Silakan login untuk melihat Library Anda."));
  }

  // BARU: Widget untuk ditampilkan jika library kosong
  Widget _buildEmptyLibrary() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_library_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Library Anda Kosong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Buku yang sudah Anda beli akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
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
    final authProvider = Provider.of<AuthProvider>(context);

    // Hapus AppBar dan Drawer dari sini jika sudah dikelola oleh NavBar
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1), fontWeight: FontWeight.bold, fontSize: 25)),
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
      ),
      drawer: _buildDrawer(context, authProvider),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !authProvider.isLoggedIn
            ? _buildLoginPrompt()
            : FutureBuilder<List<ProductModel>>(
                future: _purchasedBooksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyLibrary();
                  }

                  final purchasedBooks = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: purchasedBooks.length,
                    itemBuilder: (context, index) {
                      final book = purchasedBooks[index];
                      return Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                color: Colors.grey[200],
                                // DIUBAH: Tampilkan gambar dari Base64
                                child: book.imageBase64.isNotEmpty
                                    ? Image.memory(
                                        base64Decode(book.imageBase64),
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.book, size: 50, color: Colors.grey),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // TODO: Arahkan ke halaman pembaca buku (reader)
                                        },
                                        child: const Text('Baca'),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}