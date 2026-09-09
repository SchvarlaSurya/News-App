import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/app_theme.dart';

/// Versi skeleton dari ArticleCard, dipakai saat isLoading & belum ada data.
class ArticleCardSkeleton extends StatelessWidget {
  const ArticleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade300;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Card(
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(height: 10, width: 90, color: Colors.white),
                    const Spacer(),
                    Container(height: 10, width: 60, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List skeleton untuk state loading awal.
class ArticleListSkeleton extends StatelessWidget {
  final int itemCount;

  const ArticleListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const ArticleCardSkeleton(),
    );
  }
}
