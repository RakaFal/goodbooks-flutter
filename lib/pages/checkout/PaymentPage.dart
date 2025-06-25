import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/payment_models.dart'; // DIUBAH: Import file model yang benar
import 'CreditCardPage.dart';
import 'BankTransferPage.dart';
import 'EWalletPage.dart';
import 'ReceiptPage.dart';

class PaymentPage extends StatefulWidget {
  final ProductModel product;
  final DeliveryType deliveryType;
  final ShippingAddress? shippingAddress;

  const PaymentPage({
    Key? key,
    required this.product,
    required this.deliveryType,
    this.shippingAddress,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    totalPrice = widget.product.price +
        (widget.deliveryType == DeliveryType.physical ? 15000 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        iconTheme: const IconThemeData(color: Color.fromRGBO(54, 105, 201, 1)),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOrderRow('Product', widget.product.title),
                    _buildOrderRow('Author', widget.product.author),
                    _buildOrderRow('Price', 'Rp${widget.product.price.toStringAsFixed(0)}'),
                    if (widget.deliveryType == DeliveryType.physical) ...[
                      _buildOrderRow('Shipping', 'Rp15000'),
                      if (widget.shippingAddress != null) ...[
                        _buildOrderRow('Address', widget.shippingAddress!.address),
                        _buildOrderRow('City', widget.shippingAddress!.city),
                        _buildOrderRow('Postal Code', widget.shippingAddress!.postalCode),
                      ],
                    ],
                    const Divider(),
                    _buildOrderRow(
                      'Total',
                      'Rp${totalPrice.toStringAsFixed(0)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPaymentMethods(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _completePurchase(context),
                child: const Text(
                  'Complete Purchase',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(54, 105, 201, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? Colors.black : Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: PaymentMethod.values.map((method) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: _selectedMethod == method ? Colors.blue[50] : null,
          child: ListTile(
            leading: Icon(
              _getPaymentMethodIcon(method),
              color: const Color.fromRGBO(54, 105, 201, 1),
            ),
            title: Text(
              _getPaymentMethodName(method),
              style: const TextStyle(color: Color.fromRGBO(54, 105, 201, 1)),
            ),
            trailing: _selectedMethod == method
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              setState(() {
                _selectedMethod = method;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.eWallet:
        return Icons.payment;
    }
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

  void _completePurchase(BuildContext context) {
    switch (_selectedMethod) {
      case PaymentMethod.creditCard:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreditCardPage(
              onCardSubmitted: (card) {
                _processPayment(context, card);
              },
            ),
          ),
        );
        break;
      case PaymentMethod.bankTransfer:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BankTransferPage(
              onBankSubmitted: (bank) {
                _processPayment(context, bank);
              },
            ),
          ),
        );
        break;
      case PaymentMethod.eWallet:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EWalletPage(
              onWalletSubmitted: (wallet) {
                _processPayment(context, wallet);
              },
              amount: totalPrice,
            ),
          ),
        );
        break;
    }
  }

  void _processPayment(BuildContext context, dynamic paymentData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPage(
            product: widget.product,
            deliveryType: widget.deliveryType,
            shippingAddress: widget.shippingAddress,
            paymentMethod: _selectedMethod,
            totalPrice: totalPrice,
          ),
        ),
      );
    });
  }
}
