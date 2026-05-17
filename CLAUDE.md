# KasirRakyat — Flutter Project

Aplikasi kasir mobile offline-first untuk UMKM Indonesia (warung, toko kecil, pedagang).
Tagline: "Kasir Cepat, Usaha Lancar"
Target: Android & iOS, offline penuh (SQLite), tanpa backend API.

---

## Tech Stack

| Kebutuhan | Package | Versi |
|---|---|---|
| State management | `flutter_bloc` | ^8.x |
| State immutability | `freezed` + `freezed_annotation` | ^2.x |
| Code generation | `build_runner` | ^2.x |
| Database lokal | `drift` + `sqlite3_flutter_libs` | ^2.x |
| Navigasi | `go_router` | ^13.x |
| Barcode scanner | `mobile_scanner` | ^5.x |
| Bluetooth printer | `flutter_bluetooth_printer` | ^4.x |
| PDF & struk | `pdf` + `printing` | ^3.x |
| Grafik laporan | `fl_chart` | ^0.68.x |
| Export file | `path_provider` + `share_plus` | latest |
| Notifikasi lokal | `flutter_local_notifications` | ^17.x |
| Image picker | `image_picker` | ^1.x |
| Format angka | `intl` | ^0.19.x |
| Dependency injection | `get_it` | ^7.x |

---

## Brand & Design System

```
Primary color   : #16a34a  (hijau — brand utama)
Primary dark    : #15803d
Primary light   : #dcfce7
Primary surface : #f0fdf4

Success         : #16a34a
Warning         : #f59e0b
Danger          : #ef4444
Info            : #3b82f6
Neutral         : #6b7280

Background      : #ffffff
Surface         : #f9fafb
Border          : #e5e7eb
Text primary    : #111827
Text secondary  : #6b7280
Text tertiary   : #9ca3af
```

**Typography**
- Font: sistem default (Roboto Android / SF Pro iOS)
- Heading 1: 24px, weight 600
- Heading 2: 18px, weight 600
- Body: 14px, weight 400
- Caption: 12px, weight 400
- Label: 11px, weight 500

**Spacing & Radius**
- Padding standar: 16px
- Gap antar item: 12px
- Border radius card: 12px
- Border radius button: 8px
- Border radius chip/badge: 99px (pill)

**Bottom Navigation**
4 tab: Kasir · Produk · Laporan · Pengaturan
Icon style: outline (gunakan `Icons.*_outlined` atau package `tabler_icons`)

---

## Struktur Folder

