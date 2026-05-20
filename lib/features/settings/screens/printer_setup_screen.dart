import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/features/settings/cubit/printer_setup_cubit.dart';
import 'package:kasir_rakyat/features/settings/cubit/printer_setup_state.dart';
import 'package:kasir_rakyat/features/settings/models/printer_settings.dart';
import 'package:kasir_rakyat/features/settings/repository/settings_repository.dart';

class PrinterSetupScreen extends StatelessWidget {
  const PrinterSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = SettingsRepository.instance.getProfileSync();
    return BlocProvider(
      create: (_) => PrinterSetupCubit(
        SettingsRepository.instance,
        storeName: profile.name,
      )..init(),
      child: const _PrinterSetupView(),
    );
  }
}

class _PrinterSetupView extends StatelessWidget {
  const _PrinterSetupView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: Column(
        children: [
          const _AppBar(),
          Expanded(
            child: BlocConsumer<PrinterSetupCubit, PrinterSetupState>(
              listener: (context, state) {
                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    _DefaultPrinterCard(state: state),
                    const SizedBox(height: 20),
                    _PaperSizeSection(paperSize: state.paperSize),
                    const SizedBox(height: 20),
                    _ScanSection(state: state),
                    const SizedBox(height: 20),
                    _ActionButtons(state: state),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primarySurface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                const Text(
                  'Pengaturan Printer',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultPrinterCard extends StatelessWidget {
  final PrinterSetupState state;

  const _DefaultPrinterCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final device = state.selectedDevice;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: device != null ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: device != null ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: device != null
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.print_outlined,
              color: device != null ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device != null ? 'Printer Default' : 'Belum Ada Printer Default',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: device != null ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  device?.name ?? 'Pilih printer dari daftar di bawah',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: device != null ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (device != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    device.address,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ],
            ),
          ),
          if (device != null)
            GestureDetector(
              onTap: () => context.read<PrinterSetupCubit>().removeDefault(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaperSizeSection extends StatelessWidget {
  final ThermalPaperSize paperSize;

  const _PaperSizeSection({required this.paperSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Ukuran Kertas'),
        const SizedBox(height: 10),
        Row(
          children: ThermalPaperSize.values.map((size) {
            final selected = paperSize == size;
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    context.read<PrinterSetupCubit>().setPaperSize(size),
                child: Container(
                  margin: EdgeInsets.only(
                    right: size == ThermalPaperSize.mm58 ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        size.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        size == ThermalPaperSize.mm58
                            ? 'Standar (paling umum)'
                            : 'Lebar (struk besar)',
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ScanSection extends StatelessWidget {
  final PrinterSetupState state;

  const _ScanSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionLabel('Printer Tersedia'),
            const Spacer(),
            if (state.isScanning)
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Mencari...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: () => context.read<PrinterSetupCubit>().startScan(),
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Cari Ulang',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: state.devices.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    children: [
                      Icon(
                        state.isScanning
                            ? Icons.bluetooth_searching
                            : Icons.bluetooth_disabled,
                        size: 40,
                        color: AppColors.border,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.isScanning
                            ? 'Sedang mencari printer Bluetooth...'
                            : 'Tidak ada printer ditemukan.\nPastikan printer sudah dipasangkan di pengaturan Bluetooth ponsel Anda.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < state.devices.length; i++) ...[
                      _DeviceTile(
                        device: state.devices[i],
                        isSelected:
                            state.selectedDevice?.address == state.devices[i].address,
                      ),
                      if (i < state.devices.length - 1)
                        const Divider(
                          height: 1,
                          indent: 54,
                          color: AppColors.border,
                        ),
                    ],
                  ],
                ),
        ),
        if (state.devices.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Hanya printer yang sudah dipasangkan muncul di sini. Untuk menambah printer baru, hubungkan melalui Pengaturan Bluetooth di ponsel Anda.',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final PrinterDeviceInfo device;
  final bool isSelected;

  const _DeviceTile({required this.device, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<PrinterSetupCubit>().selectDevice(device),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.print_outlined,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name.isNotEmpty ? device.name : 'Printer Tidak Dikenal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: AppColors.border,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final PrinterSetupState state;

  const _ActionButtons({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasDevice = state.selectedDevice != null;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: hasDevice && !state.isTesting && !state.isSaving
                ? () => context.read<PrinterSetupCubit>().testPrint()
                : null,
            icon: state.isTesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print_outlined, color: Colors.white, size: 20),
            label: Text(
              state.isTesting ? 'Mencetak...' : 'Test Print',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              disabledBackgroundColor: AppColors.border,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: hasDevice && !state.isSaving && !state.isTesting
                ? () async {
                    await context.read<PrinterSetupCubit>().saveAsDefault();
                    if (context.mounted) Navigator.of(context).pop(true);
                  }
                : null,
            icon: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, color: Colors.white, size: 20),
            label: Text(
              state.isSaving ? 'Menyimpan...' : 'Jadikan Default',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.border,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}
