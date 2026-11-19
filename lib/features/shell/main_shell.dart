import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../cashier/cashier_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../menu/menu_screen.dart';
import '../report/report_screen.dart';

/// Kerangka utama setelah login: isi halaman + bottom bar 5 tab.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  static const _items = [
    _NavItem('Beranda', Icons.home_outlined, Icons.home_rounded),
    _NavItem('Kasir', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded),
    _NavItem(
      'Riwayat',
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
    ),
    _NavItem('Laporan', Icons.bar_chart_rounded, Icons.bar_chart_rounded),
    _NavItem('Menu', Icons.grid_view_outlined, Icons.grid_view_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: IndexedStack(
            index: _index,
            children: [
              HomeScreen(onNavigate: _goTo),
              const CashierScreen(),
              const HistoryScreen(),
              const ReportScreen(),
              const MenuScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: _items[i],
                        selected: i == _index,
                        onTap: () => _goTo(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brand : AppColors.muted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
