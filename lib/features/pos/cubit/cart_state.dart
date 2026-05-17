import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kasir_rakyat/core/models/product.dart';

part 'cart_state.freezed.dart';

@freezed
class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required Product product,
    required int quantity,
  }) = _CartItem;

  int get subtotal => product.sellPrice * quantity;
}

@freezed
class CartState with _$CartState {
  const CartState._();

  const factory CartState({
    @Default([]) List<CartItem> items,
  }) = _CartState;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  int get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);

  int quantityOf(int productId) {
    try {
      return items.firstWhere((i) => i.product.id == productId).quantity;
    } catch (_) {
      return 0;
    }
  }
}
