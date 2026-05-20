import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:kasir_rakyat/core/utils/currency_formatter.dart';
import 'package:kasir_rakyat/features/pos/models/payment_method.dart';
import 'package:kasir_rakyat/features/pos/models/receipt_data.dart';
import 'package:kasir_rakyat/features/settings/models/printer_settings.dart';

class ThermalPrintHelper {
  static Future<List<int>> buildReceiptBytes({
    required ReceiptData data,
    required ThermalPaperSize paperSize,
  }) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(
      paperSize == ThermalPaperSize.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];

    // Store header
    bytes += gen.text(
      data.storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    if (data.storeAddress.isNotEmpty) {
      bytes += gen.text(
        data.storeAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (data.storePhone.isNotEmpty) {
      bytes += gen.text(
        data.storePhone,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += gen.hr();

    // Transaction info
    bytes += gen.row([
      PosColumn(text: 'No: ${data.transactionId}', width: 7),
      PosColumn(
        text: _formatDate(data.createdAt),
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += gen.hr();

    // Items
    for (final item in data.items) {
      bytes += gen.row([
        PosColumn(
          text: item.name,
          width: 7,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: formatRupiah(item.subtotal),
          width: 5,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += gen.text(
        '  ${item.quantity} x ${formatRupiah(item.unitPrice)}',
        styles: const PosStyles(fontType: PosFontType.fontB),
      );
    }

    bytes += gen.hr();

    // Totals
    bytes += gen.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(
        text: formatRupiah(data.subtotal),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    if (data.tax > 0) {
      bytes += gen.row([
        PosColumn(text: 'Pajak (10%)', width: 6),
        PosColumn(
          text: formatRupiah(data.tax),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += gen.row([
      PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: formatRupiah(data.total),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    ]);

    bytes += gen.hr();

    // Payment
    bytes += gen.row([
      PosColumn(text: data.paymentMethod.label, width: 6),
      PosColumn(
        text: formatRupiah(data.amountPaid),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    if (data.paymentMethod == PaymentMethod.tunai && data.change > 0) {
      bytes += gen.row([
        PosColumn(text: 'Kembalian', width: 6),
        PosColumn(
          text: formatRupiah(data.change),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
    }

    bytes += gen.hr();
    bytes += gen.text(
      'Terima kasih!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += gen.text(
      'KasirRakyat — Solusi Digital UMKM',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += gen.feed(3);
    bytes += gen.cut();

    return bytes;
  }

  static Future<List<int>> buildTestPrintBytes({
    required String storeName,
    required ThermalPaperSize paperSize,
  }) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(
      paperSize == ThermalPaperSize.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];

    bytes += gen.text(
      '--- TEST PRINT ---',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += gen.hr();
    bytes += gen.text(
      storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += gen.text(
      'KasirRakyat v1.0',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += gen.hr();
    bytes += gen.text(
      'Printer terhubung!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += gen.text(
      'Ukuran kertas: ${paperSize.label}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += gen.feed(3);
    bytes += gen.cut();

    return bytes;
  }

  static String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }
}
