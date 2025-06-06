import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/home.dart';
import 'package:goodbooks_flutter/pages/library.dart';
import 'package:goodbooks_flutter/pages/profile/profile.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure the widget is still mounted before accessing context.
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        _showLoginDialog(context);
      } else {
        // Load wishlist data (jika diperlukan)
        // Example: Provider.of<WishlistProvider>(context, listen: false).loadWishlist();
      }
    });
  }

  void _showLoginDialog(BuildContext context) {
    // Ensure the widget is still mounted before showing a dialog.
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginDialog(
        onLoginPressed: (dialogContext) { // Renamed to avoid confusion
          Navigator.pop(dialogContext); // Use dialogContext to pop the dialog
          // Ensure the parent widget is still mounted before pushing a new route.
          if (mounted) {
            Navigator.push(
              context, // Use the original context for navigation
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
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
                    size: 40, // Increased size slightly for better visibility
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
                  authProvider.isLoggedIn ? authProvider.user?.email ?? '' : 'Not logged in',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.grey),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              // Consider using named routes or ensuring HomePage is appropriate here
              Navigator.pushReplacement( // Using pushReplacement if this is a main navigation point
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.grey),
            title: const Text('Wishlist'),
            onTap: () {
              Navigator.pop(context); // Close drawer, already on Wishlist page
            },
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Colors.grey),
            title: const Text('Library'),
            onTap: () {
              if (!authProvider.isLoggedIn) {
                _showLoginDialog(context);
                return;
              }
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LibraryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.grey),
            title: const Text('Profile'),
            onTap: () {
              if (!authProvider.isLoggedIn) {
                _showLoginDialog(context);
                return;
              }
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          const Divider(),
          if (authProvider.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // Close drawer first
                await authProvider.logout();
                // Ensure the widget is still mounted before navigating.
                if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text( // Updated title Text widget
          "Wishlist",
          style: TextStyle( // Added style similar to original NavBar
            color: Color.fromRGBO(54, 105, 201, 1),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        // foregroundColor is not needed if title style has color
        elevation: 0,
        centerTitle: false, // Set to false as per original NavBar logic for non-home pages
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/menu-svgrepo-com.svg',
            height: 30,
            width: 30,
            // Applying color filter to SVG for consistency if needed,
            // or ensure 'color' property works as expected.
            // The 'color' property on SvgPicture.asset might be deprecated or behave differently.
            // Using ColorFilter is more robust for tinting.
            colorFilter: const ColorFilter.mode(
              Color.fromRGBO(54, 105, 201, 1),
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildDrawer(context, authProvider),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: authProvider.isLoggedIn
              ? wishlistProvider.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your wishlist is empty',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7, // Adjust for better item display
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: wishlistProvider.items.length,
                      itemBuilder: (context, index) {
                        final book = wishlistProvider.items[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Book Cover
                                    Container(
                                      height: 150, // Fixed height for consistency
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[200], // Placeholder color
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset( // Assuming imagePath is valid
                                          book.imagePath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Icon(Icons.book, size: 40, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Book Title
                                    Text(
                                      book.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Author
                                    Text(
                                      book.author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(), // Pushes content below to the bottom
                                    // Price and Rating
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rp${book.price.toStringAsFixed(0)}', // Ensure price is formatted
                                          style: const TextStyle(
                                            color: Colors.redAccent, // Slightly different red
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 18, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              book.rating.toStringAsFixed(1),
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Favorite Button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(
                                    wishlistProvider.isInWishlist(book.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: wishlistProvider.isInWishlist(book.id)
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                  iconSize: 24,
                                  onPressed: () {
                                    if (!authProvider.isLoggedIn) {
                                      _showLoginDialog(context);
                                      return;
                                    }
                                    wishlistProvider.toggleWishlist(book);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
              : const Center(child: CircularProgressIndicator()), // Show loader if not logged in and not yet redirected
        ),
      ),
    );
  }
}
