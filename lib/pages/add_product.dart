import 'package:flutter/material.dart';
import '../models/product_models.dart';

class AddProductPage extends StatefulWidget {
  final Function(ProductModel) onProductAdded;

  const AddProductPage({Key? key, required this.onProductAdded}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _reviewsController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _pageCountController = TextEditingController();
  final TextEditingController _genreController = TextEditingController(); // Optional, bisa dihapus jika tidak perlu
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _publishedDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isBestseller = false;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newProduct = ProductModel(
        imagePath: 'assets/images/default.jpg', // Bisa nanti disesuaikan lewat picker
        title: _titleController.text,
        id: _idController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        rating: double.tryParse(_ratingController.text) ?? 0,
        reviews: int.tryParse(_reviewsController.text) ?? 0,
        author: _authorController.text,
        pageCount: int.tryParse(_pageCountController.text) ?? 0,
        genre: _genreController.text,
        publisher: _publisherController.text,
        publishedDate: _publishedDateController.text,
        description: _descriptionController.text,
        isBestseller: _isBestseller,
      );

      widget.onProductAdded(newProduct);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_titleController, 'Judul Buku'),
              _buildTextField(_idController, 'ID Produk'),
              _buildTextField(_priceController, 'Harga', keyboardType: TextInputType.number),
              _buildTextField(_ratingController, 'Rating', keyboardType: TextInputType.number),
              _buildTextField(_reviewsController, 'Jumlah Review', keyboardType: TextInputType.number),
              _buildTextField(_authorController, 'Penulis'),
              _buildTextField(_pageCountController, 'Jumlah Halaman', keyboardType: TextInputType.number),
              _buildTextField(_genreController, 'Genre'), 
              _buildTextField(_publisherController, 'Penerbit'),
              _buildTextField(_publishedDateController, 'Tahun Terbit'),
              _buildTextField(_descriptionController, 'Deskripsi', maxLines: 4),
              SwitchListTile(
                title: Text('Bestseller'),
                value: _isBestseller,
                onChanged: (value) {
                  setState(() {
                    _isBestseller = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Simpan Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
}
