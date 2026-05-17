import 'package:kasir_rakyat/core/models/category.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/core/services/app_data_store.dart';

class ProductsRepository {
  final _store = AppDataStore.instance;

  Future<List<Product>> getAllProducts() async => List.unmodifiable(_store.products);

  Future<List<Category>> getAllCategories() async => List.unmodifiable(_store.categories);

  Future<void> saveProduct(Product product) async => _store.saveProduct(product);

  Future<void> deleteProduct(int id) async => _store.deleteProduct(id);
}
