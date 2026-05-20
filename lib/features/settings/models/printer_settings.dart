enum ThermalPaperSize {
  mm58('58mm'),
  mm80('80mm');

  const ThermalPaperSize(this.label);
  final String label;
}

class PrinterSettings {
  final String address;
  final String name;
  final ThermalPaperSize paperSize;

  const PrinterSettings({
    required this.address,
    required this.name,
    this.paperSize = ThermalPaperSize.mm58,
  });

  PrinterSettings copyWith({
    String? address,
    String? name,
    ThermalPaperSize? paperSize,
  }) {
    return PrinterSettings(
      address: address ?? this.address,
      name: name ?? this.name,
      paperSize: paperSize ?? this.paperSize,
    );
  }
}
