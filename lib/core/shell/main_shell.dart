import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/widgets/kr_bottom_nav.dart';
import 'package:kasir_rakyat/features/pos/screens/pos_screen.dart';
import 'package:kasir_rakyat/features/products/screens/products_screen.dart';
import 'package:kasir_rakyat/features/reports/screens/reports_screen.dart';
import 'package:kasir_rakyat/features/settings/screens/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Each screen in IndexedStack is wrapped with RepaintBoundary so that
      // switching tabs does NOT trigger a repaint on the non-visible screens.
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          RepaintBoundary(child: PosScreen()),
          RepaintBoundary(child: ProductsScreen()),
          RepaintBoundary(child: ReportsScreen()),
          RepaintBoundary(child: SettingsScreen()),
        ],
      ),
      bottomNavigationBar: KrBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
