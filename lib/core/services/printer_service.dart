import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/utils/currency_formatter.dart';
import 'package:kasir_rakyat/features/pos/models/payment_method.dart';
import 'package:kasir_rakyat/features/pos/models/receipt_data.dart';

class PrinterService {
  static Future<void> printReceipt({
    required BuildContext context,
    required ReceiptData data,
  }) async {
    final device = await _showDevicePicker(context);
    if (device == null || !context.mounted) return;

    ReceiptController? controller;
    final completer = Completer<void>();

    final overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: -10000,
        top: -10000,
        child: Material(
          child: Receipt(
            builder: (ctx) => _ThermalReceiptWidget(data: data),
            onInitialized: (c) {
              controller = c;
              if (!completer.isCompleted) completer.complete();
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    try {
      await completer.future.timeout(const Duration(seconds: 3));
      await Future.delayed(const Duration(milliseconds: 500));

      // Bypass controller.print() because ReceiptState.print() sets
      // maxBufferSize to the entire PNG size, overflowing the printer buffer.
      // Instead, get the image bytes and call printImageSingle directly
      // with a proper maxBufferSize for chunked sending.
      final imageBytes = await controller!.getImageBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final imageWidth = frame.image.width;
      final imageHeight = frame.image.height;
      frame.image.dispose();

      await FlutterBluetoothPrinter.printImageSingle(
        address: device.address,
        imageBytes: imageBytes,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        paperSize: PaperSize.mm58,
        cutPaper: false,
        keepConnected: false,
        maxBufferSize: 512,
        delayTime: 120,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak: ${e.toString()}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      overlayEntry.remove();
    }
  }

  static Future<BluetoothDevice?> _showDevicePicker(BuildContext context) {
    return showModalBottomSheet<BluetoothDevice>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _DevicePickerSheet(),
    );
  }
}

class _DevicePickerSheet extends StatefulWidget {
  const _DevicePickerSheet();

  @override
  State<_DevicePickerSheet> createState() => _DevicePickerSheetState();
}

class _DevicePickerSheetState extends State<_DevicePickerSheet> {
  List<BluetoothDevice> _devices = [];
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _devices = [];
      _scanning = true;
    });
    try {
      FlutterBluetoothPrinter.discovery.listen(
        (state) {
          if (state is DiscoveryResult && mounted) {
            setState(() => _devices = state.devices);
          }
        },
        onDone: () {
          if (mounted) setState(() => _scanning = false);
        },
        onError: (_) {
          if (mounted) setState(() => _scanning = false);
        },
      );
    } catch (_) {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Pilih Printer Bluetooth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_scanning)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                GestureDetector(
                  onTap: _scan,
                  child: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_devices.isEmpty && !_scanning)
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              children: [
                Icon(Icons.bluetooth_disabled, size: 40, color: AppColors.border),
                SizedBox(height: 10),
                Text(
                  'Tidak ada printer ditemukan.\nPastikan printer Bluetooth sudah dinyalakan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: _devices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  leading: const Icon(
                    Icons.print_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  title: Text(
                    device.name ?? 'Printer Tidak Dikenal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    device.address,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  onTap: () => Navigator.of(context).pop(device),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Minimal Flutter widget rendered to the thermal printer (48mm / 58mm paper)
// Paper width: 360 dots. Font sizes must be large enough for thermal resolution.
class _ThermalReceiptWidget extends StatelessWidget {
  final ReceiptData data;

  const _ThermalReceiptWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
              _center(_bold(data.storeName, 28)),
              const SizedBox(height: 2),
              _center(_text(data.storeAddress, 22)),
              if (data.storePhone.isNotEmpty) _center(_text(data.storePhone, 22)),
              const SizedBox(height: 10),
              _dashedDivider(),
              const SizedBox(height: 8),
              _row(_text('ID Transaksi', 18), _text('Tanggal', 18)),
              const SizedBox(height: 2),
              _row(
                Flexible(child: _bold(data.transactionId, 20)),
                _text(_formatDate(data.createdAt), 20),
              ),
              const SizedBox(height: 8),
              _dashedDivider(),
              const SizedBox(height: 8),
              ...data.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(_bold(item.name, 22), _bold(formatRupiah(item.subtotal), 22)),
                      const SizedBox(height: 2),
                      _text('${item.quantity} x ${formatRupiah(item.unitPrice)}', 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _dashedDivider(),
              const SizedBox(height: 8),
              _row(_text('Subtotal', 22), _text(formatRupiah(data.subtotal), 22)),
              const SizedBox(height: 4),
              _row(_text('Pajak (10%)', 22), _text(formatRupiah(data.tax), 22)),
              const SizedBox(height: 6),
              _row(_bold('TOTAL', 26), _bold(formatRupiah(data.total), 26)),
              const SizedBox(height: 8),
              _dashedDivider(),
              const SizedBox(height: 8),
              _row(
                _text(data.paymentMethod.label, 22),
                _bold(formatRupiah(data.amountPaid), 22),
              ),
              if (data.paymentMethod == PaymentMethod.tunai) ...[
                const SizedBox(height: 4),
                _row(_text('Kembalian', 22), _bold(formatRupiah(data.change), 22)),
              ],
              const SizedBox(height: 12),
              _dashedDivider(),
              const SizedBox(height: 10),
              _center(_bold('Terima kasih!', 24)),
              const SizedBox(height: 4),
              _center(_text('KasirRakyat — Solusi Digital UMKM', 18)),
              const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _center(Widget child) => Align(alignment: Alignment.center, child: child);

  Widget _dashedDivider() => Text(
        '--------------------------------',
        style: const TextStyle(fontSize: 20, color: Colors.black, letterSpacing: 2),
        maxLines: 1,
        overflow: TextOverflow.clip,
      );

  Widget _row(Widget left, Widget right) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (left is Flexible) left else Flexible(child: left),
          const SizedBox(width: 8),
          right,
        ],
      );

  Widget _text(String s, double size) => Text(
        s,
        style: TextStyle(fontSize: size, color: Colors.black),
      );

  Widget _bold(String s, double size) => Text(
        s,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
