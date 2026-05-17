import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/features/products/cubit/products_cubit.dart';
import 'package:kasir_rakyat/features/products/cubit/products_state.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  bool get isEditing => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _buyPriceController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _barcodeController;
  int? _selectedCategoryId;
  String _selectedUnit = 'pcs';
  late final TextEditingController _customUnitController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _buyPriceController = TextEditingController(text: p != null ? '${p.buyPrice}' : '');
    _sellPriceController = TextEditingController(text: p != null ? '${p.sellPrice}' : '');
    _stockController = TextEditingController(text: p != null ? '${p.stock}' : '0');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _selectedCategoryId = p?.categoryId;
    // Resolve initial unit: preset or custom
    final savedUnit = p?.unit ?? 'pcs';
    final isPreset = _UnitSelector.presetUnits.any((u) => u.value == savedUnit);
    _selectedUnit = isPreset ? savedUnit : _UnitSelector.kOtherValue;
    _customUnitController = TextEditingController(text: isPreset ? '' : savedUnit);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama produk wajib diisi.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Resolve the actual unit string
      final unit = _selectedUnit == _UnitSelector.kOtherValue
          ? (_customUnitController.text.trim().isEmpty ? 'pcs' : _customUnitController.text.trim())
          : _selectedUnit;
      final product = Product(
        id: widget.product?.id ?? 0,
        name: name,
        categoryId: _selectedCategoryId,
        buyPrice: int.tryParse(_buyPriceController.text) ?? 0,
        sellPrice: int.tryParse(_sellPriceController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        minStock: widget.product?.minStock ?? 5,
        unit: unit,
        barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      );
      await context.read<ProductsCubit>().saveProduct(product);
      if (context.mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _FormAppBar(isEditing: widget.isEditing),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PhotoUploader(),
                    const SizedBox(height: 20),
                    _FieldLabel('Nama Produk'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _nameController,
                      hint: 'Contoh: Kopi Gula Aren',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Harga Modal'),
                              const SizedBox(height: 8),
                              _PriceField(controller: _buyPriceController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Harga Jual'),
                              const SizedBox(height: 8),
                              _PriceField(controller: _sellPriceController),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Stok Awal'),
                              const SizedBox(height: 8),
                              _NumberField(controller: _stockController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Kategori'),
                              const SizedBox(height: 8),
                              _CategoryDropdown(
                                selectedId: _selectedCategoryId,
                                onChanged: (id) => setState(() => _selectedCategoryId = id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel('Satuan Produk'),
                    const SizedBox(height: 8),
                    _UnitSelector(
                      selected: _selectedUnit,
                      customController: _customUnitController,
                      onChanged: (v) => setState(() => _selectedUnit = v),
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel('Barcode (Opsional)'),
                    const SizedBox(height: 8),
                    _BarcodeField(controller: _barcodeController),
                    const SizedBox(height: 16),
                    const _TipsCard(),
                    const SizedBox(height: 12),
                    const _ProfitCard(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _SaveButton(isSaving: _isSaving, onSave: () => _save(context)),
          ],
        ),
      ),
    );
  }
}

class _FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditing;

  const _FormAppBar({required this.isEditing});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: AppColors.primarySurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            isEditing ? 'Edit Produk' : 'Tambah Produk',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryChipInactive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        Container(height: 1, color: AppColors.border),
      ],
    );
  }
}

class _PhotoUploader extends StatelessWidget {
  const _PhotoUploader();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryChipInactive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unggah Foto Produk',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pastikan foto produk terlihat jelas dan\nmemiliki pencahayaan yang baik.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Pilih Berkas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const radius = Radius.circular(12);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radius,
      ));

    const dashLength = 8.0;
    const gapLength = 5.0;
    final dashPath = Path();
    var distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        dashPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashLength + gapLength;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _TextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _focusBorder(),
      ),
    );
  }

  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      );

  OutlineInputBorder _focusBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      );
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;

  const _PriceField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixText: 'Rp  ',
        prefixStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        hintText: '0',
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _focusBorder(),
      ),
    );
  }

  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      );

  OutlineInputBorder _focusBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      );
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;

  const _NumberField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _focusBorder(),
      ),
    );
  }

  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      );

  OutlineInputBorder _focusBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      );
}

class _CategoryDropdown extends StatelessWidget {
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  static const _categories = [
    (id: 1, name: 'Sembako'),
    (id: 2, name: 'Minuman'),
    (id: 3, name: 'Kopi & Teh'),
    (id: 4, name: 'Snack'),
    (id: 5, name: 'Bumbu'),
  ];

  const _CategoryDropdown({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedId,
      hint: const Text(
        'Pilih Kategori',
        style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      dropdownColor: AppColors.background,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
      items: _categories
          .map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              ))
          .toList(),
    );
  }
}

class _BarcodeField extends StatelessWidget {
  final TextEditingController controller;

  const _BarcodeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Scan atau ketik barcode',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 48,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.barcode_reader, color: AppColors.primary, size: 22),
          ),
        ),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Stok',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Atur stok minimal agar Anda mendapat notifikasi saat barang hampir habis.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  const _ProfitCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.trending_up, color: Color(0xFFD97706), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analisis Keuntungan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD97706),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Harga modal akan membantu sistem menghitung laba bersih usaha Anda.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Unit selector
// ---------------------------------------------------------------------------

class _UnitEntry {
  final String value;
  final String label;
  const _UnitEntry(this.value, this.label);
}

class _UnitSelector extends StatelessWidget {
  static const kOtherValue = '__other__';

  /// Common Indonesian retail / warung units.
  static const presetUnits = [
    _UnitEntry('pcs',     'Pcs'),
    _UnitEntry('buah',    'Buah'),
    _UnitEntry('kg',      'Kg'),
    _UnitEntry('gram',    'Gram'),
    _UnitEntry('ons',     'Ons'),
    _UnitEntry('liter',   'Liter'),
    _UnitEntry('ml',      'mL'),
    _UnitEntry('botol',   'Botol'),
    _UnitEntry('kaleng',  'Kaleng'),
    _UnitEntry('bungkus', 'Bungkus'),
    _UnitEntry('sachet',  'Sachet'),
    _UnitEntry('pack',    'Pack'),
    _UnitEntry('lusin',   'Lusin'),
    _UnitEntry('krat',    'Krat'),
    _UnitEntry('dus',     'Dus'),
    _UnitEntry('karton',  'Karton'),
    _UnitEntry('gulung',  'Gulung'),
    _UnitEntry('lembar',  'Lembar'),
    _UnitEntry('meter',   'Meter'),
    _UnitEntry(kOtherValue, 'Lainnya...'),
  ];

  final String selected;
  final TextEditingController customController;
  final ValueChanged<String> onChanged;

  const _UnitSelector({
    required this.selected,
    required this.customController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetUnits.map((u) {
            final isActive = selected == u.value;
            return GestureDetector(
              onTap: () => onChanged(u.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  u.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Custom unit input — visible only when "Lainnya" is selected
        if (selected == kOtherValue) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: customController,
            autofocus: true,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ketik satuan, mis. "rim", "ikat", "porsi"',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const _SaveButton({required this.isSaving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined, size: 20, color: Colors.white),
            label: Text(
              isSaving ? 'Menyimpan...' : 'Simpan Produk',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.border,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
