import 'package:flutter/material.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shimmer/shimmer.dart';

/// Kerangka daftar berita saat data pertama dimuat. Bentuknya meniru
/// lead story + baris berita supaya pergantian ke data asli tidak melompat.
class LoadingShimmer extends StatelessWidget {
  final int itemCount;

  const LoadingShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.outlineVariant,
      highlightColor: colorScheme.surface,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _Block(height: 220, radius: AppRadius.md),
          const SizedBox(height: AppSpacing.lg),
          const _Block(height: 12, width: 120),
          const SizedBox(height: AppSpacing.md),
          const _Block(height: 22),
          const SizedBox(height: AppSpacing.sm),
          const _Block(height: 22, width: 220),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < itemCount; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Block(height: 12, width: 100),
                      SizedBox(height: AppSpacing.md),
                      _Block(height: 16),
                      SizedBox(height: AppSpacing.sm),
                      _Block(height: 16, width: 160),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                const _Block(height: 96, width: 96, radius: AppRadius.sm),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const _Block({required this.height, this.width, this.radius = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
