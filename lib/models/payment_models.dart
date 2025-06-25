// Model untuk data kartu kredit
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

// Model untuk data transfer bank
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

// Model untuk data e-wallet
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

// Enum untuk metode pembayaran
enum PaymentMethod { creditCard, bankTransfer, eWallet }

// Enum untuk tipe pengiriman
enum DeliveryType { digital, physical }

// Class untuk alamat pengiriman
class ShippingAddress {
  final String address;
  final String city;
  final String postalCode;

  ShippingAddress({
    required this.address,
    required this.city,
    required this.postalCode,
  });
}