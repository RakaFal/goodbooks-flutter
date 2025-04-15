import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/banner_models.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/category_models.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/base/navbar.dart';
import 'package:goodbooks_flutter/pages/BookDetail.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<CategoryModels> categories;
  late List<BannerModel> banners;
  List<ProductModel> bestproduct = [];
  List<ProductModel> bestsellerProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    categories = CategoryModels.getCategories(); 
    banners = BannerModel.getBanners();
    _loadProducts(); 
    _checkLoginStatus();
  }
    
Future<void> _loadProducts() async {
  try {
    final productService = ProductService();
    final results = await Future.wait([
      productService.getProducts(),
      productService.getBestsellers(), 
    ]);

    if (mounted) {
      setState(() {
        bestproduct = results[0];
        bestsellerProducts = results[1];
        isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() => isLoading = false);
    }
    debugPrint('Error loading products: $e');
    
    // Tampilkan error ke user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal memuat data: ${e.toString()}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

  void _checkLoginStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();
      if (!authProvider.isLoggedIn && mounted) {
        _showLoginDialog();
      }
    } catch (e) {
      debugPrint('Login check error: $e');
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginDialog(
        onLoginPressed: (context) {
          Navigator.of(context).pop();
          _navigateToLoginPage();
        },
      ),
    );
  }

  void _navigateToLoginPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    
    if (result == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NavBar()),
        (route) => false,
      );
    }
  }

  Future<void> _navigateToDetail(ProductModel product) async {
    if (!mounted) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailPage(
          bookId: product.id,
          bookTitle: product.title,
          author: product.author,
          coverImage: product.imagePath,
          rating: product.rating,
          pageCount: product.pageCount,
          genre: product.genre,
          publisher: product.publisher,
          publishedDate: product.publishedDate,
          description: product.description,
          isPurchased: product.isPurchased,
          price: product.price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
    );
  }

  Widget _bestProductList() {
    if (isLoading) {
      return _buildLoadingIndicator(); // Show loading indicator while fetching data
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Best Products',
            style: TextStyle(
              color: Color.fromRGBO(12, 26, 48, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: bestproduct.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 0, 
                  right: 16,
                  bottom: 16,
                ),
                child: _buildProductItem(bestproduct[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _bestSellerProductList() {
    if (isLoading) {
      return _buildLoadingIndicator();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Best Seller',
            style: TextStyle(
              color: Color.fromRGBO(12, 26, 48, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: bestsellerProducts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 0,
                  right: 16,
                  bottom: 16,
                ),
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
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        return SizedBox(
          width: 160,
          height: 260,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _navigateToDetail(product),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: SizedBox(
                          height: 165,
                          width: double.infinity,
                          child: Image.asset(
                            product.imagePath,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.book, size: 40),
                            ),
                          ),
                        ),
                      ),

                      // Text Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product.isBestseller ?? false)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[700],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'BESTSELLER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                            // Book Title
                            SizedBox(
                              height: 30,
                              child: Text(
                                product.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  height: 1.0,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 1),

                            // Author
                            Text(
                              product.author,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),

                            // Price and Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Rp${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Color(0xFFFE3A30),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, 
                                      color: Colors.amber, 
                                      size: 10),
                                    const SizedBox(width: 1),
                                    Text(
                                      product.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Wishlist Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        wishlistProvider.isInWishlist(product.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: wishlistProvider.isInWishlist(product.id)
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                      iconSize: 24,
                      onPressed: () {
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
    if (banners.isEmpty) {
      return _buildBannerPlaceholder(); 
    }

    banners.shuffle(Random()); 
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: banners.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildBannerItem(banners[index]);
        },
      ),
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
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
        child: Image.asset(
          banner.imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: 600,
          cacheHeight: 300,
          errorBuilder: (context, error, stackTrace) => _buildBannerPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildBannerPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
      ),
    );
  }

  Column _categorylist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Genres',
            style: TextStyle(
              color: Color.fromRGBO(12, 26, 48, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            physics: BouncingScrollPhysics(), 
            separatorBuilder: (context, index) => const SizedBox(width: 32),
            itemBuilder: (context, index) {
              final hslColor = HSLColor.fromColor(categories[index].boxColor);
              final iconColor = hslColor.withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0)).toColor();

              return Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: categories[index].boxColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            CategoryModels.getIconData(categories[index].iconName),
                            size: 35,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    categories[index].name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(12, 26, 48, 1),
                      fontSize: 14
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Container _searchField() {
    return Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.0,
                blurRadius: 40,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(250, 250, 250, 1),
              hintText: 'Search for books',
              hintStyle: TextStyle(
                color: Color.fromRGBO(196, 197, 196, 1),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.all(15),
              suffixIcon: SizedBox(
                width: 100,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      VerticalDivider(
                        color: Color.fromRGBO(250, 250, 250, 1),
                        thickness: 0.2,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none
            ),
          ),
        ),
    );
  }
}