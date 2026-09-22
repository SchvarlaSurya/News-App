import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/widgets/news_card.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Halaman baca. Artikel dikirim lewat Get.arguments dari daftar berita.
class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final article = Get.arguments;
    if (article is! NewsArticle) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Artikel tidak ditemukan.')),
      );
    }

    final theme = Theme.of(context);
    final published = article.publishedDate;
    final body = article.readableContent;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: article.hasImage ? 280 : 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            actions: [
              BookmarkButton(article: article, onImage: article.hasImage),
              IconButton(
                tooltip: 'Bagikan',
                onPressed: () => _share(article),
                icon: const Icon(Icons.ios_share),
                style: article.hasImage ? _overlayStyle : null,
              ),
              PopupMenuButton<String>(
                tooltip: 'Aksi lainnya',
                onSelected: (value) => value == 'copy'
                    ? _copyLink(article)
                    : _openInBrowser(article),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'copy', child: Text('Salin tautan')),
                  PopupMenuItem(
                    value: 'browser',
                    child: Text('Buka di browser'),
                  ),
                ],
              ),
            ],
            flexibleSpace: article.hasImage
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        ArticleImage(article: article),
                        // Gelapkan bagian atas supaya ikon tetap terbaca.
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.scrim.withValues(alpha: 0.5),
                                AppColors.scrim.withValues(alpha: 0),
                              ],
                              stops: const [0, 0.5],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? '',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.author?.isNotEmpty == true
                              ? '${article.sourceName} · ${article.author}'
                              : article.sourceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (published != null)
                        Text(
                          DateFormat(
                            'd MMMM yyyy, HH:mm',
                            'id_ID',
                          ).format(published),
                          style: theme.textTheme.labelMedium,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.lg),
                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    Text(
                      article.description!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (body != null && body != article.description)
                    Text(body, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'NewsAPI hanya mengirim cuplikan artikel. Buka sumbernya untuk membaca lengkap.',
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openInBrowser(article),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: Text('Baca di ${article.sourceName}'),
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

  ButtonStyle get _overlayStyle => IconButton.styleFrom(
    backgroundColor: AppColors.scrim.withValues(alpha: 0.45),
    foregroundColor: AppColors.onAccent,
  );

  void _share(NewsArticle article) {
    if (article.url == null) return;
    SharePlus.instance.share(
      ShareParams(
        text: '${article.title ?? 'Berita menarik'}\n\n${article.url}',
        subject: article.title,
      ),
    );
  }

  Future<void> _copyLink(NewsArticle article) async {
    if (article.url == null) return;
    await Clipboard.setData(ClipboardData(text: article.url!));
    Get.rawSnackbar(
      message: 'Tautan disalin',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.sm,
    );
  }

  Future<void> _openInBrowser(NewsArticle article) async {
    final url = Uri.tryParse(article.url ?? '');
    if (url == null) return;

    // launchUrl langsung, tanpa canLaunchUrl: di Android 11+ pengecekan itu
    // butuh deklarasi <queries> dan sering menjawab false padahal bisa dibuka.
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.rawSnackbar(
        message: 'Tidak ada aplikasi yang bisa membuka tautan ini',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.sm,
      );
    }
  }
}
