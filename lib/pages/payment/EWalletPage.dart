import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/models/payment_models.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EWalletPage extends StatefulWidget {
  final Function(EWallet) onWalletSubmitted;
  final double amount;

  const EWalletPage({
    Key? key,
    required this.onWalletSubmitted,
    required this.amount,
  }) : super(key: key);

  @override
  State<EWalletPage> createState() => _EWalletPageState();
}

class _EWalletPageState extends State<EWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  String _selectedWallet = 'Gopay';
  String? _qrCodeData;
  bool _isLoading = false;
  bool _useDummyData = true;

  final List<String> wallets = [
    'Gopay',
    'OVO',
    'Dana',
    'ShopeePay',
    'LinkAja',
    'QRIS',
  ];

  @override
  void initState() {
    super.initState();
    // Generate QR jika default-nya sudah QRIS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedWallet == 'QRIS') {
        _generateQRIS();
      }
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _generateQRIS() async {
    setState(() {
      _isLoading = true;
      _qrCodeData = null;
    });

    if (_useDummyData) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _qrCodeData = _generateDummyQRISData();
        _isLoading = false;
      });
    } else {
      try {
        final response = await http.post(
          Uri.parse('https://api.midtrans.com/v2/charge'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Basic YOUR_SERVER_KEY',
          },
          body: jsonEncode({
            "payment_type": "qris",
            "transaction_details": {
              "order_id": "ORDER-${DateTime.now().millisecondsSinceEpoch}",
              "gross_amount": widget.amount.toInt(),
            }
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _qrCodeData = data['actions'][0]['url'];
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to generate QRIS');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  String _generateDummyQRISData() {
    return "00020101021226690014COM.GO-JEK.WWW0118936009140311111020215204581153033605802ID5920GoodBooks Store6015Jakarta Selatan61051234062380109GOJEK_QRIS0708A1234B6304ABCD";
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final eWallet = EWallet(
        walletType: _selectedWallet,
        phoneNumber: _phoneNumberController.text,
        amount: widget.amount,
      );
      widget.onWalletSubmitted(eWallet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        iconTheme: const IconThemeData(color: Color.fromRGBO(54, 105, 201, 1)),
        title: const Text(
          'E-Wallet/QRIS',
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedWallet,
                decoration: const InputDecoration(
                  labelText: 'E-Wallet',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet,
                    child: Text(wallet),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWallet = value!;
                    if (_selectedWallet == 'QRIS') {
                      _generateQRIS();
                    } else {
                      _qrCodeData = null;
                    }
                  });
                },
              ),

              if (_selectedWallet != 'QRIS') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 32),

              if (_selectedWallet == 'QRIS')
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else if (_qrCodeData != null)
                        Column(
                          children: [
                            QrImageView(
                              data: _qrCodeData!,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Amount: Rp${widget.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Scan this QR code to complete payment',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedWallet == 'QRIS') {
                      final eWallet = EWallet(
                        walletType: _selectedWallet,
                        phoneNumber: '',
                        amount: widget.amount,
                      );
                      widget.onWalletSubmitted(eWallet);
                    } else {
                      _submitForm();
                    }
                  },
                  child: Text(_selectedWallet == 'QRIS' ? 'I Have Paid' : 'Pay Now'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
