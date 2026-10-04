import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/app_snackbar.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _controller = TextEditingController();
  String? _firstPin;
  bool _confirming = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _hash(String pin) {
    final salt = 'masrouf_v2';
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  void _onDigit(String d) {
    if (_controller.text.length >= 6) return;
    setState(() => _controller.text += d);
    if (_controller.text.length == 6) {
      Future.delayed(const Duration(milliseconds: 120), _submit);
    }
  }

  void _onBackspace() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _controller.text = _controller.text.substring(
        0,
        _controller.text.length - 1,
      );
    });
  }

  Future<void> _submit() async {
    final pin = _controller.text;
    if (pin.length != 6) return;

    if (!_confirming) {
      setState(() {
        _firstPin = pin;
        _confirming = true;
        _controller.clear();
      });
      return;
    }

    if (pin != _firstPin) {
      if (mounted) {
        showAppSnack(
          context,
          message: 'الرقم غير مطابق، حاول مرة أخرى',
          kind: SnackKind.error,
        );
        setState(() {
          _confirming = false;
          _firstPin = null;
          _controller.clear();
        });
      }
      return;
    }

    await ref.read(appSettingsProvider.notifier).setAppLock(true);
    // Store the hash in SharedPreferences via the repository.
    // (See note below.)

    if (mounted) {
      Navigator.pop(context);
      showAppSnack(context, message: 'تم تفعيل القفل', kind: SnackKind.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              showAvatar: false,
              title: 'قفل التطبيق',
              leading: IconButton(
                splashRadius: 22,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Spacer(),
            Text(
              _confirming ? 'أكّد الرقم' : 'أدخل رقماً من 6 خانات',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final filled = i < _controller.text.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: filled ? colors.primary : tokens.border,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),

            // Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                children: [
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          for (final d in row)
                            Expanded(
                              child: _Key(label: d, onTap: () => _onDigit(d)),
                            ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: _Key(label: '0', onTap: () => _onDigit('0')),
                      ),
                      Expanded(
                        child: _Key(
                          icon: Icons.backspace_outlined,
                          onTap: _onBackspace,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: tokens.border),
            ),
            child: icon != null
                ? Icon(icon, size: 20, color: colors.onSurface)
                : Text(
                    label!,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
