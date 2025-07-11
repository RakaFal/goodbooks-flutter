import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert'; 
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _pageCountController = TextEditingController();

  
  String? _selectedGenre;
  final List<String> _genres = ['Fiksi', 'Non-Fiksi', 'Komik', 'Edukasi', 'Horror', 'Romance', 'Fantasy', 'Misteri', 'Lainnya'];
  
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Kompresi gambar untuk memperkecil ukuran
    );
    
    if (image == null) return; // User membatalkan pemilihan

    final imageFile = File(image.path);

    // BARU: Cek ukuran file di sini
    final int fileSizeInBytes = await imageFile.length();
    // Batas aman 700KB (700 * 1024 bytes)
    const int maxSizeInBytes = 700 * 1024; 

    if (fileSizeInBytes > maxSizeInBytes) {
      // JIKA UKURAN TERLALU BESAR:
      // 1. Tampilkan dialog peringatan
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ukuran Gambar Terlalu Besar"),
            content: Text("Ukuran gambar maksimal adalah 700 KB. Ukuran gambar Anda adalah ${(fileSizeInBytes / 1024).toStringAsFixed(1)} KB."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Mengerti"),
              ),
            ],
          ),
        );
      }
      // 2. Jangan proses gambar ini (kosongkan state)
      setState(() {
        _imageFile = null;
      });
    } else {
      // JIKA UKURAN AMAN:
      // Lanjutkan seperti biasa, tampilkan preview gambar
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih gambar sampul buku.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sellerId = authProvider.user?.id;

      if (sellerId == null) {
          // Handle error jika user tidak login
          throw Exception("User not logged in.");
      }

      // 1. Baca file gambar menjadi data biner (bytes)
      final imageBytes = await _imageFile!.readAsBytes();

      // 2. Encode data biner tersebut menjadi string Base64
      final String base64Image = base64Encode(imageBytes);

      // 3. Buat ID unik untuk produk baru
      final newProductId = FirebaseFirestore.instance.collection('products').doc().id;

      // 4. Buat objek ProductModel dengan data dari form dan string Base64
      final newBook = ProductModel(
        id: newProductId,
        imageBase64: base64Image, // Menyimpan string Base64
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        genre: _selectedGenre ?? 'Lainnya',
        rating: 0.0,
        reviews: 0,
        pageCount: int.tryParse(_pageCountController.text) ?? 0, 
        publisher: 'Self-Published',
        publishedDate: DateTime.now().toIso8601String(),
        isBestseller: false,
        isPurchased: false,
        sellerId: sellerId, 
      );

      // 5. Simpan data produk (yang sudah berisi string Base64) ke Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(newProductId)
          .set(newBook.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Buku berhasil ditambahkan")),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      debugPrint('Error saat submit form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan buku: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _pageCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Produk Buku",
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(54, 105, 201, 1)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Cover Image Picker
              GestureDetector(
                onTap: _pickCoverImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  // DIUBAH: Tampilkan gambar dari _imageFile
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Ketuk untuk memilih sampul", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Form fields...
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Judul Buku", border: OutlineInputBorder()),
                validator: (value) => value?.isEmpty ?? true ? 'Judul harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: "Penulis", border: OutlineInputBorder()),
                validator: (value) => value?.isEmpty ?? true ? 'Penulis harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField( // BARU: Form input untuk deskripsi
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi Singkat", border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Deskripsi harus diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                items: _genres.map((genre) {
                  return DropdownMenuItem(value: genre, child: Text(genre));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGenre = value);
                },
                decoration: const InputDecoration(labelText: "Genre", border: OutlineInputBorder()),
                validator: (value) => value == null ? 'Pilih salah satu genre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pageCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Jumlah Halaman", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Jumlah halaman harus diisi';
                  if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(labelText: "Harga (Rp)", border: OutlineInputBorder(), prefixText: 'Rp '),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga harus diisi';
                  if (double.tryParse(value) == null) return 'Masukkan harga valid';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(54, 105, 201, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        "Simpan Produk",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}