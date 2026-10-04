import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_motion.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth * .90)
              .clamp(250.0, 360.0)
              .toDouble();

          return Center(
            child: SizedBox(
              width: width,
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: colors.primary,
                      elevation: 4,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: colors.shadow.withValues(alpha: .15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(items.length, (index) {
                          final item = items[index];
                          return _Destination(
                            item: item,
                            selected: index == currentIndex,
                            onTap: () => onTap(index),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _AddButton(onTap: onAdd),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.curve,
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
          decoration: BoxDecoration(
            color: selected
                ? colors.onPrimary.withValues(alpha: .18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: selected
                ? Border.all(color: colors.onPrimary.withValues(alpha: .22))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: AppSizes.iconSm,
                color: colors.onPrimary.withValues(alpha: selected ? 1 : .75),
              ),
              const SizedBox(width: 4),
              if (selected)
                AnimatedScale(
                  scale: 1,
                  alignment: isRtl
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  duration: AppMotion.standard,
                  curve: AppMotion.curve,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Material(
      color: tokens.primary,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.add_rounded,
            color: tokens.onPrimary,
            size: AppSizes.iconMd,
          ),
        ),
      ),
    );
  }
}
