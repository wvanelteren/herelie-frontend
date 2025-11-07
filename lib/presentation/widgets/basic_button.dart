import 'package:flutter/material.dart';

enum BasicButtonVariant { primary, secondary }

class BasicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final BasicButtonVariant variant;

  const BasicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = BasicButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPrimary = variant == BasicButtonVariant.primary;

    final backgroundColor = isPrimary ? Colors.black : Colors.white;
    final foregroundColor = isPrimary ? Colors.white : Colors.black;
    final borderSide = isPrimary
        ? BorderSide.none
        : const BorderSide(color: Colors.black, width: 1);

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          side: borderSide,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                ),
        ),
      ),
    );
  }
}
