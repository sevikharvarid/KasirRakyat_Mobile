import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/features/settings/cubit/settings_cubit.dart';
import 'package:kasir_rakyat/features/settings/cubit/settings_state.dart';
import 'package:kasir_rakyat/features/settings/models/store_profile.dart';
import 'package:kasir_rakyat/features/settings/repository/settings_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(SettingsRepository.instance)..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: Column(
        children: [
          const _AppBar(),
          Expanded(
            child: BlocConsumer<SettingsCubit, SettingsState>(
              listener: (context, state) {
                state.whenOrNull(
                  error: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  loaded: (profile, notifLowStock, printReceiptAuto, _) =>
                      _LoadedBody(
                        profile: profile,
                        notifLowStock: notifLowStock,
                        printReceiptAuto: printReceiptAuto,
                      ),
                  error: (message) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.danger,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              context.read<SettingsCubit>().loadSettings(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMedium,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
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

class _LoadedBody extends StatelessWidget {
  final StoreProfile profile;
  final bool notifLowStock;
  final bool printReceiptAuto;

  const _LoadedBody({
    required this.profile,
    required this.notifLowStock,
    required this.printReceiptAuto,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        _StoreProfileCard(profile: profile),
        const SizedBox(height: 20),
        _SectionTitle('Toko'),
        const SizedBox(height: 10),
        _SettingsGroup(
          items: [
            _SettingsTile(
              icon: Icons.store_outlined,
              iconColor: AppColors.primary,
              title: 'Profil Toko',
              subtitle: profile.name,
              onTap: () => _showEditProfileSheet(context, profile),
            ),
            _SettingsTile(
              icon: Icons.people_outline,
              iconColor: AppColors.info,
              title: 'Kelola Pengguna',
              subtitle: 'Owner & Kasir',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.print_outlined,
              iconColor: AppColors.warning,
              title: 'Pengaturan Printer',
              subtitle: 'Bluetooth Thermal',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Notifikasi & Struk'),
        const SizedBox(height: 10),
        _SettingsGroup(
          items: [
            _SwitchTile(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.warning,
              title: 'Notifikasi Stok Menipis',
              subtitle: 'Ingatkan saat stok mendekati batas minimum',
              value: notifLowStock,
              onChanged: (v) =>
                  context.read<SettingsCubit>().toggleNotifLowStock(v),
            ),
            _SwitchTile(
              icon: Icons.receipt_outlined,
              iconColor: AppColors.info,
              title: 'Cetak Struk Otomatis',
              subtitle: 'Cetak struk langsung setelah transaksi selesai',
              value: printReceiptAuto,
              onChanged: (v) =>
                  context.read<SettingsCubit>().togglePrintReceiptAuto(v),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Data & Backup'),
        const SizedBox(height: 10),
        _SettingsGroup(
          items: [
            _SettingsTile(
              icon: Icons.upload_file_outlined,
              iconColor: AppColors.primary,
              title: 'Ekspor Laporan PDF',
              subtitle: 'Unduh laporan dalam format PDF',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.backup_outlined,
              iconColor: AppColors.info,
              title: 'Backup Database',
              subtitle: 'Simpan data ke penyimpanan lokal',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.restore_outlined,
              iconColor: AppColors.warning,
              title: 'Pulihkan Data',
              subtitle: 'Muat ulang data dari file backup',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Tentang Aplikasi'),
        const SizedBox(height: 10),
        _SettingsGroup(
          items: [
            _SettingsTile(
              icon: Icons.info_outline,
              iconColor: AppColors.primary,
              title: 'Versi Aplikasi',
              subtitle: 'v1.0.0',
              onTap: null,
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Syarat & Ketentuan',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.help_outline,
              iconColor: AppColors.textSecondary,
              title: 'Pusat Bantuan',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        _LogoutButton(),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context, StoreProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: _EditProfileSheet(profile: profile),
      ),
    );
  }
}

class _StoreProfileCard extends StatelessWidget {
  final StoreProfile profile;

  const _StoreProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (profile.ownerName != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    profile.ownerName!,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
                if (profile.address != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    profile.address!,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showEditProfileSheet(context, profile),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, StoreProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: _EditProfileSheet(profile: profile),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

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

class _SettingsGroup extends StatelessWidget {
  final List<Widget> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: 54,
                endIndent: 0,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight,
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.logout_outlined,
          size: 20,
          color: AppColors.danger,
        ),
        label: const Text(
          'Keluar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.danger,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.danger, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final StoreProfile profile;

  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ownerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _addressController = TextEditingController(
      text: widget.profile.address ?? '',
    );
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _ownerController = TextEditingController(
      text: widget.profile.ownerName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Edit Profil Toko',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _FormField(label: 'Nama Toko', controller: _nameController),
          const SizedBox(height: 14),
          _FormField(label: 'Nama Pemilik', controller: _ownerController),
          const SizedBox(height: 14),
          _FormField(
            label: 'Alamat',
            controller: _addressController,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Nomor HP',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final updated = StoreProfile(
                  name: _nameController.text.trim().isNotEmpty
                      ? _nameController.text.trim()
                      : widget.profile.name,
                  address: _addressController.text.trim().isNotEmpty
                      ? _addressController.text.trim()
                      : null,
                  phone: _phoneController.text.trim().isNotEmpty
                      ? _phoneController.text.trim()
                      : null,
                  ownerName: _ownerController.text.trim().isNotEmpty
                      ? _ownerController.text.trim()
                      : null,
                );
                context.read<SettingsCubit>().saveProfile(updated);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
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
      ],
    );
  }
}
