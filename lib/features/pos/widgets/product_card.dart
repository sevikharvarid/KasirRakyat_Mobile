import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/core/utils/currency_formatter.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int cartQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.product,
    required this.cartQuantity,
    required this.onAdd,
    required this.onRemove,
  });

  bool get _isOutOfStock => product.stock == 0;
  bool get _isLowStock => product.stock > 0 && product.stock <= product.minStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageSection(product: product, isOutOfStock: _isOutOfStock, isLowStock: _isLowStock),
          _InfoSection(
            product: product,
            cartQuantity: cartQuantity,
            isOutOfStock: _isOutOfStock,
            onAdd: onAdd,
            onRemove: onRemove,
          ),
        ],
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final Product product;
  final bool isOutOfStock;
  final bool isLowStock;

  const _ImageSection({
    required this.product,
    required this.isOutOfStock,
    required this.isLowStock,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 156,
          width: double.infinity,
          child: _buildImage(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _StockBadge(product: product, isOutOfStock: isOutOfStock, isLowStock: isLowStock),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final imageChild = product.imageUrl != null
        ? Image.network(
            product.imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
          )
        : _imagePlaceholder();

    if (!isOutOfStock) return imageChild;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0,      0,      0,      0.4, 0,
      ]),
      child: imageChild,
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEDF3EB),
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.border, size: 40),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final Product product;
  final bool isOutOfStock;
  final bool isLowStock;

  const _StockBadge({
    required this.product,
    required this.isOutOfStock,
    required this.isLowStock,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final String label;

    if (isOutOfStock) {
      bg = AppColors.stockHabisBg;
      textColor = AppColors.stockHabisText;
      label = 'HABIS';
    } else if (isLowStock) {
      bg = AppColors.stockLowBg;
      textColor = AppColors.stockLowText;
      label = 'Stok: ${product.stock}';
    } else {
      bg = AppColors.stockOkBg;
      textColor = AppColors.stockOkText;
      label = 'Stok: ${product.stock}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: isOutOfStock ? 0.5 : 0,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Product product;
  final int cartQuantity;
  final bool isOutOfStock;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _InfoSection({
    required this.product,
    required this.cartQuantity,
    required this.isOutOfStock,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isOutOfStock ? 0.6 : 1.0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _categoryLabel(),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatRupiah(product.sellPrice),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock ? AppColors.textSecondary : AppColors.primary,
                    ),
                  ),
                ),
                if (isOutOfStock)
                  _DisabledButton()
                else if (cartQuantity > 0)
                  _QuantityStepper(
                    quantity: cartQuantity,
                    onAdd: onAdd,
                    onRemove: onRemove,
                  )
                else
                  _AddButton(onAdd: onAdd),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel() {
    switch (product.categoryId) {
      case 1: return 'Sembako';
      case 2: return 'Minuman';
      case 3: return 'Kopi & Teh';
      case 4: return 'Snack';
      case 5: return 'Bumbu';
      default: return '';
    }
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onAdd;

  const _AddButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 18),
      ),
    );
  }
}

class _DisabledButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF6E7B6C),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.do_not_disturb_alt_outlined, color: Colors.white, size: 18),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityStepper({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryChipInactive,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            onTap: onRemove,
            icon: Icons.remove,
            isAdd: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StepperButton(
            onTap: onAdd,
            icon: Icons.add,
            isAdd: true,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool isAdd;

  const _StepperButton({
    required this.onTap,
    required this.icon,
    required this.isAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isAdd ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1)),
          ],
        ),
        child: Icon(
          icon,
          size: 14,
          color: isAdd ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
