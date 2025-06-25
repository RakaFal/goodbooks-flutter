import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';


class EditProductPage extends StatefulWidget {
  // BARU: Menerima produk yang akan diedit
  final ProductModel product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  
  // DIUBAH: Controller sekarang akan diinisialisasi di initState
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _pageCountController;
  
  String? _selectedGenre;
  final List<String> _genres = ['Fiksi', 'Non-Fiksi', 'Komik', 'Edukasi', 'Horror', 'Romance', 'Fantasy', 'Misteri', 'Lainnya'];
  
  // DIUBAH: Pisahkan antara gambar baru dan gambar lama
  File? _newImageFile; // Untuk menampung file gambar BARU yang dipilih
  String? _existingImageBase64; // Untuk menampung data Base64 LAMA
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // BARU: Isi semua form dengan data dari produk yang dilewatkan
    _titleController = TextEditingController(text: widget.product.title);
    _authorController = TextEditingController(text: widget.product.author);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toStringAsFixed(0));
    _pageCountController = TextEditingController(text: widget.product.pageCount.toString());
    _selectedGenre = widget.product.genre;
    _existingImageBase64 = widget.product.imageBase64;
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (image != null) {
      setState(() {
        _newImageFile = File(image.path); // Simpan gambar baru yang dipilih
      });
    }
  }

  // DIUBAH: Logika submit form menjadi untuk UPDATE
  Future<void> _updateForm() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      String imageBase64;

      // Cek apakah ada gambar baru yang dipilih
      if (_newImageFile != null) {
        // Jika ada, encode gambar baru
        final imageBytes = await _newImageFile!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      } else {
        // Jika tidak, gunakan gambar lama yang sudah ada
        imageBase64 = _existingImageBase64 ?? '';
      }

      // Buat objek produk yang sudah diperbarui
      final updatedBook = ProductModel(
        id: widget.product.id, // Gunakan ID yang sudah ada
        imageBase64: imageBase64,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        genre: _selectedGenre ?? 'Lainnya',
        sellerId: widget.product.sellerId, // Gunakan sellerId yang sudah ada
        // Field lain bisa di-hardcode atau dibuatkan form inputnya juga
        rating: widget.product.rating,
        reviews: widget.product.reviews,
        pageCount: int.tryParse(_pageCountController.text) ?? 0,
        publisher: widget.product.publisher,
        publishedDate: widget.product.publishedDate,
        isBestseller: widget.product.isBestseller,
        isPurchased: widget.product.isPurchased,
      );

      // Lakukan UPDATE ke dokumen yang sudah ada
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id) 
          .update(updatedBook.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Buku berhasil diperbarui")),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      debugPrint('Error saat update form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui buku: $e")),
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
        title: const Text("Edit Produk Buku", style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1), fontWeight: FontWeight.bold)),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // DIUBAH: Logika untuk menampilkan preview gambar
                    child: _newImageFile != null
                        // 1. Jika ada gambar baru, tampilkan gambar baru
                        ? Image.file(_newImageFile!, fit: BoxFit.cover)
                        // 2. Jika tidak, tampilkan gambar lama dari Base64
                        : (_existingImageBase64?.isNotEmpty == true
                            ? Image.memory(base64Decode(_existingImageBase64!), fit: BoxFit.cover)
                            // 3. Jika tidak ada sama sekali, tampilkan ikon
                            : const Center(child: Icon(Icons.image, size: 80))),
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
                onPressed: _isLoading ? null : _updateForm,
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