```
lib/
├── main.dart
├── app.dart                          # Root widget, router setup
├── injection.dart                    # get_it dependency injection setup
│
├── core/
│   ├── database/
│   │   ├── app_database.dart         # Drift database class
│   │   ├── app_database.g.dart       # Generated oleh build_runner
│   │   ├── tables/
│   │   │   ├── products_table.dart
│   │   │   ├── categories_table.dart
│   │   │   ├── transactions_table.dart
│   │   │   ├── transaction_items_table.dart
│   │   │   ├── stock_logs_table.dart
│   │   │   └── users_table.dart
│   │   └── daos/
│   │       ├── products_dao.dart
│   │       ├── products_dao.g.dart
│   │       ├── transactions_dao.dart
│   │       ├── transactions_dao.g.dart
│   │       ├── reports_dao.dart
│   │       └── reports_dao.g.dart
│   │
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_constants.dart
│   │
│   ├── utils/
│   │   ├── currency_formatter.dart   # Format Rupiah: Rp 10.000
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   │
│   └── widgets/                      # Shared/reusable widgets
│       ├── kr_button.dart
│       ├── kr_text_field.dart
│       ├── kr_card.dart
│       ├── kr_badge.dart             # Badge stok: Tersedia/Menipis/Habis
│       ├── kr_empty_state.dart
│       ├── kr_loading.dart
│       └── kr_bottom_nav.dart
│
└── features/
    ├── auth/
    │   ├── screens/
    │   │   ├── splash_screen.dart
    │   │   ├── onboarding_screen.dart
    │   │   ├── setup_store_screen.dart
    │   │   └── pin_login_screen.dart
    │   ├── cubit/
    │   │   ├── auth_cubit.dart
    │   │   ├── auth_cubit.freezed.dart   # Generated
    │   │   └── auth_state.dart
    │   └── repository/
    │       └── auth_repository.dart
    │
    ├── pos/
    │   ├── screens/
    │   │   ├── pos_screen.dart
    │   │   ├── cart_screen.dart
    │   │   ├── payment_screen.dart
    │   │   └── receipt_screen.dart
    │   ├── widgets/
    │   │   ├── product_grid.dart
    │   │   ├── product_card.dart
    │   │   ├── category_filter.dart
    │   │   ├── cart_item_row.dart
    │   │   └── cart_fab.dart
    │   ├── cubit/
    │   │   ├── pos_cubit.dart
    │   │   ├── pos_cubit.freezed.dart
    │   │   ├── pos_state.dart
    │   │   ├── cart_cubit.dart
    │   │   ├── cart_cubit.freezed.dart
    │   │   └── cart_state.dart
    │   └── repository/
    │       ├── pos_repository.dart
    │       └── cart_repository.dart
    │
    ├── products/
    │   ├── screens/
    │   │   ├── products_screen.dart
    │   │   └── product_form_screen.dart
    │   ├── widgets/
    │   │   ├── product_list_tile.dart
    │   │   └── stock_badge.dart
    │   ├── cubit/
    │   │   ├── products_cubit.dart
    │   │   ├── products_cubit.freezed.dart
    │   │   └── products_state.dart
    │   └── repository/
    │       └── products_repository.dart
    │
    ├── inventory/
    │   ├── screens/
    │   │   ├── inventory_screen.dart
    │   │   └── restock_screen.dart
    │   ├── cubit/
    │   │   ├── inventory_cubit.dart
    │   │   ├── inventory_cubit.freezed.dart
    │   │   └── inventory_state.dart
    │   └── repository/
    │       └── inventory_repository.dart
    │
    ├── reports/
    │   ├── screens/
    │   │   ├── reports_screen.dart
    │   │   └── transaction_detail_screen.dart
    │   ├── widgets/
    │   │   ├── metric_card.dart
    │   │   ├── sales_chart.dart
    │   │   └── top_products_list.dart
    │   ├── cubit/
    │   │   ├── reports_cubit.dart
    │   │   ├── reports_cubit.freezed.dart
    │   │   └── reports_state.dart
    │   └── repository/
    │       └── reports_repository.dart
    │
    └── settings/
        ├── screens/
        │   ├── settings_screen.dart
        │   ├── store_profile_screen.dart
        │   ├── manage_users_screen.dart
        │   └── printer_setup_screen.dart
        ├── cubit/
        │   ├── settings_cubit.dart
        │   ├── settings_cubit.freezed.dart
        │   └── settings_state.dart
        └── repository/
            └── settings_repository.dart
```

---

## Pola Arsitektur: Cubit + Freezed + Repository

### 1. State — selalu pakai Freezed

```dart
// lib/features/products/cubit/products_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kasir_rakyat/core/database/tables/products_table.dart';

part 'products_state.freezed.dart';

@freezed
class ProductsState with _$ProductsState {
  const factory ProductsState.initial() = _Initial;
  const factory ProductsState.loading() = _Loading;
  const factory ProductsState.loaded({
    required List<Product> products,
    required List<Category> categories,
    String? selectedCategoryId,
    String? searchQuery,
  }) = _Loaded;
  const factory ProductsState.error(String message) = _Error;
}
```

### 2. Cubit — logic & emit state

