import 'package:kasir_rakyat/features/settings/models/printer_settings.dart';
import 'package:kasir_rakyat/features/settings/models/store_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository._();
  static final SettingsRepository instance = SettingsRepository._();

  static const _kStoreName = 'store_name';
  static const _kStoreAddress = 'store_address';
  static const _kStorePhone = 'store_phone';
  static const _kOwnerName = 'owner_name';
  static const _kNotifLowStock = 'notif_low_stock';
  static const _kPrintReceiptAuto = 'print_receipt_auto';
  static const _kPrinterAddress = 'printer_address';
  static const _kPrinterName = 'printer_name';
  static const _kPrinterPaperSize = 'printer_paper_size';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  StoreProfile getProfileSync() {
    return StoreProfile(
      name: _prefs.getString(_kStoreName) ?? 'Toko Saya',
      address: _prefs.getString(_kStoreAddress),
      phone: _prefs.getString(_kStorePhone),
      ownerName: _prefs.getString(_kOwnerName),
    );
  }

  Future<StoreProfile> getProfile() async => getProfileSync();

  Future<void> saveProfile(StoreProfile profile) async {
    await _prefs.setString(_kStoreName, profile.name);
    if (profile.address != null) {
      await _prefs.setString(_kStoreAddress, profile.address!);
    }
    if (profile.phone != null) {
      await _prefs.setString(_kStorePhone, profile.phone!);
    }
    if (profile.ownerName != null) {
      await _prefs.setString(_kOwnerName, profile.ownerName!);
    }
  }

  Future<bool> getNotifLowStock() async =>
      _prefs.getBool(_kNotifLowStock) ?? false;

  Future<bool> getPrintReceiptAuto() async =>
      _prefs.getBool(_kPrintReceiptAuto) ?? true;

  Future<void> setNotifLowStock(bool value) async {
    await _prefs.setBool(_kNotifLowStock, value);
  }

  Future<void> setPrintReceiptAuto(bool value) async {
    await _prefs.setBool(_kPrintReceiptAuto, value);
  }

  PrinterSettings? getPrinterSettingsSync() {
    final address = _prefs.getString(_kPrinterAddress);
    if (address == null || address.isEmpty) return null;
    final name = _prefs.getString(_kPrinterName) ?? 'Printer';
    final paperSizeRaw = _prefs.getString(_kPrinterPaperSize) ?? 'mm58';
    final paperSize = paperSizeRaw == 'mm80'
        ? ThermalPaperSize.mm80
        : ThermalPaperSize.mm58;
    return PrinterSettings(address: address, name: name, paperSize: paperSize);
  }

  Future<PrinterSettings?> getPrinterSettings() async =>
      getPrinterSettingsSync();

  Future<void> savePrinterSettings(PrinterSettings settings) async {
    await _prefs.setString(_kPrinterAddress, settings.address);
    await _prefs.setString(_kPrinterName, settings.name);
    await _prefs.setString(_kPrinterPaperSize, settings.paperSize.name);
  }

  Future<void> clearPrinterSettings() async {
    await _prefs.remove(_kPrinterAddress);
    await _prefs.remove(_kPrinterName);
    await _prefs.remove(_kPrinterPaperSize);
  }
}
