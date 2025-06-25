import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/profile/editprofile.dart';
import 'package:goodbooks_flutter/pages/profile/settings_page.dart';
import 'package:goodbooks_flutter/base/navbar.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';
import 'wishlist_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSellerMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


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
            onPressed: () => Navigator.of(context).pop(false), // Eksplisit kembalikan false
            child: const Text("Tidak", 
              style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1)),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(54, 105, 201, 1),
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
  
  void _showLoginDialog(BuildContext context) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LoginDialog(
        onLoginPressed: (ctx) {
          Navigator.pop(ctx);
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
          }
        },
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authProvider.logout();
    }
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
            title: const Text('Home'),
            onTap: () => navigateTo(0), // Ke Home
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
            leading: const Icon(Icons.person_outline),
            selected: true, // Menandakan kita sedang di halaman Profile
            selectedTileColor: Colors.blue[50],
            title: const Text('Profile'),
            onTap: () => Navigator.pop(context), // Cukup tutup drawer
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1), fontWeight: FontWeight.bold, fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/menu-svgrepo-com.svg',
            height: 30,
            width: 30,
            colorFilter: const ColorFilter.mode(Color.fromRGBO(54, 105, 201, 1), BlendMode.srcIn),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // Tombol Edit Profile tetap di sini
          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color.fromRGBO(54, 105, 201, 1)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
            ),
          // BARU: Tombol Settings menggantikan menu tiga titik
          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Color.fromRGBO(54, 105, 201, 1), size: 25),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider), // Drawer diletakkan di sini
      body: SingleChildScrollView( // Body diletakkan di sini
        padding: const EdgeInsets.all(20),
        child: authProvider.isLoggedIn ? _buildUserProfile(authProvider) : _buildGuestProfile(context),
      ),
    );
  }

  Widget _buildUserProfile(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: authProvider.user?.profileImageBase64.isNotEmpty == true
                ? MemoryImage(base64Decode(authProvider.user!.profileImageBase64))
                : const AssetImage('assets/images/download.png') as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(authProvider.user?.name ?? 'User', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(authProvider.user?.email ?? 'No email', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 24),
          
          // Daftar Menu Utama
          _buildMenuCard([
            _buildListTile(Icons.edit_outlined, 'Edit Profile', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()))),
            _buildListTile(Icons.history_outlined, 'Order History', () {}),
            _buildListTile(Icons.favorite_outline, 'Wishlist', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()))),
            _buildListTile(Icons.settings_outlined, 'Settings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
          ]),

          const SizedBox(height: 16),

          // Menu Mode Penjual
          _buildMenuCard([
            ListTile(
              leading: Icon(_isSellerMode ? Icons.storefront_outlined : Icons.person_outline, color: Color.fromRGBO(54, 105, 201, 1)),
              title: Text(_isSellerMode ? 'Mode Penjual Aktif' : 'Beralih ke Mode Penjual'),
              trailing: Switch(value: _isSellerMode, onChanged: _toggleSellerMode, activeColor: Color.fromRGBO(54, 105, 201, 1)),
              onTap: () => _toggleSellerMode(!_isSellerMode),
            ),
          ]),

          const SizedBox(height: 16),

          // Menu Logout
          _buildMenuCard([
            _buildListTile(
              Icons.exit_to_app,
              'Logout',
              () => _handleLogout(context),
              color: Colors.red,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/download.png')),
          const SizedBox(height: 20),
          const Text('Guest', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(54, 105, 201, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: const Text('Login / Register'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey.shade400),
      onTap: onTap,
    );
  }
}