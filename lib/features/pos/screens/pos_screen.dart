import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/models/category.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/core/widgets/kr_shimmer.dart';
import 'package:kasir_rakyat/features/pos/cubit/cart_cubit.dart';
import 'package:kasir_rakyat/features/pos/cubit/cart_state.dart';
import 'package:kasir_rakyat/features/pos/cubit/pos_cubit.dart';
import 'package:kasir_rakyat/features/pos/cubit/pos_state.dart';
import 'package:kasir_rakyat/features/pos/repository/pos_repository.dart';
import 'package:kasir_rakyat/features/pos/screens/cart_screen.dart';
import 'package:kasir_rakyat/features/pos/widgets/cart_fab.dart';
import 'package:kasir_rakyat/features/pos/widgets/category_filter.dart';
import 'package:kasir_rakyat/features/pos/widgets/product_card.dart';
import 'package:kasir_rakyat/features/settings/repository/settings_repository.dart';
import 'package:shimmer/shimmer.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PosCubit(PosRepository())..loadProducts()),
        BlocProvider(create: (_) => CartCubit()),
      ],
      child: const _PosView(),
    );
  }
}

class _PosView extends StatefulWidget {
  const _PosView();

  @override
  State<_PosView> createState() => _PosViewState();
}

class _PosViewState extends State<_PosView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: Column(
        children: [
          const _PosAppBar(),
          Expanded(
            child: BlocBuilder<PosCubit, PosState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const _PosShimmer(),
                  loaded:
                      (products, categories, selectedCategoryId, searchQuery) {
                        final filtered = _applyFilter(
                          products: products,
                          categoryId: selectedCategoryId,
                          query: searchQuery,
                        );
                        return _LoadedBody(
                          products: filtered,
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
                              context.read<PosCubit>().loadProducts(),
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

class _PosAppBar extends StatelessWidget {
  const _PosAppBar();

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
  final List<Category> categories;
  final int? selectedCategoryId;
  final TextEditingController searchController;

  const _LoadedBody({
    required this.products,
    required this.categories,
    required this.selectedCategoryId,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final hasCart = cartState.totalItems > 0;

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GreetingSection(),
                        const SizedBox(height: 20),
                        _SearchBar(controller: searchController),
                        const SizedBox(height: 16),
                        CategoryFilter(
                          categories: categories,
                          selectedCategoryId: selectedCategoryId,
                          onCategorySelected: (id) =>
                              context.read<PosCubit>().filterByCategory(id),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (products.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 56,
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
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, hasCart ? 100 : 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          cartQuantity: cartState.quantityOf(product.id),
                          onAdd: () =>
                              context.read<CartCubit>().addProduct(product),
                          onRemove: () => context
                              .read<CartCubit>()
                              .removeProduct(product.id),
                        );
                      }, childCount: products.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                    ),
                  ),
              ],
            ),
            if (hasCart)
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: CartFab(
                  cartState: cartState,
                  onCheckout: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<CartCubit>(),
                          child: const CartScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GreetingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Halo, Selamat Datang',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Kelola penjualan di '),
              TextSpan(
                text: SettingsRepository.instance.getProfileSync().name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const TextSpan(text: ' hari ini.'),
            ],
          ),
        ),
      ],
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
      onChanged: (value) => context.read<PosCubit>().search(value),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Cari barang atau scan barcode...',
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.qr_code_scanner,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: () {
            // open barcode scanner
          },
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

class _PosShimmer extends StatelessWidget {
  const _PosShimmer();

  static Widget _box(double height, {double radius = 8, double? width}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: KrShimmer.base,
      highlightColor: KrShimmer.highlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            _box(22, width: 160),
            const SizedBox(height: 8),
            _box(16, width: 220),
            const SizedBox(height: 20),
            // Search bar
            _box(48, radius: 12),
            const SizedBox(height: 16),
            // Category chips
            Row(
              children: List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _box(34, radius: 99, width: 72),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Product grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
