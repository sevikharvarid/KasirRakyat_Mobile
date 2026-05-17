import 'package:kasir_rakyat/features/pos/models/payment_method.dart';

class ReceiptItem {
  final String name;
  final int quantity;
  final int unitPrice;
  final int subtotal;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });
}

class ReceiptData {
  final String transactionId;
  final DateTime createdAt;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final List<ReceiptItem> items;
  final int subtotal;
  final int tax;
  final int total;
  final PaymentMethod paymentMethod;
  final int amountPaid;
  final int change;

  const ReceiptData({
    required this.transactionId,
    required this.createdAt,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
  });
}
