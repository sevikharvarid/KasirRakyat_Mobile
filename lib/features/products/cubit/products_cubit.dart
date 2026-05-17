import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/features/products/repository/products_repository.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository _repository;

  ProductsCubit(this._repository) : super(const ProductsState.initial());

  Future<void> loadProducts() async {
    emit(const ProductsState.loading());
    try {
      final products = await _repository.getAllProducts();
      final categories = await _repository.getAllCategories();
      emit(ProductsState.loaded(products: products, categories: categories));
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }

  void filterByCategory(int? categoryId) {
    state.maybeWhen(
      loaded: (products, categories, _, searchQuery) => emit(
        ProductsState.loaded(
          products: products,
          categories: categories,
          selectedCategoryId: categoryId,
          searchQuery: searchQuery,
        ),
      ),
      orElse: () {},
    );
  }

  void search(String query) {
    state.maybeWhen(
      loaded: (products, categories, selectedCategoryId, _) => emit(
        ProductsState.loaded(
          products: products,
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          searchQuery: query,
        ),
      ),
      orElse: () {},
    );
  }

  Future<void> saveProduct(Product product) async {
    try {
      await _repository.saveProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _repository.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }
}
