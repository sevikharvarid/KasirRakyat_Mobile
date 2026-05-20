import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/core/services/thermal_print_helper.dart';
import 'package:kasir_rakyat/features/pos/models/receipt_data.dart';
import 'package:kasir_rakyat/features/settings/repository/settings_repository.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterService {
  static Future<void> printReceipt({
    required BuildContext context,
    required ReceiptData data,
  }) async {
    final settings = SettingsRepository.instance.getPrinterSettingsSync();
    if (settings == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Belum ada printer default. Atur di Pengaturan → Pengaturan Printer.',
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Mengirim ke ${settings.name}...'),
              ],
            ),
            duration: const Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      final bytes = await ThermalPrintHelper.buildReceiptBytes(
        data: data,
        paperSize: settings.paperSize,
      );
      await _send(address: settings.address, bytes: bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Struk berhasil dicetak'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> _send({
    required String address,
    required List<int> bytes,
  }) async {
    final connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: address,
    );
    if (!connected) throw Exception('Tidak dapat terhubung ke printer');

    final ok = await PrintBluetoothThermal.writeBytes(bytes);
    await PrintBluetoothThermal.disconnect;

    if (!ok) throw Exception('Gagal mengirim data ke printer');
  }
}
