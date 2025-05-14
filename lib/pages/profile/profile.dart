import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/profile/editprofile.dart';
import '../Wishlist.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                    // Fallback to default image on error
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