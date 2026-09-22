import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Berita teratas: gambar lebar, judul serif besar. Hanya dipakai sekali
/// di puncak daftar supaya tetap terasa sebagai headline.
class FeaturedNewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const FeaturedNewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: ArticleImage(article: article),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ArticleMeta(article: article),
            const SizedBox(height: AppSpacing.sm),
            Text(
              article.title ?? '',
              style: theme.textTheme.displaySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (article.description != null &&
                article.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                article.description!,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Baris berita: teks di kiri, thumbnail di kanan. Bentuk yang dipakai
/// koran digital karena judul tetap terbaca sambil scroll cepat.
class NewsListItem extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsListItem({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArticleMeta(article: article),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    article.title ?? '',
                    style: theme.textTheme.titleMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (article.hasImage) ...[
              const SizedBox(width: AppSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: ArticleImage(article: article),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sumber berita + waktu terbit.
class ArticleMeta extends StatelessWidget {
  final NewsArticle article;

  const ArticleMeta({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final published = article.publishedDate;

    return Row(
      children: [
        Flexible(
          child: Text(
            article.sourceName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (published != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            timeago.format(published, locale: 'id'),
            style: theme.textTheme.labelMedium,
          ),
        ],
      ],
    );
  }
}

/// Gambar artikel dengan cache, placeholder, dan pengganti saat gagal.
class ArticleImage extends StatelessWidget {
  final NewsArticle article;

  const ArticleImage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget placeholder([IconData icon = Icons.article_outlined]) => ColoredBox(
      color: colorScheme.outlineVariant,
      child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 28),
    );

    if (!article.hasImage) return placeholder();

    return CachedNetworkImage(
      imageUrl: article.urlToImage!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => placeholder(),
      errorWidget: (context, url, error) =>
          placeholder(Icons.image_not_supported_outlined),
    );
  }
}

/// Tombol simpan artikel. [onImage] dipakai saat tombol berada di atas gambar.
class BookmarkButton extends StatelessWidget {
  final NewsArticle article;
  final bool onImage;

  const BookmarkButton({
    super.key,
    required this.article,
    this.onImage = false,
  });

  Future<void> _toggle(NewsController controller) async {
    final saved = await controller.toggleBookmark(article);
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      message: saved ? 'Disimpan ke bacaan nanti' : 'Dihapus dari simpanan',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.sm,
      backgroundColor: Theme.of(Get.context!).colorScheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final saved = controller.isBookmarked(article);
      return IconButton(
        tooltip: saved ? 'Hapus dari simpanan' : 'Simpan artikel',
        onPressed: () => _toggle(controller),
        style: onImage
            ? IconButton.styleFrom(
                backgroundColor: AppColors.scrim.withValues(alpha: 0.45),
                foregroundColor: AppColors.onAccent,
              )
            : null,
        icon: Icon(
          saved ? Icons.bookmark : Icons.bookmark_outline,
          color: onImage
              ? AppColors.onAccent
              : (saved ? colorScheme.primary : colorScheme.onSurface),
        ),
      );
    });
  }
}
