import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import 'cart_tab.dart';
import 'home_tab.dart';
import 'scan_tab.dart';
import 'settings_tab.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tabs = <Widget>[
      const HomeTab(),
      const ScanTab(),
      const CartTab(),
      const SettingsTab(),
    ];

    final navItems = [
      _NavItemData(icon: Icons.home_rounded, label: t.t('home_tab')),
      _NavItemData(icon: Icons.qr_code_scanner_rounded, label: t.t('scan_tab')),
      _NavItemData(icon: Icons.shopping_bag_rounded, label: t.t('cart_tab')),
      _NavItemData(icon: Icons.settings_rounded, label: t.t('settings_tab')),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A13331F),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(navItems.length, (index) {
              final selected = index == _currentIndex;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.leafGreenSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          navItems[index].icon,
                          size: 24,
                          color: selected
                              ? AppColors.leafGreenDark
                              : AppColors.darkGrey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          navItems[index].label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? AppColors.leafGreenDark
                                : AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
