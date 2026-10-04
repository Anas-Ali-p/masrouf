import 'package:flutter/material.dart';

@immutable
class TransactionCategory {
  const TransactionCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
}

const List<TransactionCategory> kExpenseCategories = [
  TransactionCategory(
    id: 'food',
    label: 'مطاعم',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFF97316),
  ),
  TransactionCategory(
    id: 'shopping',
    label: 'تسوق',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFF8B5CF6),
  ),
  TransactionCategory(
    id: 'transport',
    label: 'مواصلات',
    icon: Icons.directions_car_rounded,
    color: Color(0xFFDC2626),
  ),
  TransactionCategory(
    id: 'bills',
    label: 'فواتير',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFF0EA5E9),
  ),
  TransactionCategory(
    id: 'health',
    label: 'صحة',
    icon: Icons.medical_services_rounded,
    color: Color(0xFF10B981),
  ),
  TransactionCategory(
    id: 'fun',
    label: 'ترفيه',
    icon: Icons.movie_rounded,
    color: Color(0xFFE11D48),
  ),
  TransactionCategory(
    id: 'fuel',
    label: 'وقود',
    icon: Icons.local_gas_station_rounded,
    color: Color(0xFFF59E0B),
  ),
  TransactionCategory(
    id: 'other',
    label: 'أخرى',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF6B7280),
  ),
];

const List<TransactionCategory> kIncomeCategories = [
  TransactionCategory(
    id: 'salary',
    label: 'راتب',
    icon: Icons.payments_rounded,
    color: Color(0xFF16A34A),
  ),
  TransactionCategory(
    id: 'gift',
    label: 'هدية',
    icon: Icons.card_giftcard_rounded,
    color: Color(0xFFEC4899),
  ),
  TransactionCategory(
    id: 'biz',
    label: 'أعمال',
    icon: Icons.storefront_rounded,
    color: Color(0xFF0EA5E9),
  ),
  TransactionCategory(
    id: 'other_i',
    label: 'أخرى',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF6B7280),
  ),
];
