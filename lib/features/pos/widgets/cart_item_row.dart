import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/utils/currency_formatter.dart';
import 'package:kasir_rakyat/features/pos/cubit/cart_state.dart';

class CartItemRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;
  final int maxStock;

  const CartItemRow({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
    required this.maxStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _Thumbnail(imageUrl: item.product.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(item.product.sellPrice),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QuantityStepper(
            quantity: item.quantity,
            maxStock: maxStock,
            onAdd: onAdd,
            onRemove: onRemove,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 22),
          ),
        ],
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

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEDF3EB),
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.border, size: 24),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final int maxStock;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityStepper({
    required this.quantity,
    required this.maxStock,
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
          _StepBtn(onTap: onRemove, icon: Icons.remove, isAdd: false),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StepBtn(onTap: quantity >= maxStock ? null : onAdd, icon: Icons.add, isAdd: true),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final bool isAdd;

  const _StepBtn({required this.onTap, required this.icon, required this.isAdd});

  @override
  Widget build(BuildContext context) {
    final disabled = isAdd && onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: disabled ? AppColors.border : (isAdd ? AppColors.primary : Colors.white),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1)),
          ],
        ),
        child: Icon(icon, size: 14, color: disabled ? AppColors.textTertiary : (isAdd ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}
