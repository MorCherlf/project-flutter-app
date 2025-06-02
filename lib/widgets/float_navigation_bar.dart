import 'package:flutter/material.dart';

class FloatNavigationBar extends StatefulWidget {
  final List<FloatNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatNavigationBar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    required this.onTap,
  });

  @override
  State<FloatNavigationBar> createState() => _FloatNavigationBarState();
}

class _FloatNavigationBarState extends State<FloatNavigationBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant FloatNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _selectedIndex = widget.currentIndex;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.items.map((item) {
            final int index = widget.items.indexOf(item);
            final bool isSelected = _selectedIndex == index;
            final IconData iconToShow = isSelected && item.activeIcon != null ? item.activeIcon! : item.icon;

            return Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => _onItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container( // 包裹 Icon 和 Text 的 Container
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0), // 可调整内边距
                        width: 120,
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(30.0), // 可调整圆角
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              iconToShow, // 使用 iconToShow
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 1.0),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class FloatNavigationBarItem {
  final IconData icon;
  final IconData? activeIcon; // 添加可选的 activeIcon 属性
  final String label;

  const FloatNavigationBarItem({
    required this.icon,
    this.activeIcon, // activeIcon 变为可选
    required this.label,
  });
}
