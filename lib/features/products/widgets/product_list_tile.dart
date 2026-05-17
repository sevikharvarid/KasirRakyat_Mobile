import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/models/product.dart';
import 'package:kasir_rakyat/core/utils/currency_formatter.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isOutOfStock => product.stock == 0;
  bool get _isLowStock => product.stock > 0 && product.stock <= product.minStock;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _Thumbnail(imageUrl: product.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StockBadge(product: product, isOutOfStock: _isOutOfStock, isLowStock: _isLowStock),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(product.sellPrice),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _isOutOfStock ? AppColors.textSecondary : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            _MenuButton(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imageUrl;

  const _Thumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 64,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFEDF3EB),
        child: const Center(
          child: Icon(Icons.image_outlined, color: AppColors.border, size: 24),
        ),
      );
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
      label = 'LIMIT';
    } else {
      bg = AppColors.stockOkBg;
      textColor = AppColors.stockOkText;
      label = 'STOK ${product.stock}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuButton({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Text('Edit Produk', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
              SizedBox(width: 10),
              Text('Hapus', style: TextStyle(fontSize: 14, color: AppColors.danger)),
            ],
          ),
        ),
      ],
    );
  }
}
