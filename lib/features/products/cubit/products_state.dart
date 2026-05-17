import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kasir_rakyat/core/models/category.dart';
import 'package:kasir_rakyat/core/models/product.dart';

part 'products_state.freezed.dart';

@freezed
class ProductsState with _$ProductsState {
  const factory ProductsState.initial() = _Initial;
  const factory ProductsState.loading() = _Loading;
  const factory ProductsState.loaded({
    required List<Product> products,
    required List<Category> categories,
    int? selectedCategoryId,
    @Default('') String searchQuery,
  }) = _Loaded;
  const factory ProductsState.error(String message) = _Error;
}
