import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../utils/app_theme.dart';
import '../widgets/bookmark_button.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  Future<void> _openFullArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.url);
    if (uri == null) {
      _showSnackBar(context, 'Tautan berita tidak valid.');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showSnackBar(context, 'Gagal membuka tautan berita.');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = article.urlToImage != null && article.urlToImage!.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Material(
                color: Colors.black.withValues(alpha: 0.35),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: BookmarkButton(article: article, overlayStyle: true),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: article.urlToImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 48,
                            ),
                          ),
                        ),
                        // Scrim biar back/bookmark icon tetap kebaca di atas gambar.
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.black.withValues(alpha: 0),
                                Colors.black.withValues(alpha: 0.1),
                              ],
                              stops: const [0, 0.4, 1],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
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
                      Text(
                        DateFormat('d MMM yyyy, HH:mm').format(article.publishedAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl * 1.5),
                  Text(
                    (article.content == null || article.content!.isEmpty)
                        ? (article.description ?? 'Konten tidak tersedia.')
                        : article.content!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openFullArticle(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Baca Selengkapnya'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
