import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_motion.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

Future<Color?> showColorPickerSheet(
  BuildContext context, {
  required Color initial,
}) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => _ColorPickerSheet(initial: initial),
  );
}

class _ColorPickerSheet extends StatefulWidget {
  const _ColorPickerSheet({required this.initial});
  final Color initial;

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late HSVColor _hsv;
  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
    _hexController = TextEditingController(text: _hex(_hsv.toColor()));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────
  String _hex(Color c) {
    final argb = c.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _setHsv(HSVColor next) {
    setState(() {
      _hsv = next;
      _hexController.text = _hex(next.toColor());
    });
  }

  void _setFromHex(String raw) {
    final cleaned = raw.replaceAll('#', '').trim();
    if (cleaned.length != 6) return;
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return;
    final color = Color(0xFF000000 | value);
    setState(() => _hsv = HSVColor.fromColor(color));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final preview = _hsv.toColor();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSizes.md,
        6,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle (stays outside the scroll so it's always visible)
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Scrollable body ─────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          'اختر لوناً مخصصاً',
                          textAlign: TextAlign.center,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Material(
                        color: tokens.border.withValues(alpha: .35),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Live preview ─────────────────────────
                  AnimatedContainer(
                    duration: AppMotion.fast,
                    height: 50,
                    decoration: BoxDecoration(
                      color: preview,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      boxShadow: [
                        BoxShadow(
                          color: preview.withValues(alpha: .35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _hex(preview),
                        textDirection: TextDirection.ltr,
                        style: text.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: .25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Hue ──────────────────────────────────
                  _Label(context, 'الدرجة'),
                  const SizedBox(height: 6),
                  _HueSlider(
                    hue: _hsv.hue,
                    onChanged: (h) => _setHsv(_hsv.withHue(h)),
                  ),
                  const SizedBox(height: 12),

                  // ── SV square ────────────────────────────
                  _Label(context, 'التشبع والإضاءة'),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 110,
                    child: _SVSquare(hsv: _hsv, onChanged: _setHsv),
                  ),
                  const SizedBox(height: 12),

                  // ── Hex ──────────────────────────────────
                  _Label(context, 'الكود الست عشري'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _hexController,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _setFromHex,
                    onChanged: _setFromHex,
                    style: text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: Icon(
                          Icons.tag_rounded,
                          size: 16,
                          color: tokens.textMuted,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor: colors.surface,
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(
                        4,
                        12,
                        12,
                        12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        borderSide: BorderSide(color: tokens.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Quick picks ──────────────────────────
                  _Label(context, 'اختيارات سريعة'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _quickPicks.map((c) {
                      final active = c.toARGB32() == preview.toARGB32();
                      return GestureDetector(
                        onTap: () => _setHsv(HSVColor.fromColor(c)),
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: active
                                ? Border.all(color: colors.onSurface, width: 2)
                                : Border.all(color: tokens.border, width: 1),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // ── Apply ────────────────────────────────
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, preview),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      textStyle: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('تطبيق اللون'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _quickPicks = <Color>[
    Color(0xFF2F3EE0),
    Color(0xFF3CCABC),
    Color(0xFF16A34A),
    Color(0xFFF49B07),
    Color(0xFFDC2626),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFF14B8A6),
    Color(0xFFEAB308),
    Color(0xFF1F2937),
    Color(0xFF78350F),
  ];
}

// ─────────────────────────────────────────────────────────
//  Small label
// ─────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.context, this.text);
  final BuildContext context;
  final String text;

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 2),
      child: Text(
        text,
        style: context.text.labelSmall?.copyWith(
          color: context.tokens.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Hue slider — rainbow gradient with a draggable thumb
// ─────────────────────────────────────────────────────────

class _HueSlider extends StatelessWidget {
  const _HueSlider({required this.hue, required this.onChanged});

  final double hue;
  final ValueChanged<double> onChanged;

  static const _hues = <Color>[
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const thumbSize = 26.0;
        final left = (hue / 360).clamp(0.0, 1.0) * (w - thumbSize);

        return GestureDetector(
          onPanDown: (d) => _handle(d.localPosition.dx, w, thumbSize),
          onPanUpdate: (d) => _handle(d.localPosition.dx, w, thumbSize),
          child: SizedBox(
            height: thumbSize + 4,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient track
                Positioned(
                  left: 0,
                  right: 0,
                  top: 2,
                  child: Container(
                    height: thumbSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(thumbSize / 2),
                      border: Border.all(color: tokens.border, width: 1),
                      gradient: const LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: _hues,
                      ),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: left,
                  top: 0,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize + 4,
                    decoration: BoxDecoration(
                      color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handle(double dx, double w, double thumbSize) {
    final t = ((dx - thumbSize / 2) / (w - thumbSize)).clamp(0.0, 1.0);
    onChanged(t * 360);
  }
}

// ─────────────────────────────────────────────────────────
//  Saturation / Value pad
// ─────────────────────────────────────────────────────────
class _SVSquare extends StatelessWidget {
  const _SVSquare({required this.hsv, required this.onChanged});

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        const cursorSize = 18.0;

        // In RTL, saturation 0 (white) sits at the physical right edge.
        // So the cursor's x position is mirrored: (1 - sat) instead of sat.
        final satFactor = isRtl ? (1 - hsv.saturation) : hsv.saturation;

        final cursorLeft = satFactor * size.width - cursorSize / 2;
        final cursorTop = (1 - hsv.value) * size.height - cursorSize / 2;

        return GestureDetector(
          onPanDown: (d) => _handle(d.localPosition, size, isRtl),
          onPanUpdate: (d) => _handle(d.localPosition, size, isRtl),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Base color (hue at full sat/val)
              Container(
                decoration: BoxDecoration(
                  color: HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: tokens.border, width: 1),
                ),
              ),
              // White → transparent (saturation axis)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  gradient: const LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [Colors.white, Colors.transparent],
                  ),
                ),
              ),
              // Transparent → black (value axis)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  gradient: const LinearGradient(
                    begin: AlignmentDirectional.topCenter,
                    end: AlignmentDirectional.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ),
                ),
              ),
              // Cursor
              Positioned(
                left: cursorLeft,
                top: cursorTop,
                child: Container(
                  width: cursorSize,
                  height: cursorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .35),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handle(Offset pos, Size size, bool isRtl) {
    final ratio = (pos.dx / size.width).clamp(0.0, 1.0);
    // Mirror the saturation reading in RTL so a tap on the right
    // edge = 0 (white) and a tap on the left edge = 1 (full color).
    final s = isRtl ? (1 - ratio) : ratio;
    final v = (1 - pos.dy / size.height).clamp(0.0, 1.0);
    onChanged(hsv.withSaturation(s).withValue(v));
  }
}
