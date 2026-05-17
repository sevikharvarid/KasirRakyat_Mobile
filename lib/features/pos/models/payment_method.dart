enum PaymentMethod { tunai, transfer, qris }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.tunai: return 'Tunai';
      case PaymentMethod.transfer: return 'Transfer';
      case PaymentMethod.qris: return 'QRIS';
    }
  }
}
