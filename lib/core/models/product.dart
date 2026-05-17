import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    int? categoryId,
    required int sellPrice,
    required int buyPrice,
    required int stock,
    required int minStock,
    /// Satuan produk, mis. "pcs", "kg", "dus". Default "pcs".
    @Default('pcs') String unit,
    String? imageUrl,
    String? barcode,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Product;
}