```dart
// lib/features/products/cubit/products_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/products_repository.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository _repository;

  ProductsCubit(this._repository) : super(const ProductsState.initial());

  Future<void> loadProducts() async {
    emit(const ProductsState.loading());
    try {
      final products = await _repository.getAllProducts();
      final categories = await _repository.getAllCategories();
      emit(ProductsState.loaded(
        products: products,
        categories: categories,
      ));
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }

  Future<void> addProduct(ProductsCompanion product) async {
    try {
      await _repository.insertProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }

  void filterByCategory(String? categoryId) {
    final current = state;
    if (current is _Loaded) {
      emit(current.copyWith(selectedCategoryId: categoryId));
    }
  }

  void search(String query) {
    final current = state;
    if (current is _Loaded) {
      emit(current.copyWith(searchQuery: query));
    }
  }
}
```

### 3. Repository — satu-satunya akses ke DAO

```dart
// lib/features/products/repository/products_repository.dart

import 'package:kasir_rakyat/core/database/daos/products_dao.dart';
import 'package:kasir_rakyat/core/database/app_database.dart';

class ProductsRepository {
  final ProductsDao _productsDao;

  ProductsRepository(this._productsDao);

  Future<List<Product>> getAllProducts() => _productsDao.getAllProducts();
  Future<List<Category>> getAllCategories() => _productsDao.getAllCategories();
  Future<int> insertProduct(ProductsCompanion p) => _productsDao.insertProduct(p);
  Future<bool> updateProduct(ProductsCompanion p) => _productsDao.updateProduct(p);
  Future<int> deleteProduct(int id) => _productsDao.deleteProduct(id);
  Stream<List<Product>> watchLowStockProducts() => _productsDao.watchLowStockProducts();
}
```

### 4. Screen — konsumsi state dengan BlocBuilder

```dart
// lib/features/products/screens/products_screen.dart

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductsCubit>()..loadProducts(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Produk')),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox(),
              loading: () => const KrLoading(),
              loaded: (products, categories, selectedCategory, query) {
                if (products.isEmpty) {
                  return const KrEmptyState(
                    icon: Icons.inventory_2_outlined,
                    message: 'Belum ada produk',
                    action: 'Tambah Produk',
                  );
                }
                return ProductGrid(products: products);
              },
              error: (message) => KrEmptyState(
                icon: Icons.error_outline,
                message: message,
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## Dependency Injection (get_it)

```dart
// lib/injection.dart

final getIt = GetIt.instance;

void setupInjection() {
  // Database
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // DAOs
  getIt.registerLazySingleton<ProductsDao>(
    () => ProductsDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TransactionsDao>(
    () => TransactionsDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ReportsDao>(
    () => ReportsDao(getIt<AppDatabase>()),
  );

  // Repositories
  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepository(getIt<ProductsDao>()),
  );
  getIt.registerLazySingleton<PosRepository>(
    () => PosRepository(getIt<TransactionsDao>()),
  );
  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepository(getIt<ReportsDao>()),
  );

  // Cubits — factory supaya instance baru tiap BlocProvider
  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<CartCubit>(
    () => CartCubit(getIt<CartRepository>()),
  );
  getIt.registerFactory<ReportsCubit>(
    () => ReportsCubit(getIt<ReportsRepository>()),
  );
  // ...daftarkan semua Cubit dengan pola yang sama
}
```

---

## Database Schema (Drift)

```dart
// products
id, name, categoryId, sellPrice, buyPrice, stock, minStock,
imageUrl, barcode, isActive, createdAt, updatedAt

// categories
id, name, icon, colorHex, sortOrder

// transactions
id, receiptNumber, totalAmount, discountAmount, finalAmount,
paymentMethod, amountPaid, changeAmount, notes, cashierId,
status (completed/voided), createdAt

// transaction_items
id, transactionId, productId, productName, sellPrice, quantity, subtotal

// stock_logs
id, productId, type (in/out/adjustment), quantity,
previousStock, newStock, notes, createdAt

