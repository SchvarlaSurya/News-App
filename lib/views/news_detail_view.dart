import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_article.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/news_card.dart';

/// Detail artikel. Artikel dikirim lewat `Get.toNamed(..., arguments: article)`.
class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  Future<void> _openFullArticle(NewsArticle article) async {
    final uri = Uri.tryParse(article.url);
    if (uri == null) {
      Get.snackbar('Oops', 'Tautan berita tidak valid.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      Get.snackbar('Oops', 'Gagal membuka tautan berita.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = Get.arguments;
    // Mis. halaman di-refresh di web: arguments hilang.
    if (article is! NewsArticle) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Artikel tidak ditemukan.')),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final body = (article.content == null || article.content!.isEmpty)
        ? (article.description ?? 'Konten tidak tersedia.')
        // NewsAPI memotong content dengan akhiran "[+1234 chars]".
        : article.content!.replaceAll(RegExp(r'\s*\[\+\d+ chars\]$'), '');

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
                color: AppColors.scrim.withValues(alpha: 0.35),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onImage),
                  onPressed: Get.back,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: BookmarkButton(article: article),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NewsImage(url: article.urlToImage, iconSize: 48),
                  // Scrim biar tombol back/bookmark tetap kebaca di atas gambar.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.scrim.withValues(alpha: 0.35),
                          AppColors.scrim.withValues(alpha: 0),
                          AppColors.scrim.withValues(alpha: 0.1),
                        ],
                        stops: const [0, 0.4, 1],
                      ),
                    ),
                  ),
                ],
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
                          article.author == null || article.author!.isEmpty
                              ? article.source.name
                              : '${article.source.name} · ${article.author}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat('d MMM yyyy, HH:mm', 'id_ID')
                            .format(article.publishedAt.toLocal()),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl * 1.5),
                  if (article.description != null &&
                      article.description!.isNotEmpty &&
                      article.description != body) ...[
                    Text(
                      article.description!,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(body, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openFullArticle(article),
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
