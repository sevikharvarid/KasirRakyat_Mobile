import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';

/// Tab item definition — immutable, const-constructible.
class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem(this.icon, this.activeIcon, this.label);
}

const _kTabs = [
  _TabItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Kasir'),
  _TabItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Produk'),
  _TabItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Laporan'),
  _TabItem(Icons.settings_outlined, Icons.settings, 'Pengaturan'),
];

class KrBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  const KrBottomNav({
    super.key,
    required this.currentIndex,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Material ancestor is required for InkWell to work and to handle
    // BoxShadow/elevation correctly inside Scaffold.bottomNavigationBar.
    return Material(
      color: AppColors.primarySurface,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(_kTabs.length, (i) {
                  return _NavItem(
                    tab: _kTabs[i],
                    isActive: currentIndex == i,
                    onTap: () => onTabSelected?.call(i),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // InkWell inside a Material ancestor provides reliable tap detection,
      // correct hit-testing bounds, and a subtle ripple for tactile feedback.
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryLight.withValues(alpha: 0.6),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                size: 22,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
