import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/profile/editprofile.dart';
import '../Wishlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodbooks_flutter/pages/seller/seller_home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSellerMode = false;

  @override
  void initState() {
    super.initState();
    _loadSellerMode();
  }

  Future<void> _loadSellerMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSellerMode = prefs.getBool('isSellerMode') ?? false;
    });
  }

  Future<void> _toggleSellerMode(bool value) async {
    if (value && !_isSellerMode) {
      // Tampilkan dialog jika ingin aktifkan mode penjual
      final shouldSwitch = await showSellerDialog(context);
      if (shouldSwitch) {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _isSellerMode = true;
        });
        await prefs.setBool('isSellerMode', true);

        // Navigasi ke SellerHomePage setelah toggle
        Navigator.pushReplacementNamed(context, '/seller-home');
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isSellerMode = false;
      });
      await prefs.setBool('isSellerMode', false);
    }
  }

  Future<bool> showSellerDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Mode Penjual"),
        content: const Text("Apakah Anda yakin ingin beralih ke mode penjual?"),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Tidak"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).pop(true); // Mengembalikan true jika user menekan "Ya"
            },
            child: const Text("Ya, Beralih", 
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Image
          authProvider.isLoggedIn && authProvider.user?.profileImageUrl.isNotEmpty == true
              ? CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(authProvider.user!.profileImageUrl),
                  backgroundColor: Colors.grey[300],
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('Error loading profile image: $exception');
                  },
                )
              : const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/download.png'),
                ),
          const SizedBox(height: 20),
          Text(
            authProvider.isLoggedIn ? authProvider.user?.name ?? 'User' : 'Guest',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            authProvider.isLoggedIn ? authProvider.user?.email ?? 'No email' : 'Not logged in',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (authProvider.isLoggedIn && authProvider.user?.phone != null && authProvider.user!.phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                authProvider.user!.phone,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          const SizedBox(height: 30),

          // Tombol Switch Role
          if (authProvider.isLoggedIn)
            ListTile(
              leading: Icon(_isSellerMode ? Icons.store : Icons.person),
              title: Text(_isSellerMode ? 'Mode Penjual Aktif' : 'Beralih ke Mode Penjual'),
              trailing: Switch(
                value: _isSellerMode,
                onChanged: (value) => _toggleSellerMode(value),
              ),
              onTap: () => _toggleSellerMode(!_isSellerMode),
            ),

          // Tombol lain tetap sama
          if (!authProvider.isLoggedIn)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              child: const Text('Login'),
            ),
          if (authProvider.isLoggedIn) ...[
            _buildListTile(Icons.edit, 'Edit Profile', () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                )),
            _buildListTile(Icons.history, 'Order History', () {}),
            _buildListTile(Icons.favorite, 'Wishlist', () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistPage()),
                )),
            _buildListTile(Icons.settings, 'Settings', () {}),
            _buildListTile(
              Icons.exit_to_app,
              'Logout',
              () async {
                await authProvider.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}