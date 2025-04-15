import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/profile/editprofile.dart';
import '../Wishlist.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/download.png'),
          ),
          const SizedBox(height: 20),
          Text(
            authProvider.isLoggedIn ? 'John Doe' : 'Guest User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            authProvider.isLoggedIn ? 'johndoe@example.com' : 'Not logged in',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          if (!authProvider.isLoggedIn)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              child: const Text('Login'),
            ),
          if (authProvider.isLoggedIn) ...[
            _buildListTile(
              Icons.edit, 
              'Edit Profile', 
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
            ),
            _buildListTile(Icons.history, 'Order History', () {}),
            _buildListTile(
              Icons.favorite, 
              'Wishlist', 
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              ),
            ),
            _buildListTile(Icons.settings, 'Settings', () {}),
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