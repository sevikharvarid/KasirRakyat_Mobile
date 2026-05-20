import 'package:kasir_rakyat/core/models/category.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/features/pos/models/payment_method.dart';
import 'package:kasir_rakyat/features/pos/models/receipt_data.dart';

/// In-memory singleton shared by all repositories (POS, Products, Reports).
/// Replaces the previously isolated mocks so that data is consistent across
/// the whole app without a database.
///
/// TODO: replace with Drift persistence in a later sprint.
class AppDataStore {
  AppDataStore._();
  static final AppDataStore instance = AppDataStore._();

  // ── Categories ─────────────────────────────────────────────────────────────
  final List<Category> categories = [
    const Category(id: 1, name: 'Sembako',   sortOrder: 1),
    const Category(id: 2, name: 'Minuman',   sortOrder: 2),
    const Category(id: 3, name: 'Kopi & Teh', sortOrder: 3),
    const Category(id: 4, name: 'Snack',     sortOrder: 4),
    const Category(id: 5, name: 'Bumbu',     sortOrder: 5),
  ];

  // ── Products ────────────────────────────────────────────────────────────────
  final List<Product> products = [
    const Product(
      id: 1, name: 'Kopi Sachet', categoryId: 3, unit: 'sachet',
      sellPrice: 2500, buyPrice: 1800, stock: 24, minStock: 10,
    ),
    const Product(
      id: 2, name: 'Minyak Goreng 1L', categoryId: 1, unit: 'botol',
      sellPrice: 18000, buyPrice: 14000, stock: 5, minStock: 5,
    ),
    const Product(
      id: 3, name: 'Crip-Crip Snack', categoryId: 4, unit: 'pcs',
      sellPrice: 5000, buyPrice: 3500, stock: 42, minStock: 10,
    ),
    const Product(
      id: 4, name: 'Beras Premium 5kg', categoryId: 1, unit: 'kg',
      sellPrice: 72000, buyPrice: 58000, stock: 12, minStock: 5,
    ),
    const Product(
      id: 5, name: 'Air Mineral 600ml', categoryId: 2, unit: 'botol',
      sellPrice: 4000, buyPrice: 2800, stock: 50, minStock: 10,
    ),
    const Product(
      id: 6, name: 'Gula Pasir 1kg', categoryId: 1, unit: 'kg',
      sellPrice: 14000, buyPrice: 11000, stock: 18, minStock: 5,
    ),
    const Product(
      id: 7, name: 'Teh Celup', categoryId: 2, unit: 'pcs',
      sellPrice: 3000, buyPrice: 2000, stock: 30, minStock: 10,
    ),
    const Product(
      id: 8, name: 'Mie Instan', categoryId: 1, unit: 'pcs',
      sellPrice: 3500, buyPrice: 2500, stock: 60, minStock: 20,
    ),
  ];

  int _nextProductId = 9;

  // ── Transactions ─────────────────────────────────────────────────────────────
  final List<AppTransaction> transactions = [];

  // ── Order History (Riwayat Order) ────────────────────────────────────────────
  final List<ReceiptData> receipts = [];

  // ── Products API ─────────────────────────────────────────────────────────────
  void saveProduct(Product product) {
    final idx = products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      products[idx] = product;
    } else {
      products.add(product.copyWith(id: _nextProductId++));
    }
  }

  void deleteProduct(int id) => products.removeWhere((p) => p.id == id);

  // ── Order History API ─────────────────────────────────────────────────────────
  void addReceipt(ReceiptData receipt) => receipts.insert(0, receipt);

  // ── Transactions API ─────────────────────────────────────────────────────────
  void recordTransaction(AppTransaction tx) {
    transactions.add(tx);
    // Decrement stock for each sold item
    for (final item in tx.items) {
      final idx = products.indexWhere((p) => p.id == item.productId);
      if (idx >= 0) {
        final current = products[idx].stock;
        final newStock = (current - item.quantity).clamp(0, 999999);
        products[idx] = products[idx].copyWith(stock: newStock);
      }
    }
  }
}

// ── Transaction model ─────────────────────────────────────────────────────────

class AppTransaction {
  final String id;
  final DateTime createdAt;
  final List<AppTxItem> items;
  final int subtotal;
  final int tax;
  final int total;
  final PaymentMethod paymentMethod;
  final int amountPaid;
  final int change;
  final String? customerName;
  final String? customerPhone;

  const AppTransaction({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    this.customerName,
    this.customerPhone,
  });
}

class AppTxItem {
  final int productId;
  final String productName;
  final int unitPrice;
  final int buyPrice;
  final int quantity;
  final int subtotal;

  const AppTxItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.buyPrice,
    required this.quantity,
    required this.subtotal,
  });
}
