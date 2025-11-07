import 'package:flutter/material.dart';

enum AppTab { recipes, input, shopping }

class AppBottomBar extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab>? onTabSelected;

  const AppBottomBar({
    super.key,
    required this.currentTab,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _BottomBarButton(
          icon: Icons.menu_book_rounded,
          tab: AppTab.recipes,
          currentTab: currentTab,
          label: 'Recepten',
          onPressed: onTabSelected,
          color: theme.colorScheme.primary,
        ),
        _BottomBarButton(
          icon: Icons.add,
          tab: AppTab.input,
          currentTab: currentTab,
          label: 'Nieuw recept',
          onPressed: onTabSelected,
          color: theme.colorScheme.primary,
        ),
        _BottomBarButton(
          icon: Icons.shopping_cart_outlined,
          tab: AppTab.shopping,
          currentTab: currentTab,
          label: 'Boodschappen',
          onPressed: onTabSelected,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final IconData icon;
  final AppTab tab;
  final AppTab currentTab;
  final String label;
  final ValueChanged<AppTab>? onPressed;
  final Color color;

  const _BottomBarButton({
    required this.icon,
    required this.tab,
    required this.currentTab,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = tab == currentTab;
    final selectedColor = color;
    final unselectedColor =
        theme.colorScheme.onSurface.withAlpha((0.65 * 255).round());

    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: IconButton(
        splashRadius: 28,
        onPressed: () => onPressed?.call(tab),
        icon: Icon(
          icon,
          color: isSelected ? selectedColor : unselectedColor,
          size: 28,
        ),
        tooltip: label,
      ),
    );
  }
}
