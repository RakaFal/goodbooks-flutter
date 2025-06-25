import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/payment_models.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptPage extends StatefulWidget {
  final ProductModel product;
  final DeliveryType deliveryType;
  final ShippingAddress? shippingAddress;
  final PaymentMethod paymentMethod;
  final double totalPrice;

  const ReceiptPage({
    Key? key,
    required this.product,
    required this.deliveryType,
    required this.paymentMethod,
    required this.totalPrice,
    this.shippingAddress,
  }) : super(key: key);

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool _isProcessing = false;
  final DateTime _purchaseDate = DateTime.now();

  // BARU: Fungsi untuk mencatat pembelian dan kembali ke home
  Future<void> _finalizeAndGoHome() async {
    // Hanya proses jika ini pembelian digital
    if (widget.deliveryType == DeliveryType.digital) {
      setState(() => _isProcessing = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      final bookId = widget.product.id;

      if (userId != null && userId.isNotEmpty) {
        try {
          // Mencatat buku ke library pengguna
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('purchased_books')
              .doc(bookId)
              .set({'purchasedAt': _purchaseDate});
          
          // Kembali ke home setelah berhasil
          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal menyimpan ke library: $e")),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      }
    } else {
      // Jika pembelian fisik, langsung kembali ke home
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipt', 
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildOrderSummary(),
            const SizedBox(height: 24),
            _buildPaymentInfo(),
            const SizedBox(height: 32),
            _buildDeliveryInfo(),
            const SizedBox(height: 40),
            _buildThankYou(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        // DIUBAH: Tombol sekarang memanggil fungsi _finalizeAndGoHome
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _finalizeAndGoHome,
          child: _isProcessing 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
            : const Text('Back to Home'),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(54, 105, 201, 1))),
          const SizedBox(height: 8),
          Text('Order #${_purchaseDate.millisecondsSinceEpoch.toString().substring(5)}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year} ${_purchaseDate.hour}:${_purchaseDate.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return _buildInfoCard(
      title: 'Order Summary',
      children: [
        _buildReceiptRow('Product', widget.product.title),
        _buildReceiptRow('Author', widget.product.author),
        _buildReceiptRow('Price', 'Rp${widget.product.price.toStringAsFixed(0)}'),
        _buildReceiptRow('Shipping', widget.deliveryType == DeliveryType.physical ? 'Rp15000' : 'Digital Delivery'),
        const Divider(height: 24),
        _buildReceiptRow('Total Amount', 'Rp${widget.totalPrice.toStringAsFixed(0)}', isTotal: true),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return _buildInfoCard(
      title: 'Payment Information',
      children: [
        _buildReceiptRow('Payment Method', _getPaymentMethodName(widget.paymentMethod)),
        _buildReceiptRow('Payment Status', 'Completed'),
        _buildReceiptRow('Payment Date', '${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}'),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return _buildInfoCard(
      title: 'Delivery Information',
      children: [
        if (widget.deliveryType == DeliveryType.digital) ...[
          _buildReceiptRow('Delivery Type', 'Digital'),
          _buildReceiptRow('Status', 'Available immediately'),
          _buildReceiptRow('Access', 'Check your library'),
        ] else if (widget.shippingAddress != null) ...[
          _buildReceiptRow('Delivery Type', 'Physical Shipping'),
          _buildReceiptRow('Address', widget.shippingAddress!.address, isAddress: true),
          _buildReceiptRow('City', widget.shippingAddress!.city),
          _buildReceiptRow('Postal Code', widget.shippingAddress!.postalCode),
          _buildReceiptRow('Estimated Delivery', '3-5 business days'),
        ],
      ],
    );
  }

  Widget _buildThankYou() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 60, color: Colors.green),
          const SizedBox(height: 16),
          Text('Thank you for your purchase!', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Your order has been processed successfully.', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
     return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildReceiptRow(String label, String value, 
      {bool isBold = false, bool isTotal = false, bool isAddress = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.5, // Gunakan constraints dari LayoutBuilder
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: isTotal ? const Color.fromRGBO(54, 105, 201, 1) : Colors.black,
                  ),
                  overflow: isAddress ? TextOverflow.ellipsis : TextOverflow.visible,
                  maxLines: isAddress ? 2 : 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit/Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.eWallet:
        return 'E-Wallet/QRIS';
    }
  }
}