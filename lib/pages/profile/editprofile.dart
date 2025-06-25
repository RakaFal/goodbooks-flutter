import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/pages/login/ResetPasswordPage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _newImageFile;
  bool _isLoading = false;
  bool _isPhotoRemoved = false;

  
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.user?.name ?? 'John Doe');
    _emailController = TextEditingController(text: authProvider.user?.email ?? 'johndoe@example.com');
    _phoneController = TextEditingController(text: authProvider.user?.phone ?? '+6281234567890');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleProfileImageTap() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool hasExistingImage = authProvider.user?.profileImageBase64.isNotEmpty ?? false;

    // Jika pengguna sudah punya foto (dan foto itu tidak ditandai untuk dihapus), tampilkan opsi
    if (hasExistingImage && !_isPhotoRemoved) {
      _showImageOptions();
    } else {
      // Jika tidak punya foto, langsung buka galeri
      _pickImage();
    }
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color.fromRGBO(54, 105, 201, 1)),
                title: const Text('Pilih dari Galeri', style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1), fontWeight: FontWeight.bold)),
                onTap: () {
                  _pickImage();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Foto', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  setState(() {
                    _newImageFile = null;
                    _isPhotoRemoved = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Kompresi gambar untuk memperkecil ukuran
    );
    
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final int fileSizeInBytes = await imageFile.length();
    const int maxSizeInBytes = 700 * 1024; // Batas aman 700 KB

    if (fileSizeInBytes > maxSizeInBytes) {
      // Tampilkan dialog peringatan jika gambar terlalu besar
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ukuran Gambar Terlalu Besar"),
            content: Text("Ukuran maksimal adalah 700 KB. Ukuran gambar Anda adalah ${(fileSizeInBytes / 1024).toStringAsFixed(1)} KB."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Mengerti"),
              ),
            ],
          ),
        );
      }
      // Jangan proses gambar, biarkan preview tetap gambar lama/default
    } else {
      // Jika ukuran aman, perbarui state untuk menampilkan preview
      setState(() {
        _newImageFile = imageFile;
        _isPhotoRemoved = false;
      });
    }
  }

  // DIUBAH TOTAL: Logika penyimpanan sekarang terpusat di sini
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Mulai dengan gambar lama sebagai default
    String? finalImageBase64 = authProvider.user?.profileImageBase64;

    try {
      if (_isPhotoRemoved) {
        // Jika user memilih hapus, kirim string kosong
        finalImageBase64 = '';
      } else if (_newImageFile != null) {
        // Jika ya, encode gambar baru tersebut menjadi string Base64
        final imageBytes = await _newImageFile!.readAsBytes();
        finalImageBase64 = base64Encode(imageBytes);
      } else {
        // Jika tidak ada perubahan, gunakan gambar lama
        finalImageBase64 = authProvider.user?.profileImageBase64;
      }

      // 2. Panggil updateUserProfile satu kali dengan semua data final
      await authProvider.updateUserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageBase64: finalImageBase64, // Kirim Base64 baru atau lama
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context); // Kembali ke halaman profil
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan profil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(54, 105, 201, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color.fromRGBO(54, 105, 201, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: _handleProfileImageTap, 
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _isPhotoRemoved
                              ? const AssetImage('assets/images/download.png') as ImageProvider 
                              : (_newImageFile != null
                                  ? FileImage(_newImageFile!)
                                  : (authProvider.user?.profileImageBase64.isNotEmpty == true
                                      ? MemoryImage(base64Decode(authProvider.user!.profileImageBase64))
                                      : const AssetImage('assets/images/download.png')
                                    ) as ImageProvider),
                          ),
                          Container(
                            decoration: BoxDecoration(color: Color.fromRGBO(54, 105, 201, 1), borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, validator: (v) => v!.isEmpty ? 'Email tidak boleh kosong' : null),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined, validator: (v) => v!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null),
                    const SizedBox(height: 40),
                    if (authProvider.isLoggedIn)
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage())),
                        child: const Text('Change Password', style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1), fontSize: 16)),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      validator: validator,
    );
  }
}
