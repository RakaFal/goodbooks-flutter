import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goodbooks_flutter/pages/home.dart';
import 'package:goodbooks_flutter/pages/library.dart';
import 'package:goodbooks_flutter/pages/profile/profile.dart';
import '../pages/Wishlist.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      const HomePage(),
      const WishlistPage(),
      const LibraryPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Redirect to login if not authenticated
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          });
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: _buildDrawer(context, authProvider),
          appBar: AppBar(
            title: Text(
              _getTitle(_selectedIndex),
              style: const TextStyle(
                color: Color.fromRGBO(54, 105, 201, 1),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: _selectedIndex == 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/menu-svgrepo-com.svg',
                height: 30,
                width: 30,
                color: const Color.fromRGBO(54, 105, 201, 1),
                colorFilter: const ColorFilter.mode(
                  Color.fromRGBO(54, 105, 201, 1),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            automaticallyImplyLeading: false,
            actions: _getAppBarActions(_selectedIndex, authProvider),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Wishlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            selectedItemColor: const Color.fromRGBO(54, 105, 201, 1),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
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
            leading: const Icon(Icons.home, color: Colors.grey),
            title: const Text('Home'),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
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
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
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
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
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
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          if (authProvider.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Logout'),
              onTap: () async {
                await authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Goodbooks';
      case 1: return 'My Wishlist';
      case 2: return 'Library';
      case 3: return 'Profile';
      default: return '';
    }
  }

  List<Widget> _getAppBarActions(int index, AuthProvider authProvider) {
    if (index == 3) {
      return [
        IconButton(
          icon: const Icon(Icons.logout),
          color: const Color.fromRGBO(54, 105, 201, 1),
          onPressed: () async {
            if (!authProvider.isLoggedIn) {
              _showLoginDialog(context);
              return;
            }
            await authProvider.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ];
    }
    
    return [
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            color: const Color.fromRGBO(54, 105, 201, 1),
            onPressed: () {
              if (!authProvider.isLoggedIn) {
                _showLoginDialog(context);
                return;
              }
              // Proceed with chat feature
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/shopping-cart-svgrepo-com.svg',
              height: 30,
              width: 30,
              color: const Color.fromRGBO(54, 105, 201, 1),
            ),
            onPressed: () {
              if (!authProvider.isLoggedIn) {
                _showLoginDialog(context);
                return;
              }
              // Proceed with cart feature
            },
          ),
        ],
      ),
    ];
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LoginDialog(
        onLoginPressed: (context) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
      ),
    );
  }
}