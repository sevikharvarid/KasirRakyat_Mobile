import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/features/pos/repository/pos_repository.dart';
import 'pos_state.dart';

class PosCubit extends Cubit<PosState> {
  final PosRepository _repository;

  PosCubit(this._repository) : super(const PosState.initial());

  Future<void> loadProducts() async {
    emit(const PosState.loading());
    try {
      final products = await _repository.getAllProducts();
      final categories = await _repository.getAllCategories();
      emit(PosState.loaded(products: products, categories: categories));
    } catch (e) {
      emit(PosState.error(e.toString()));
    }
  }

  void filterByCategory(int? categoryId) {
    state.maybeWhen(
      loaded: (products, categories, _, searchQuery) {
        emit(PosState.loaded(
          products: products,
          categories: categories,
          selectedCategoryId: categoryId,
          searchQuery: searchQuery,
        ));
      },
      orElse: () {},
    );
  }

  void search(String query) {
    state.maybeWhen(
      loaded: (products, categories, selectedCategoryId, _) {
        emit(PosState.loaded(
          products: products,
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          searchQuery: query,
        ));
      },
      orElse: () {},
    );
  }
}
