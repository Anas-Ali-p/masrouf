import 'package:flutter/material.dart';
import 'app_bottom_nav_bar.dart';

/// Which tab the user is on. Order MUST match [kNavItems].
enum AppNavDestination { home, transactions, reports, settings }

/// Public list — referenced from any screen/shell via `kNavItems`.
const List<AppBottomNavItem> kNavItems = [
  AppBottomNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'الرئيسية',
  ),
  AppBottomNavItem(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    label: 'العمليات',
  ),
  AppBottomNavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'التقارير',
  ),
  AppBottomNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'الإعدادات',
  ),
];
