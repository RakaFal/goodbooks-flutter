import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/pages/home.dart';
import 'package:goodbooks_flutter/pages/library.dart';
import 'package:goodbooks_flutter/pages/profile/profile.dart';
import 'package:goodbooks_flutter/pages/Wishlist.dart'; 
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';

class NavBar extends StatefulWidget {
  final int initialIndex; // Tambahkan parameter initialIndex

  const NavBar({
    super.key,
    this.initialIndex = 0, // Default ke 0 (HomePage)
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int _selectedIndex; // Hapus inisialisasi langsung
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Gunakan initialIndex dari widget
    _initializePages();
  }

  void _initializePages() {
    // Pastikan HomePage diimpor dengan benar di sini jika berbeda dari file ini
    _pages = [
      const HomePage(),
      const WishlistPage(),
      const LibraryPage(),
      const ProfilePage(),
    ];
  }

  // Public getter for selectedIndex if needed by other widgets (though Provider is often better)
  // int get selectedIndex => _selectedIndex;

  void _onItemTapped(int index) {
    // Logic untuk menampilkan dialog login jika item memerlukan login bisa ditambahkan di sini
    // Contoh:
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // if ((index == 1 || index == 2 || index == 3) && !authProvider.isLoggedIn) {
    //   _showLoginDialog(context); // Anda perlu method _showLoginDialog di sini jika ingin menggunakannya
    //   return;
    // }
    setState(() {
      _selectedIndex = index;
    });
  }

  // Jika Anda memerlukan _showLoginDialog di NavBar, Anda bisa menambahkannya di sini
  // void _showLoginDialog(BuildContext context) {
  //   showDialog(...);
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped, // Gunakan method _onItemTapped
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
}
