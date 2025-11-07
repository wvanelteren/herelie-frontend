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
    final background = theme.colorScheme.surface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomBarButton(
            icon: Icons.list_alt_rounded,
            tab: AppTab.recipes,
            currentTab: currentTab,
            label: 'Recepten',
            onPressed: onTabSelected,
          ),
          _BottomBarButton(
            icon: Icons.add,
            tab: AppTab.input,
            currentTab: currentTab,
            label: 'Nieuw recept',
            emphasize: true,
            onPressed: onTabSelected,
          ),
          _BottomBarButton(
            icon: Icons.receipt_long,
            tab: AppTab.shopping,
            currentTab: currentTab,
            label: 'Boodschappen',
            onPressed: onTabSelected,
          ),
        ],
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final IconData icon;
  final AppTab tab;
  final AppTab currentTab;
  final String label;
  final bool emphasize;
  final ValueChanged<AppTab>? onPressed;

  const _BottomBarButton({
    required this.icon,
    required this.tab,
    required this.currentTab,
    required this.label,
    this.emphasize = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = tab == currentTab;
    final primary = theme.colorScheme.primary;
    final inactive = theme.colorScheme.onSurface.withAlpha((0.6 * 255).round());
    final iconColor = isSelected ? theme.colorScheme.onPrimary : inactive;
    final bgColor = isSelected
        ? primary
        : (emphasize
            ? theme.colorScheme.primary.withAlpha((0.08 * 255).round())
            : Colors.transparent);

    final borderRadius = emphasize ? 24.0 : 16.0;

    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: InkWell(
        onTap: () => onPressed?.call(tab),
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(emphasize ? 12 : 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            icon,
            size: emphasize ? 28 : 24,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
