import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// List skeleton berefek shimmer, dipakai saat loading awal & belum ada data.
/// Bentuknya meniru NewsCard biar transisi ke data asli gak lompat.
class LoadingShimmer extends StatelessWidget {
  final int itemCount;

  const LoadingShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Card(
          child: Shimmer.fromColors(
            baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
            highlightColor:
                isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: AppColors.onImage),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(height: 10, width: 90, color: AppColors.onImage),
                      const Spacer(),
                      Container(height: 10, width: 60, color: AppColors.onImage),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
