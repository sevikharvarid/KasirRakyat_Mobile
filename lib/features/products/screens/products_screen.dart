import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/models/category.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/core/widgets/kr_shimmer.dart';
import 'package:kasir_rakyat/features/products/cubit/products_cubit.dart';
import 'package:kasir_rakyat/features/products/cubit/products_state.dart';
import 'package:kasir_rakyat/features/products/repository/products_repository.dart';
import 'package:kasir_rakyat/features/products/screens/product_form_screen.dart';
import 'package:kasir_rakyat/features/products/widgets/product_list_tile.dart';
import 'package:kasir_rakyat/features/pos/widgets/category_filter.dart';
import 'package:shimmer/shimmer.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit(ProductsRepository())..loadProducts(),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const _AppBar(),
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const _ProductsShimmer(),
                  loaded:
                      (products, categories, selectedCategoryId, searchQuery) {
                        final filtered = _applyFilter(
                          products: products,
                          categoryId: selectedCategoryId,
                          query: searchQuery,
                        );
                        return _LoadedBody(
                          products: filtered,
                          allCount: products.length,
                          categories: categories,
                          selectedCategoryId: selectedCategoryId,
                          searchController: _searchController,
                        );
                      },
                  error: (message) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.danger,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              context.read<ProductsCubit>().loadProducts(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _openForm(BuildContext context, Product? product) {
    final cubit = context.read<ProductsCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ProductFormScreen(product: product),
        ),
      ),
    );
  }

  List<Product> _applyFilter({
    required List<Product> products,
    required int? categoryId,
    required String query,
  }) {
    var result = products;
    if (categoryId != null) {
      result = result.where((p) => p.categoryId == categoryId).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return result;
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primarySurface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMedium,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final List<Product> products;
  final int allCount;
  final List<Category> categories;
  final int? selectedCategoryId;
  final TextEditingController searchController;

  const _LoadedBody({
    required this.products,
    required this.allCount,
    required this.categories,
    required this.selectedCategoryId,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SearchBar(controller: searchController),
        const SizedBox(height: 12),
        _BarcodeScanButton(),
        const SizedBox(height: 16),
        CategoryFilter(
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          onCategorySelected: (id) =>
              context.read<ProductsCubit>().filterByCategory(id),
        ),
        const SizedBox(height: 20),
        _SectionHeader(count: allCount),
        const SizedBox(height: 12),
        if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppColors.border,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Produk tidak ditemukan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductListTile(
                product: product,
                onTap: () {},
                onEdit: () {
                  final cubit = context.read<ProductsCubit>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: ProductFormScreen(product: product),
                      ),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, product),
              );
            },
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Produk?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Produk "${product.name}" akan dihapus secara permanen.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ProductsCubit>().deleteProduct(product.id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (v) => context.read<ProductsCubit>().search(v),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Cari nama produk atau barcode...',
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _BarcodeScanButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.barcode_reader,
              color: AppColors.textSecondary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Pindai Barcode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int count;

  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Daftar Produk',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          '$count PRODUK',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _ProductsShimmer extends StatelessWidget {
  const _ProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: KrShimmer.base,
      highlightColor: KrShimmer.highlight,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
