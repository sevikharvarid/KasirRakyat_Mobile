import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addProduct(Product product) {
    if (product.stock == 0) return;
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      if (items[idx].quantity >= product.stock) return;
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }

  void removeProduct(int productId) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    if (items[idx].quantity > 1) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity - 1);
    } else {
      items.removeAt(idx);
    }
    emit(state.copyWith(items: items));
  }

  void deleteItem(int productId) {
    final items = List<CartItem>.from(state.items)
      ..removeWhere((i) => i.product.id == productId);
    emit(state.copyWith(items: items));
  }

  void clearCart() => emit(const CartState());
}
