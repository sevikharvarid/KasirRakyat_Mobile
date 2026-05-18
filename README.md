# KasirRakyat

> **Kasir Cepat, Usaha Lancar**

Aplikasi kasir mobile **offline-first** untuk UMKM Indonesia — warung, toko kecil, dan pedagang. Dibangun dengan Flutter, berjalan penuh tanpa koneksi internet menggunakan SQLite lokal.

---

## Fitur Utama

- **POS (Point of Sale)** — Grid produk, filter kategori, pencarian, scan barcode
- **Keranjang Belanja** — Tambah/kurang item, diskon, catatan transaksi
- **Pembayaran** — Tunai (hitung kembalian otomatis), transfer, QRIS
- **Struk Digital** — Preview, share WhatsApp, cetak via Bluetooth
- **Manajemen Produk** — CRUD produk, foto, kategori, stok awal
- **Laporan Harian** — Omzet, jumlah transaksi, produk terlaris
- **Multi User** — Role owner & kasir dengan PIN login
- **Pengaturan Toko** — Profil toko, setup printer

---

## Tech Stack

| Kebutuhan | Package | Versi |
|---|---|---|
| State management | `flutter_bloc` | ^8.x |
| State immutability | `freezed` + `freezed_annotation` | ^2.x |
| Code generation | `build_runner` | ^2.x |
| Navigasi | `go_router` | ^13.x |
| Bluetooth printer | `flutter_bluetooth_printer` | ^2.x |
| Grafik laporan | `fl_chart` | ^0.68.x |
| Export file | `path_provider` + `share_plus` | latest |
| Image picker | `image_picker` | ^1.x |
| Format angka | `intl` | ^0.19.x |
| Dependency injection | `get_it` | ^7.x |
| Preferensi lokal | `shared_preferences` | ^2.x |
| Loading shimmer | `shimmer` | ^3.x |

---

## Arsitektur

Proyek menggunakan pola **Cubit + Freezed + Repository**:

```
Screen (UI)
  └── BlocBuilder / BlocListener
        └── Cubit (logic)
              └── Repository
                    └── DAO (Drift/SQLite)
```

Setiap fitur wajib memiliki 3 folder:

- `screens/` — UI layer
- `cubit/` — State management (Freezed state)
- `repository/` — Akses data (melalui DAO)

---

## Struktur Folder

```
lib/
├── main.dart
├── app.dart                    # Root widget & router
├── injection.dart              # Dependency injection (get_it)
├── core/
│   ├── constants/              # Warna, tipografi, konstanta app
│   ├── models/
│   ├── services/
│   ├── shell/
│   ├── utils/                  # currency_formatter, date_formatter, validators
│   └── widgets/                # Shared widgets (KrButton, KrCard, dll.)
└── features/
    ├── auth/                   # Splash, onboarding, setup toko, PIN login
    ├── pos/                    # Layar kasir, keranjang, pembayaran, struk
    ├── products/               # Manajemen produk & kategori
    ├── inventory/              # Stok & riwayat mutasi
    ├── reports/                # Laporan penjualan & grafik
    └── settings/               # Profil toko, user, printer
```

---

## Memulai

### Prasyarat

- Flutter SDK `>=3.11.0`
- Dart SDK `<4.0.0`
- Android Studio / Xcode (untuk build ke device)

### Instalasi

```bash
# Clone repo
git clone <repo-url>
cd kasir_rakyat

# Install dependencies
flutter pub get

# Jalankan code generation (Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# Jalankan aplikasi
flutter run
```

---

## Konvensi Kode

- **Harga** disimpan sebagai `int` (Rupiah penuh) — bukan `double`
- **Format Rupiah** selalu via `formatRupiah()` → `Rp 10.000`
- **Warna** diambil dari `AppColors` — tidak hardcode hex di widget
- **Navigasi** via `GoRouter` — tidak pakai `Navigator.push` langsung
- **Teks UI** dalam Bahasa Indonesia
- State Freezed: selalu gunakan `.when()` di `BlocBuilder`

---

## Roadmap

### MVP v1.0

- [ ] Splash screen & onboarding
- [ ] Setup toko & PIN login
- [ ] POS: grid produk, filter, search, barcode scan
- [ ] Keranjang & pembayaran
- [ ] Struk digital (share & cetak)
- [ ] Manajemen produk
- [ ] Laporan harian
- [ ] Pengaturan toko

### v1.1

- [ ] Export laporan PDF
- [ ] Notifikasi stok menipis
- [ ] Riwayat mutasi stok
- [ ] Multi user & role

### v1.2

- [ ] Laporan mingguan & bulanan dengan grafik
- [ ] Stok opname
- [ ] Backup & restore database
- [ ] Varian produk

### v2.0

- [ ] Utang piutang pelanggan
- [ ] Sinkronisasi cloud
- [ ] Web dashboard owner

---

## Platform

| Platform | Status |
|---|---|
| Android | ✅ Didukung |
| iOS | ✅ Didukung |
| Web | ❌ Tidak didukung (SQLite lokal) |
