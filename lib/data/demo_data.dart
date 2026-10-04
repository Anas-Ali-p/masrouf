import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/transaction.dart';

// ─────────────────────────────────────────────────────────
//  Accounts
// ─────────────────────────────────────────────────────────

final List<Account> demoAccounts = [
  Account(
    id: 'a1',
    name: 'الحساب الرئيسي',
    currency: 'SAR',
    balance: 12450.00,
    accentColor: const Color(0xFF2F3EE0),
    type: AccountType.checking,
    accountNumber: '···· 4821',
    createdAt: DateTime(2023, 4, 12),
    note: 'الحساب الأساسي للرواتب والمصاريف اليومية.',
    monthlyIncome: 8500,
    monthlyExpense: 3120.75,
  ),
  Account(
    id: 'a2',
    name: 'محفظة العملات',
    currency: 'USD',
    balance: 320.50,
    accentColor: const Color(0xFF3CCABC),
    type: AccountType.wallet,
    accountNumber: '···· 1177',
    createdAt: DateTime(2024, 1, 3),
    monthlyIncome: 400,
    monthlyExpense: 79.50,
  ),
  Account(
    id: 'a3',
    name: 'المدخرات',
    currency: 'SAR',
    balance: 5000.00,
    accentColor: const Color(0xFF16A34A),
    type: AccountType.savings,
    accountNumber: '···· 9084',
    createdAt: DateTime(2022, 9, 20),
    monthlyIncome: 1200,
    monthlyExpense: 0,
  ),
];

// ─────────────────────────────────────────────────────────
//  Transactions
// ─────────────────────────────────────────────────────────

final List<Transaction> demoTransactions = [
  Transaction(
    id: 't1',
    title: 'راتب الشهر',
    category: 'دخل',
    amount: 8500.00,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    icon: Icons.payments_rounded,
    isIncome: true,
    accountId: 'a1',
  ),
  Transaction(
    id: 't2',
    title: 'مشتريات سوبر ماركت',
    category: 'تسوق',
    amount: 320.75,
    date: DateTime.now().subtract(const Duration(hours: 6)),
    icon: Icons.shopping_cart_rounded,
    iconColor: const Color(0xFFF49B07),
    accountId: 'a1',
  ),
  Transaction(
    id: 't3',
    title: 'قهوة الصباح',
    category: 'مطاعم',
    amount: 22.00,
    date: DateTime.now().subtract(const Duration(days: 1)),
    icon: Icons.local_cafe_rounded,
    iconColor: const Color(0xFF8B5CF6),
    accountId: 'a1',
  ),
  Transaction(
    id: 't4',
    title: 'بنزين',
    category: 'مواصلات',
    amount: 180.00,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    icon: Icons.local_gas_station_rounded,
    iconColor: const Color(0xFFDC2626),
    accountId: 'a1',
  ),
  Transaction(
    id: 't5',
    title: 'اشتراك الإنترنت',
    category: 'فواتير',
    amount: 199.00,
    date: DateTime.now().subtract(const Duration(days: 2)),
    icon: Icons.wifi_rounded,
    iconColor: const Color(0xFF0EA5E9),
    accountId: 'a1',
  ),
  Transaction(
    id: 't6',
    title: 'مطعم العشاء',
    category: 'مطاعم',
    amount: 85.50,
    date: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    icon: Icons.restaurant_rounded,
    iconColor: const Color(0xFFF97316),
    accountId: 'a2',
  ),
  Transaction(
    id: 't7',
    title: 'صيدلية',
    category: 'صحة',
    amount: 45.00,
    date: DateTime.now().subtract(const Duration(days: 3)),
    icon: Icons.medical_services_rounded,
    iconColor: const Color(0xFF10B981),
    accountId: 'a1',
  ),
  Transaction(
    id: 't8',
    title: 'اشتراك نتفليكس',
    category: 'ترفيه',
    amount: 55.00,
    date: DateTime.now().subtract(const Duration(days: 4)),
    icon: Icons.movie_rounded,
    iconColor: const Color(0xFFE11D48),
    accountId: 'a2',
  ),
  Transaction(
    id: 't9',
    title: 'هدية',
    category: 'دخل',
    amount: 200.00,
    date: DateTime.now().subtract(const Duration(days: 5)),
    icon: Icons.card_giftcard_rounded,
    isIncome: true,
    accountId: 'a3',
  ),
  Transaction(
    id: 't10',
    title: 'فاتورة الكهرباء',
    category: 'فواتير',
    amount: 240.00,
    date: DateTime.now().subtract(const Duration(days: 6)),
    icon: Icons.bolt_rounded,
    iconColor: const Color(0xFFF59E0B),
    accountId: 'a1',
  ),
];
