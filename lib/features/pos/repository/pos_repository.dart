import 'package:kasir_rakyat/core/models/category.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/core/services/app_data_store.dart';

class PosRepository {
  final _store = AppDataStore.instance;

  Future<List<Product>> getAllProducts() async => List.unmodifiable(_store.products);

  Future<List<Category>> getAllCategories() async => List.unmodifiable(_store.categories);
}
