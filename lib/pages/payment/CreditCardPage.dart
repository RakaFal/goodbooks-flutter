// pages/payment/credit_card_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodbooks_flutter/models/payment_models.dart';

class CreditCardPage extends StatefulWidget {
  final Function(PaymentCard) onCardSubmitted;

  const CreditCardPage({Key? key, required this.onCardSubmitted}) : super(key: key);

  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(54, 105, 201, 1)),
        title: const Text(
          'Credit/Debit Card',
          style: TextStyle(
            color: Color.fromRGBO(54, 105, 201, 1),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCardNumberField(),
              const SizedBox(height: 16),
              _buildCardHolderField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildExpiryDateField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCvvField()),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Pay Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: const InputDecoration(
        labelText: 'Card Number',
        prefixIcon: Icon(Icons.credit_card),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        CardNumberFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card number';
        }
        if (value.length < 16) {
          return 'Card number must be 16 digits';
        }
        return null;
      },
    );
  }

  Widget _buildCardHolderField() {
    return TextFormField(
      controller: _cardHolderController,
      decoration: const InputDecoration(
        labelText: 'Card Holder Name',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card holder name';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryDateField() {
    return TextFormField(
      controller: _expiryDateController,
      decoration: const InputDecoration(
        labelText: 'MM/YY',
        prefixIcon: Icon(Icons.calendar_today),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        CardExpiryFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter expiry date';
        }
        if (value.length < 5) {
          return 'Invalid expiry date';
        }
        return null;
      },
    );
  }

  Widget _buildCvvField() {
    return TextFormField(
      controller: _cvvController,
      decoration: const InputDecoration(
        labelText: 'CVV',
        prefixIcon: Icon(Icons.lock),
      ),
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter CVV';
        }
        if (value.length < 3) {
          return 'CVV must be 3 digits';
        }
        return null;
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final card = PaymentCard(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolder: _cardHolderController.text,
        expiryDate: _expiryDateController.text,
        cvv: _cvvController.text,
      );
      widget.onCardSubmitted(card);
    }
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);
    
    var formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) formatted += ' ';
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);
    
    var formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) formatted += '/';
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}