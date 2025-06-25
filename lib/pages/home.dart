import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/banner_models.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/category_models.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/book_detail.dart';
import 'package:goodbooks_flutter/pages/search/book_search_delegate.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goodbooks_flutter/base/navbar.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // DIUBAH: Inisialisasi semua list sebagai list kosong.
  List<CategoryModel> categories = [];
  List<BannerModel> banners = [];
  List<ProductModel> bestproduct = [];
  List<ProductModel> bestsellerProducts = [];
  bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // DIUBAH: Panggil satu fungsi saja untuk memuat semua data dari Firestore.
    _loadAllData();
  }

  // Ganti nama fungsi dari _loadProducts menjadi _loadAllData
  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final productService = ProductService();
      // Panggil semua fungsi fetch secara bersamaan untuk efisiensi
      final results = await Future.wait([
        productService.getBanners(),
        productService.getCategories(),
        productService.getProducts(),
        productService.getBestsellers(),
      ]);
      
      if (mounted) {
        setState(() {
          banners = results[0] as List<BannerModel>;
          categories = results[1] as List<CategoryModel>;
          bestproduct = results[2] as List<ProductModel>;
          bestsellerProducts = results[3] as List<ProductModel>;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(authProvider),
          drawer: _buildDrawer(context, authProvider),
          body: RefreshIndicator(
            onRefresh: _loadAllData, // Tambahkan fitur pull-to-refresh
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _searchField(),
                    const SizedBox(height: 20),
                    _buildBannerSlider(),
                    const SizedBox(height: 20),
                    _categorylist(),
                    const SizedBox(height: 20),
                    _bestProductList(),
                    const SizedBox(height: 20),
                    _bestSellerProductList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(AuthProvider authProvider) {
    return AppBar(
      title: const Text(
        "GoodBooks",
        style: TextStyle(
          color: Color.fromRGBO(54, 105, 201, 1),
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/menu-svgrepo-com.svg',
          height: 30,
          width: 30,
          colorFilter: const ColorFilter.mode(
            Color.fromRGBO(54, 105, 201, 1),
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              color: const Color.fromRGBO(54, 105, 201, 1),
              onPressed: () {
                if (!authProvider.isLoggedIn) {
                  _showLoginDialog(context);
                }
                // TODO: Implement navigation to chat page
              },
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/shopping-cart-svgrepo-com.svg',
                height: 30,
                width: 30,
                colorFilter: const ColorFilter.mode(
                  Color.fromRGBO(54, 105, 201, 1),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                if (!authProvider.isLoggedIn) {
                  _showLoginDialog(context);
                }
                // TODO: Implement navigation to cart page
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _bestProductList() {
    if (isLoading && bestproduct.isEmpty) return _buildLoadingIndicator();
    if (bestproduct.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text("Produk terbaik belum tersedia.")),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Best Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bestproduct.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 16, bottom: 16),
                child: _buildProductItem(bestproduct[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _bestSellerProductList() {
    if (isLoading && bestsellerProducts.isEmpty) return _buildLoadingIndicator();
    if (bestsellerProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text("Produk bestseller belum tersedia.")),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Best Seller', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bestsellerProducts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 16, bottom: 16),
                child: _buildProductItem(bestsellerProducts[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        return SizedBox(
          width: 160,
          // Sedikit menambah tinggi kartu untuk memberi ruang
          height: 270, 
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailPage(product: product)),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bagian Gambar
                      SizedBox(
                        height: 165,
                        width: double.infinity,
                        child: product.imageBase64.isNotEmpty
                            ? Image.memory(
                                base64Decode(product.imageBase64),
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.book, color: Colors.grey),
                              ),
                      ),
                      // Bagian Teks
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              const Spacer(), // Pendorong ke bawah
                              // BARU: Harga dan Rating dalam satu baris
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Harga di Kiri
                                  Text(
                                    'Rp${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  // Rating di Kanan
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text(
                                        product.rating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
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
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        wishlistProvider.isInWishlist(product.id) ? Icons.favorite : Icons.favorite_border,
                        color: wishlistProvider.isInWishlist(product.id) ? Colors.red : Colors.grey[600],
                      ),
                      onPressed: () {
                        if (!authProvider.isLoggedIn) {
                          _showLoginDialog(context);
                          return;
                        }
                        wishlistProvider.toggleWishlist(product);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerSlider() {
    if (isLoading && banners.isEmpty) return Container(height: 200, child: _buildLoadingIndicator());
    if (banners.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return _buildBannerItem(banners[index]);
        },
      ),
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // DIUBAH: Logika untuk menampilkan gambar banner dari Base64
        child: banner.imageBase64.isNotEmpty
            ? Image.memory(
                base64Decode(banner.imageBase64),
                fit: BoxFit.cover,
                gaplessPlayback: true, // Mencegah gambar berkedip saat dimuat
                errorBuilder: (context, error, stackTrace) => _buildBannerPlaceholder(),
              )
            : _buildBannerPlaceholder(), // Tampilkan placeholder jika data kosong
      ),
    );
  }

  Widget _buildBannerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: const Center(child: Icon(Icons.image_search, size: 50, color: Colors.grey)), 
    );
  }

  Widget _categorylist() {
    // Pengecekan loading dan data kosong sudah benar
    if (isLoading && categories.isEmpty) return _buildLoadingIndicator();
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Genres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: category.boxColor, 
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      CategoryModel.getIconData(category.iconName),
                      size: 35,
                      color: Colors.white, 
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          // Panggil SearchDelegate saat area pencarian ditekan
          showSearch(
            context: context,
            delegate: BookSearchDelegate(),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 10),
              Text('Search for books', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
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
            selected: true,
            selectedTileColor: Colors.blue[50],
            title: const Text('Home'),
            onTap: () => Navigator.pop(context), // Cukup tutup drawer
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Wishlist'),
            onTap: () => authProvider.isLoggedIn ? navigateTo(1) : _showLoginDialog(context), // Ke Wishlist
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
