import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/banner_models.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/category_models.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/BookDetail.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goodbooks_flutter/theme/apptheme.dart';
// Import NavBar - Ensure this path points to your modified NavBar that accepts initialIndex
import 'package:goodbooks_flutter/base/navbar.dart'; 

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    categories = CategoryModels.getCategories();
    banners = BannerModel.getBanners();
    _loadProducts();
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
        if (context.mounted) { 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
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
          ),
          drawer: _buildDrawer(context, authProvider),
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
      },
    );
  }

  Widget _bestProductList() {
    if (isLoading) return _buildLoadingIndicator();
    if (bestproduct.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text("No best products available at the moment.")),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
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
    if (isLoading) return _buildLoadingIndicator();
    if (bestsellerProducts.isEmpty) {
       return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text("No bestseller products available at the moment.")),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
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
          height: 260, 
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
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
                    isBestseller: product.isBestseller,
                    isPurchased: product.isPurchased,
                    price: product.price,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: SizedBox(
                          height: 165,
                          width: double.infinity,
                          child: Image.asset(
                            product.imagePath, 
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200], child: const Icon(Icons.book, color: Colors.grey)),
                          ),
                        ),
                      ),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                height: 1.2, 
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              product.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                            const SizedBox(height: 3),
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
                                    const Icon(Icons.star, size: 10, color: Colors.amber),
                                    const SizedBox(width: 1),
                                    Text(
                                      product.rating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      padding: EdgeInsets.zero, 
                      constraints: const BoxConstraints(), 
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
        child: Image.asset(
          banner.imagePath, 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildBannerPlaceholder(),
        ),
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

  Column _categorylist() {
    if (categories.isEmpty) return Column(children: const [SizedBox.shrink()]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
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
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 20), 
            separatorBuilder: (context, index) => const SizedBox(width: 16), 
            itemBuilder: (context, index) {
              final category = categories[index];
              // Reverted iconColor logic to your original implementation
              final hslColor = HSLColor.fromColor(category.boxColor);
              final iconColor = hslColor.withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0)).toColor();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: category.boxColor,
                      borderRadius: BorderRadius.circular(16),
                       boxShadow: [ 
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      CategoryModels.getIconData(category.iconName),
                      size: 35,
                      color: iconColor, // Using the reverted iconColor
                    ),
                  ),
                  const SizedBox(height: 8), 
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(12, 26, 48, 1),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), 
            blurRadius: 10, 
            offset: const Offset(0, 2), 
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white, 
          hintText: 'Search for books',
          hintStyle: const TextStyle(
            color: Color.fromRGBO(196, 197, 196, 1),
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
          prefixIcon: const Padding( 
            padding: EdgeInsets.only(left: 15.0, right: 10.0),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5), 
          ),
        ),
         onSubmitted: (value) {
          debugPrint('Searching for: $value');
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(54, 105, 201, 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color.fromRGBO(54, 105, 201, 1),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  authProvider.isLoggedIn ? authProvider.user?.name ?? 'User' : 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authProvider.isLoggedIn ? authProvider.user?.email ?? 'No email' : 'Not logged in',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.grey),
            selectedTileColor: Colors.blue[50],
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); 
              // Navigate to NavBar, showing the Home tab (index 0)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavBar(initialIndex: 0)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border, color: Colors.grey),
            selectedTileColor: Colors.blue[50],
            title: const Text('Wishlist'),
            onTap: () {
              Navigator.pop(context); 
              if (!authProvider.isLoggedIn) {
                _showLoginDialog(context);
                return;
              }
              // Navigate to NavBar, showing the Wishlist tab (index 1)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavBar(initialIndex: 1)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined, color: Colors.grey),
            selectedTileColor: Colors.blue[50],
            title: const Text('Library'),
            onTap: () {
              Navigator.pop(context); 
              if (!authProvider.isLoggedIn) {
                _showLoginDialog(context);
                return;
              }
              // Navigate to NavBar, showing the Library tab (index 2)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavBar(initialIndex: 2)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.grey),
            selectedTileColor: Colors.blue[50],
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); 
              if (!authProvider.isLoggedIn) {
                _showLoginDialog(context);
                return;
              }
              // Navigate to NavBar, showing the Profile tab (index 3)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavBar(initialIndex: 3)),
              );
            },
          ),
          const Divider(),
          if (authProvider.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); 
                await Provider.of<AuthProvider>(context, listen: false).logout();
                if(mounted){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                     (route) => false,
                  );
                }
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
