import 'package:kasir_rakyat/features/settings/models/printer_settings.dart';

class PrinterDeviceInfo {
  final String address;
  final String name;

  const PrinterDeviceInfo({required this.address, required this.name});

  @override
  bool operator ==(Object other) =>
      other is PrinterDeviceInfo && other.address == address;

  @override
  int get hashCode => address.hashCode;
}

class PrinterSetupState {
  final List<PrinterDeviceInfo> devices;
  final bool isScanning;
  final PrinterDeviceInfo? selectedDevice;
  final ThermalPaperSize paperSize;
  final bool isTesting;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const PrinterSetupState({
    this.devices = const [],
    this.isScanning = true,
    this.selectedDevice,
    this.paperSize = ThermalPaperSize.mm58,
    this.isTesting = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  PrinterSetupState copyWith({
    List<PrinterDeviceInfo>? devices,
    bool? isScanning,
    PrinterDeviceInfo? Function()? selectedDevice,
    ThermalPaperSize? paperSize,
    bool? isTesting,
    bool? isSaving,
    String? Function()? errorMessage,
    String? Function()? successMessage,
  }) {
    return PrinterSetupState(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      selectedDevice:
          selectedDevice != null ? selectedDevice() : this.selectedDevice,
      paperSize: paperSize ?? this.paperSize,
      isTesting: isTesting ?? this.isTesting,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
    );
  }
}
