import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/services/thermal_print_helper.dart';
import 'package:kasir_rakyat/features/settings/cubit/printer_setup_state.dart';
import 'package:kasir_rakyat/features/settings/models/printer_settings.dart';
import 'package:kasir_rakyat/features/settings/repository/settings_repository.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterSetupCubit extends Cubit<PrinterSetupState> {
  final SettingsRepository _repository;
  final String storeName;

  Timer? _scanTimer;
  static const _scanInterval = Duration(seconds: 4);
  static const _scanTimeout = Duration(seconds: 30);

  PrinterSetupCubit(this._repository, {required this.storeName})
      : super(const PrinterSetupState());

  Future<void> init() async {
    final saved = _repository.getPrinterSettingsSync();
    PrinterDeviceInfo? selected;
    ThermalPaperSize paperSize = ThermalPaperSize.mm58;
    if (saved != null) {
      selected = PrinterDeviceInfo(address: saved.address, name: saved.name);
      paperSize = saved.paperSize;
    }
    emit(state.copyWith(
      selectedDevice: () => selected,
      paperSize: paperSize,
    ));
    await startScan();
  }

  Future<void> startScan() async {
    _scanTimer?.cancel();
    emit(state.copyWith(isScanning: true, errorMessage: () => null));

    await _fetchDevices();

    // Keep refreshing so newly paired devices appear automatically
    _scanTimer = Timer.periodic(_scanInterval, (_) async {
      if (!isClosed) await _fetchDevices();
    });

    // Stop scanning after timeout
    Timer(_scanTimeout, stopScan);
  }

  void stopScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
    if (!isClosed) emit(state.copyWith(isScanning: false));
  }

  Future<void> _fetchDevices() async {
    try {
      final paired = await PrintBluetoothThermal.pairedBluetooths;
      if (isClosed) return;
      final devices = paired
          .map((d) => PrinterDeviceInfo(address: d.macAdress, name: d.name))
          .toList();
      emit(state.copyWith(devices: devices, isScanning: false));
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isScanning: false,
          errorMessage: () => 'Gagal memindai: $e',
        ));
      }
    }
  }

  void selectDevice(PrinterDeviceInfo device) {
    emit(state.copyWith(selectedDevice: () => device));
  }

  void setPaperSize(ThermalPaperSize size) {
    emit(state.copyWith(paperSize: size));
  }

  Future<void> saveAsDefault() async {
    final device = state.selectedDevice;
    if (device == null) return;

    emit(state.copyWith(isSaving: true, successMessage: () => null, errorMessage: () => null));
    try {
      final settings = PrinterSettings(
        address: device.address,
        name: device.name,
        paperSize: state.paperSize,
      );
      await _repository.savePrinterSettings(settings);
      emit(state.copyWith(
        isSaving: false,
        successMessage: () => 'Printer "${device.name}" disimpan sebagai default',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: () => 'Gagal menyimpan: $e',
      ));
    }
  }

  Future<void> testPrint() async {
    final device = state.selectedDevice;
    if (device == null) return;

    emit(state.copyWith(isTesting: true, successMessage: () => null, errorMessage: () => null));
    try {
      final bytes = await ThermalPrintHelper.buildTestPrintBytes(
        storeName: storeName,
        paperSize: state.paperSize,
      );

      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.address,
      );
      if (!connected) throw Exception('Tidak dapat terhubung ke printer');

      final ok = await PrintBluetoothThermal.writeBytes(bytes);
      await PrintBluetoothThermal.disconnect;

      if (!ok) throw Exception('Gagal mengirim data ke printer');

      emit(state.copyWith(
        isTesting: false,
        successMessage: () => 'Test print berhasil!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isTesting: false,
        errorMessage: () => 'Test print gagal: $e',
      ));
    }
  }

  Future<void> removeDefault() async {
    await _repository.clearPrinterSettings();
    emit(state.copyWith(selectedDevice: () => null));
  }

  @override
  Future<void> close() {
    _scanTimer?.cancel();
    return super.close();
  }
}
