import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/payment_models.dart';
import 'CheckoutPage.dart';

class ReceiptPage extends StatelessWidget {
  final ProductModel product;
  final DeliveryType deliveryType;
  final ShippingAddress? shippingAddress;
  final PaymentMethod paymentMethod;
  final double totalPrice;
  final DateTime purchaseDate;

  ReceiptPage({
    Key? key,
    required this.product,
    required this.deliveryType,
    required this.paymentMethod,
    required this.totalPrice,
    this.shippingAddress,
  })  : purchaseDate = DateTime.now(),
        super(key: key);

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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text(
            'Back to Home',
            style: TextStyle(fontSize: 16, color: const Color.fromRGBO(54, 105, 201, 1), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Untuk vertikal center
        crossAxisAlignment: CrossAxisAlignment.center, // Untuk horizontal center
        children: [
          const Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(54, 105, 201, 1),
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center, // Tambahkan ini
          ),
          const SizedBox(height: 8),
          Text(
            'Order #${purchaseDate.millisecondsSinceEpoch.toString().substring(5)}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center, // Pusatkan teks order number
          ),
          const SizedBox(height: 8),
          Text(
            '${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year} ${purchaseDate.hour}:${purchaseDate.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center, // Pusatkan teks tanggal
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildReceiptRow('Product', product.title),
            _buildReceiptRow('Author', product.author),
            _buildReceiptRow('Price', 'Rp${product.price.toStringAsFixed(0)}'),
            _buildReceiptRow(
              'Shipping',
              deliveryType == DeliveryType.physical ? 'Rp15000' : 'Digital Delivery',
            ),
            const Divider(height: 24),
            _buildReceiptRow(
              'Total Amount',
              'Rp${totalPrice.toStringAsFixed(0)}',
              isBold: true,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildReceiptRow('Payment Method', _getPaymentMethodName(paymentMethod)),
            _buildReceiptRow('Payment Status', 'Completed'),
            _buildReceiptRow('Payment Date', 
              '${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            if (deliveryType == DeliveryType.digital) ...[
              _buildReceiptRow('Delivery Type', 'Digital'),
              _buildReceiptRow('Status', 'Available immediately'),
              _buildReceiptRow('Access', 'Check your library'),
            ] else if (shippingAddress != null) ...[
              _buildReceiptRow('Delivery Type', 'Physical Shipping'),
              _buildReceiptRow('Address', shippingAddress!.address, isAddress: true),
              _buildReceiptRow('City', shippingAddress!.city),
              _buildReceiptRow('Postal Code', shippingAddress!.postalCode),
              _buildReceiptRow('Estimated Delivery', '3-5 business days'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThankYou() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 60, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Thank you for your purchase!',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your order has been processed successfully.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Tambahkan tombol atau elemen lain jika diperlukan
        ],
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