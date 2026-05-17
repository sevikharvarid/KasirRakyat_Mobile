import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kasir_rakyat/core/models/category.dart';
import 'package:kasir_rakyat/core/models/product.dart';

part 'pos_state.freezed.dart';

@freezed
class PosState with _$PosState {
  const factory PosState.initial() = _Initial;
  const factory PosState.loading() = _Loading;
  const factory PosState.loaded({
    required List<Product> products,
    required List<Category> categories,
    int? selectedCategoryId,
    @Default('') String searchQuery,
  }) = _Loaded;
  const factory PosState.error(String message) = _Error;
}
