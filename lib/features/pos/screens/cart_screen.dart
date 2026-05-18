import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/services/app_data_store.dart';
import 'package:kasir_rakyat/core/utils/currency_formatter.dart';
import 'package:kasir_rakyat/features/pos/cubit/cart_cubit.dart';
import 'package:kasir_rakyat/features/pos/cubit/cart_state.dart';
import 'package:kasir_rakyat/features/pos/models/payment_method.dart';
import 'package:kasir_rakyat/features/pos/models/receipt_data.dart';
import 'package:kasir_rakyat/features/pos/screens/receipt_screen.dart';
import 'package:kasir_rakyat/features/pos/widgets/cart_item_row.dart';
import 'package:kasir_rakyat/features/settings/repository/settings_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PaymentMethod _method = PaymentMethod.tunai;
  int _amountReceived = 0;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  static int _tax(int subtotal) => (subtotal * 11 / 100).round();
  static int _total(int subtotal) => subtotal + _tax(subtotal);
  int _change(int total) =>
      _amountReceived >= total ? _amountReceived - total : 0;

  bool _canPay(CartState state) {
    if (state.items.isEmpty) return false;
    if (_method == PaymentMethod.tunai) {
      return _amountReceived >= _total(state.totalAmount);
    }
    return true;
  }

  void _onAmountChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() => _amountReceived = int.tryParse(digits) ?? 0);
  }

  void _onPay(BuildContext context, CartState state) {
    final subtotal = state.totalAmount;
    final tax = _tax(subtotal);
    final total = _total(subtotal);
    final change = _change(total);
    final now = DateTime.now();
    final id =
        'TRX-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}';

    final profile = SettingsRepository.instance.getProfileSync();

    final receiptData = ReceiptData(
      transactionId: id,
      createdAt: now,
      storeName: profile.name,
      storeAddress: profile.address ?? '',
      storePhone: profile.phone ?? '',
      items: state.items
          .map(
            (item) => ReceiptItem(
              name: item.product.name,
              quantity: item.quantity,
              unitPrice: item.product.sellPrice,
              subtotal: item.subtotal,
            ),
          )
          .toList(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      paymentMethod: _method,
      amountPaid: _method == PaymentMethod.tunai ? _amountReceived : total,
      change: change,
    );

    // Record transaction to shared store so Reports can read real data
    AppDataStore.instance.recordTransaction(
      AppTransaction(
        id: id,
        createdAt: now,
        items: state.items
            .map(
              (item) => AppTxItem(
                productId: item.product.id,
                productName: item.product.name,
                unitPrice: item.product.sellPrice,
                buyPrice: item.product.buyPrice,
                quantity: item.quantity,
                subtotal: item.subtotal,
              ),
            )
            .toList(),
        subtotal: subtotal,
        tax: tax,
        total: total,
        paymentMethod: _method,
        amountPaid: _method == PaymentMethod.tunai ? _amountReceived : total,
        change: change,
      ),
    );

    context.read<CartCubit>().clearCart();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ReceiptScreen(data: receiptData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      appBar: _CartAppBar(),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final subtotal = state.totalAmount;
          final tax = _tax(subtotal);
          final total = _total(subtotal);
          final change = _change(total);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CartHeader(totalItems: state.totalItems),
                      const SizedBox(height: 12),
                      _ItemsList(state: state),
                      const SizedBox(height: 20),
                      _PaymentMethodSection(
                        selected: _method,
                        onSelect: (m) => setState(() {
                          _method = m;
                          _amountReceived = 0;
                          _amountController.clear();
                        }),
                      ),
                      if (_method == PaymentMethod.tunai) ...[
                        const SizedBox(height: 16),
                        _AmountSection(
                          controller: _amountController,
                          change: change,
                          onChanged: _onAmountChanged,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _OrderSummary(
                        subtotal: subtotal,
                        tax: tax,
                        total: total,
                        canPay: _canPay(state),
                        onPay: () => _onPay(context, state),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartAppBar extends StatelessWidget implements PreferredSizeWidget {
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
          title: Image.asset(
            'assets/images/app_logo.png',
            height: 40,
            fit: BoxFit.contain,
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
                  Icons.receipt_long_outlined,
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

class _CartHeader extends StatelessWidget {
  final int totalItems;

  const _CartHeader({required this.totalItems});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            '$totalItems Item',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemsList extends StatelessWidget {
  final CartState state;

  const _ItemsList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppColors.border,
              ),
              SizedBox(height: 12),
              Text(
                'Keranjang kosong',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return CartItemRow(
          item: item,
          maxStock: item.product.stock,
          onAdd: () => context.read<CartCubit>().addProduct(item.product),
          onRemove: () =>
              context.read<CartCubit>().removeProduct(item.product.id),
          onDelete: () => context.read<CartCubit>().deleteItem(item.product.id),
        );
      },
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelect;

  const _PaymentMethodSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'METODE PEMBAYARAN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _MethodCard(
              icon: Icons.payments_outlined,
              label: 'Tunai',
              isSelected: selected == PaymentMethod.tunai,
              onTap: () => onSelect(PaymentMethod.tunai),
            ),
            const SizedBox(width: 10),
            _MethodCard(
              icon: Icons.account_balance_outlined,
              label: 'Transfer',
              isSelected: selected == PaymentMethod.transfer,
              onTap: () => onSelect(PaymentMethod.transfer),
            ),
            const SizedBox(width: 10),
            _MethodCard(
              icon: Icons.qr_code_2_outlined,
              label: 'QRIS',
              isSelected: selected == PaymentMethod.qris,
              onTap: () => onSelect(PaymentMethod.qris),
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountSection extends StatelessWidget {
  final TextEditingController controller;
  final int change;
  final ValueChanged<String> onChanged;

  const _AmountSection({
    required this.controller,
    required this.change,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uang Diterima',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              hintText: '0',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Kembalian',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                formatRupiah(change),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final int subtotal;
  final int tax;
  final int total;
  final bool canPay;
  final VoidCallback onPay;

  const _OrderSummary({
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.canPay,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _Row(label: 'Subtotal', value: formatRupiah(subtotal)),
          const SizedBox(height: 8),
          _Row(label: 'Pajak (11%)', value: formatRupiah(tax)),
          const SizedBox(height: 8),
          _Row(
            label: 'Diskon',
            value: '- ${formatRupiah(0)}',
            valueColor: AppColors.danger,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                formatRupiah(total),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canPay ? onPay : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Pastikan nominal pembayaran sudah sesuai.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
