import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/base/NavBar.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfilePasswordPage extends StatefulWidget {
  // Halaman ini tidak lagi memerlukan parameter karena akan mengambil data dari AuthProvider
  const ProfilePasswordPage({super.key});

  @override
  _ProfilePasswordPageState createState() => _ProfilePasswordPageState();
}

class _ProfilePasswordPageState extends State<ProfilePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  // DIUBAH: Inisialisasi controller secara langsung untuk menghindari LateError.
  final TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // listen: false karena kita hanya butuh data sekali saat inisialisasi.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // DIUBAH: Tetapkan nilai `.text` dari controller yang sudah ada,
    // bukan membuat instance baru.
    nameController.text = authProvider.user?.name ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan profil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Pengguna tidak ditemukan. Silakan coba lagi.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Panggil fungsi updateUserProfile yang sudah ada di AuthProvider
      await authProvider.updateUserProfile(
        name: nameController.text.trim(),
        email: currentUser.email, // email tetap (jika ada)
        phone: currentUser.phone, // nomor telepon tetap
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil disimpan!")),
      );

      // Arahkan ke halaman utama aplikasi dan hapus semua halaman sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavBar()),
        (Route<dynamic> route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan profil: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {}, // Sebaiknya dinonaktifkan agar user tidak kembali ke verifikasi
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Satu Langkah Lagi!",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Konfirmasi nama lengkap Anda untuk masuk ke aplikasi GoodBooks.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Full Name Input
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nama lengkap tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(54, 105, 201, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        "Simpan & Masuk",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}