import 'package:flutter/material.dart';

class BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int? badgeCount; // 修改为 int? 类型，表示徽标数量
  final Color? color; // 新增图标主色参数
  final Color badgeColor;
  final Color textColor;
  final double iconSize;
  final double badgeRadius; // 改为圆角半径参数
  final bool showBadge; // 新增显式控制显示

  const BadgedIcon({
    super.key,
    required this.icon,
    this.badgeCount, // 徽标数量可以为空
    this.color, // 图标颜色继承主题
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.iconSize = 24.0,
    this.badgeRadius = 100.0, // 符合M3圆角规范
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final shouldShowBadge = showBadge && badgeCount != null && badgeCount! > 0;
    String badgeDisplay = '';

    if (shouldShowBadge) {
      if (badgeCount! > 99) {
        badgeDisplay = '99+';
      } else {
        badgeDisplay = badgeCount!.toString();
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(icon, size: iconSize, color: effectiveColor),
        if (shouldShowBadge)
          Positioned(
            right: -12,
            top: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(badgeRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeDisplay,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontSize: _getFontSize(badgeDisplay),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }

  double _getFontSize(String text) {
    final length = text.length;
    if (length > 2) return 10.0;
    if (length > 1) return 11.0;
    return 12.0;
  }
}