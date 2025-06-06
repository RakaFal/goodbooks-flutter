import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/provider/seller_product_provider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedGenre;
  final List<String> _genres = ['Fiksi', 'Non-Fiksi', 'Komik', 'Edukasi', 'Lainnya'];
  final ImagePicker _picker = ImagePicker();
  XFile? _coverImage; // ✅ Gunakan XFile untuk menyimpan hasil pick image
  late ProductService productService;

  String? _coverPath;

  @override
  void initState() {
    super.initState();
    productService = ProductService();
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverPath = image.path;
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState?.validate() == true && _coverImage != null) {
      try {
        // Upload gambar ke Supabase Storage
        final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = _coverImage!.path;

        final imageUrl = await productService.uploadImageToSupabase(imagePath, fileName);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal mengunggah gambar")),
          );
          return;
        }

        // Buat produk baru dengan URL gambar
        final newBook = ProductModel(
          imagePath: imageUrl,
          title: _titleController.text,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          price: double.tryParse(_priceController.text) ?? 0.0,
          rating: 0.0,
          reviews: 0,
          author: _authorController.text,
          pageCount: 0,
          genre: _selectedGenre ?? 'Lainnya',
          publisher: '',
          publishedDate: '',
          description: '',
          isBestseller: false,
          isPurchased: false,
        );

        // Simpan produk ke database Supabase
        await productService.addProduct(newBook);

        // Simpan juga ke provider lokal
        context.read<SellerProductProvider>().addProduct(newBook);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Buku berhasil ditambahkan")),
        );

        Navigator.pop(context);
      } catch (e) {
        debugPrint('Error saat submit form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan buku: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Buku")),
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
                  ),
                  child: _coverPath != null
                      ? Image.file(File(_coverPath!))
                      : const Center(child: Icon(Icons.image, size: 80)),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Judul Buku"),
                validator: (value) => value?.isEmpty ?? true ? 'Judul harus diisi' : null,
              ),

              const SizedBox(height: 10),

              // Author
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: "Penulis"),
                validator: (value) => value?.isEmpty ?? true ? 'Penulis harus diisi' : null,
              ),

              const SizedBox(height: 10),

              // Genre
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                items: _genres.map((genre) {
                  return DropdownMenuItem(value: genre, child: Text(genre));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGenre = value);
                },
                decoration: const InputDecoration(labelText: "Genre"),
                validator: (value) => value == null ? 'Pilih salah satu genre' : null,
              ),

              const SizedBox(height: 10),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga (Rp)"),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga harus diisi';
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Masukkan harga valid';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () => _submitForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(54, 105, 201, 1),
                ),
                child: const Text("Simpan", 
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