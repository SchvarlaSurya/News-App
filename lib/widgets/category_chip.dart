import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Chip kategori dengan state aktif (solid) vs tidak aktif (outline)
/// yang beda jelas, plus transisi warna halus.
class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: selected ? Colors.white : colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
