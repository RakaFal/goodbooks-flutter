import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Added for the burger icon
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart'; // Added for drawer functionality
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart'; // Added for drawer functionality
import 'package:goodbooks_flutter/pages/Wishlist.dart'; // Added for drawer navigation
import 'package:goodbooks_flutter/pages/home.dart'; // Added for drawer navigation
import 'package:goodbooks_flutter/pages/profile/profile.dart'; // Added for drawer navigation
import 'package:goodbooks_flutter/provider/AuthProvider.dart'; // Added for drawer
import 'package:provider/provider.dart'; // Added for AuthProvider
import '../data/dummy_data.dart'; // pastikan path ini sesuai dengan tempat kamu menyimpan dummyProducts
// Assuming ProductModel is defined in dummy_data.dart or accessible elsewhere
// If not, you might need: import 'package:goodbooks_flutter/models/product_models.dart';

class LibraryPage extends StatefulWidget { // Changed to StatefulWidget to use _scaffoldKey and _buildDrawer
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Copied _showLoginDialog from WishlistPage for drawer functionality
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

  // Copied _buildDrawer from WishlistPage
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.grey),
            title: const Text('Wishlist'),
            onTap: () {
              if (!authProvider.isLoggedIn) {
                _showLoginDialog(context);
                return;
              }
              Navigator.pop(context);
              Navigator.pushReplacement( // Or push, depending on desired stack behavior
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Colors.grey),
            title: const Text('Library'),
            onTap: () {
              Navigator.pop(context); // Already on Library page
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
                Navigator.pop(context);
                await authProvider.logout();
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
    // Ambil hanya buku yang sudah dibeli
    final purchasedBooks =
        dummyProducts.where((book) => book.isPurchased).toList();
    final authProvider = Provider.of<AuthProvider>(context); // For the drawer

    return Scaffold(
      key: _scaffoldKey, // Added key
      appBar: AppBar( // Added AppBar
        title: const Text(
          "Library",
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // To match other pages
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/menu-svgrepo-com.svg', // Make sure this asset exists
            height: 30,
            width: 30,
            colorFilter: const ColorFilter.mode(
              Color.fromRGBO(54, 105, 201, 1),
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildDrawer(context, authProvider), // Added Drawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: purchasedBooks.isEmpty
            ? const Center(
                child: Column( // Added for better empty state presentation
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_library_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No books purchased yet.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Explore and find your next read!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.57, // You might want to adjust this for optimal display
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: purchasedBooks.length,
                itemBuilder: (context, index) {
                  final book = purchasedBooks[index];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      // constraints: const BoxConstraints(maxHeight: 350), // Can be removed if childAspectRatio controls height
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.min, // Removed to allow Spacer to work better
                        children: [
                          Container(
                            height: 160, // Consider making this flexible or based on aspect ratio
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                book.imagePath, // Ensure this path is correct
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.book, size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox( // Wrapped title in SizedBox for better height control if needed
                            height: 40, // Fixed height for title area
                            child: Text(
                              book.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(), // Pushes the "Purchased" text to the bottom
                          Padding(
                            padding: const EdgeInsets.only(top: 8), // Ensure some space if Spacer isn't enough
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Purchased',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
