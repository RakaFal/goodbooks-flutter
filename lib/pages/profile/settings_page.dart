import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/pages/login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/login/ResetPasswordPage.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Fungsi untuk konfirmasi dan proses logout
  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Tampilkan dialog konfirmasi untuk keamanan
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun Anda?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    // Jika pengguna menekan "Logout" pada dialog
    if (confirm == true) {
      await authProvider.logout();
      
      // Arahkan ke halaman login dan hapus semua halaman sebelumnya
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        // Tombol kembali akan muncul otomatis, kita hanya perlu warnanya
        iconTheme: const IconThemeData(color: Color.fromRGBO(54, 105, 201, 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Grup Pengaturan Akun
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Ganti Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordPage()));
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Grup Pengaturan Lainnya (Contoh)
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Lainnya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          ),
           Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () { /* TODO: Navigasi ke halaman notifikasi */ },
                ),
                 const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Tentang Aplikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () { /* TODO: Navigasi ke halaman tentang aplikasi */ },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}