// users
id, name, role (owner/cashier), pin, isActive, createdAt
```

---

## Konvensi Kode

**Penamaan**
- File: `snake_case.dart`
- Class: `PascalCase`
- Variable/method: `camelCase`
- Constant: `kCamelCase` (prefix `k`)
- Cubit: `FeatureCubit`
- State: `FeatureState`
- Repository: `FeatureRepository`

**Freezed rules**
- Setiap state wajib `@freezed`
- Selalu gunakan `.when()` di BlocBuilder — jangan `is` type check
- Model data dengan banyak field juga pakai `@freezed`
- Setelah edit file state, jalankan:
  `flutter pub run build_runner build --delete-conflicting-outputs`

**Widget rules**
- Screen adalah `StatelessWidget` biasa — state dihandle Cubit
- `BlocProvider` di level screen untuk inject Cubit via `getIt`
- `BlocBuilder` untuk rebuild UI saat state berubah
- `BlocListener` untuk side effect (navigasi, snackbar, dialog)
- `BlocConsumer` jika butuh builder + listener sekaligus
- Gunakan `const` constructor sebisa mungkin
- Extract widget ke file terpisah jika lebih dari 80 baris

**Format Rupiah — selalu gunakan helper ini:**
```dart
// lib/core/utils/currency_formatter.dart
String formatRupiah(int amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}
// Output: Rp 10.000
```

**Harga disimpan sebagai `int` (Rupiah penuh) — jangan `double`.**

---

## Fitur & Status

### MVP v1.0
- [ ] Splash screen & onboarding
- [ ] Setup toko pertama kali
- [ ] Login PIN per user
- [ ] Layar POS: grid produk, filter kategori, search, barcode scan
- [ ] Keranjang: tambah/kurang/hapus item, diskon, catatan
- [ ] Pembayaran: tunai (hitung kembalian), transfer, QRIS (gambar statis)
- [ ] Struk digital: preview, share WhatsApp, cetak Bluetooth
- [ ] Manajemen produk: CRUD, foto, kategori, stok awal
- [ ] Laporan harian: omzet, transaksi, produk terlaris
- [ ] Pengaturan toko: profil, printer

### v1.1
- [ ] Export laporan PDF
- [ ] Notifikasi stok menipis
- [ ] Riwayat mutasi stok
- [ ] Multi user & role (owner vs kasir)
- [ ] Shift kasir

### v1.2
- [ ] Laporan mingguan & bulanan dengan grafik
- [ ] Stok opname
- [ ] Backup & restore database
- [ ] Varian produk

### v2.0
- [ ] Utang piutang pelanggan
- [ ] Sinkronisasi cloud (mulai online)
- [ ] Web dashboard owner

---

## Aturan Penting saat Generate Code

1. **State selalu Freezed** — jangan pakai class biasa untuk state Cubit
2. **Selalu `.when()`** di BlocBuilder — jangan `if (state is X)`
3. **Repository adalah satu-satunya akses ke DAO** — Cubit tidak boleh panggil DAO langsung
4. **Cubit tidak boleh import BuildContext** — logic murni tanpa Flutter UI dependency
5. **Setiap fitur wajib punya 3 folder**: `screens/` · `cubit/` · `repository/`
6. **Selalu gunakan Drift** untuk semua operasi database — jangan `sqflite` langsung
7. **Semua harga dalam `int`** (Rupiah) — jangan `double`
8. **GoRouter** untuk semua navigasi — jangan `Navigator.push` langsung
9. **Bahasa Indonesia** untuk semua teks UI yang tampil ke pengguna
10. Semua screen harus punya **empty state** dan **error state**
11. Semua operasi async di Cubit harus wrap `try/catch` dan emit error state
12. Format angka selalu pakai `formatRupiah()` dari `currency_formatter.dart`
13. Warna selalu ambil dari `AppColors` — jangan hardcode hex di widget
14. Setelah buat atau edit file Freezed, selalu jalankan `build_runner`
