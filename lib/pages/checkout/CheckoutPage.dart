import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/payment_models.dart'; 
import 'PaymentPage.dart';

class CheckoutPage extends StatefulWidget {
  final ProductModel product;

  const CheckoutPage({Key? key, required this.product}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  DeliveryType _deliveryType = DeliveryType.digital;
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(54, 105, 201, 1),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductSummary(),
            const SizedBox(height: 24),
            const Text('Delivery Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(54, 105, 201, 1))),
            const SizedBox(height: 8),
            _buildDeliveryOptions(),
            const SizedBox(height: 24),
            if (_deliveryType == DeliveryType.physical)
              _buildShippingForm(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(54, 105, 201, 1), // Warna tombol utama
                  foregroundColor: Colors.white, // Warna teks
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _proceedToPayment,
                child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // DIUBAH: Logika disederhanakan untuk hanya menangani Base64
              child: SizedBox(
                width: 80,
                height: 120,
                child: widget.product.imageBase64.isNotEmpty
                    // Tampilkan gambar dari Base64 jika ada
                    ? Image.memory(
                        base64Decode(widget.product.imageBase64),
                        fit: BoxFit.cover,
                        gaplessPlayback: true, // Mencegah kedip saat gambar dimuat
                      )
                    // Tampilkan placeholder jika string Base64 kosong
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, size: 40, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.author,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp${widget.product.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: DeliveryType.values.map((type) {
          return RadioListTile<DeliveryType>(
            title: Text(
              type == DeliveryType.digital 
                  ? 'Digital Delivery (Instant Access)' 
                  : 'Physical Delivery (Shipping Required)',
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
            value: type,
            groupValue: _deliveryType,
            activeColor: const Color.fromRGBO(54, 105, 201, 1),
            onChanged: (DeliveryType? value) {
              setState(() {
                _deliveryType = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShippingForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(54, 105, 201, 1),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Full Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(54, 105, 201, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(54, 105, 201, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(54, 105, 201, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your postal code';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedToPayment() {
    if (_deliveryType == DeliveryType.physical) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          product: widget.product,
          deliveryType: _deliveryType,
          shippingAddress: _deliveryType == DeliveryType.physical
              ? ShippingAddress(
                  address: _addressController.text,
                  city: _cityController.text,
                  postalCode: _postalCodeController.text,
                )
              : null,
        ),
      ),
    );
  }
}