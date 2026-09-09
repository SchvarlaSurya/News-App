import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/article.dart';
import '../utils/app_theme.dart';
import 'bookmark_button.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.onTap});

  /// Format waktu relatif ("2 jam lalu"); jatuh ke tanggal (intl) kalau lebih dari 7 hari.
  String _formatPublishedAt(DateTime publishedAt) {
    final diff = DateTime.now().difference(publishedAt);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return DateFormat('d MMM yyyy', 'id_ID').format(publishedAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: article.urlToImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant),
                      ),
                    // Gradient tipis di bawah gambar biar judul yang ditumpuk tetap terbaca.
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.sm,
                      child: Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: BookmarkButton(article: article, overlayStyle: true),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.sourceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(_formatPublishedAt(article.publishedAt), style: theme.textTheme.bodySmall),
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
