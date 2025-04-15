// models/payment_model.dart
enum PaymentMethod { creditCard, bankTransfer, eWallet }

class PaymentCard {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;

  PaymentCard({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
  });
}

class BankAccount {
  final String bankName;
  final String accountNumber;
  final String accountHolder;

  BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });
}

class EWallet {
  final String walletType;
  final String phoneNumber;
  final double amount;

  EWallet({
    required this.walletType,
    required this.phoneNumber,
    required this.amount,
  });
}