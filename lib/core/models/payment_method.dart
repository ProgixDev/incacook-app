sealed class PaymentMethod {
  const PaymentMethod({required this.id});
  final String id;
}

class WalletPaymentMethod extends PaymentMethod {
  const WalletPaymentMethod({required super.id, required this.balance});

  final double balance;

  bool coversAmount(double amount) => balance >= amount;
  double shortfallFor(double amount) => amount - balance;
  double remainderAfter(double amount) => balance - amount;
}

class SavedCardPaymentMethod extends PaymentMethod {
  const SavedCardPaymentMethod({
    required super.id,
    required this.last4,
    required this.expiry,
    this.brand = 'Visa',
  });

  final String last4;
  final String expiry;
  final String brand;
}

class PayPalPaymentMethod extends PaymentMethod {
  const PayPalPaymentMethod({required super.id, required this.maskedEmail});

  final String maskedEmail;
}

class ApplePayPaymentMethod extends PaymentMethod {
  const ApplePayPaymentMethod({required super.id});
}

class GooglePayPaymentMethod extends PaymentMethod {
  const GooglePayPaymentMethod({required super.id});
}
