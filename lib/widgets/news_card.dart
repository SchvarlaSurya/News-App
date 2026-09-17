import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/news_controller.dart';
import '../models/news_article.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Kartu berita reusable: gambar 16:9 + judul di atas gradient, source & waktu.
/// Muncul dengan animasi fade + slide-up; [index] dipakai untuk efek stagger.
class NewsCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback? onTap;
  final int index;

  const NewsCard({super.key, required this.article, this.onTap, this.index = 0});

  /// Format waktu relatif ("2 jam lalu"); jatuh ke tanggal kalau lebih dari 7 hari.
  static String formatPublishedAt(DateTime publishedAt) {
    final diff = DateTime.now().difference(publishedAt);

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM yyyy', 'id_ID').format(publishedAt);
  }

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(_opacity);

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 30 * widget.index.clamp(0, 8));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final article = widget.article;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Card(
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NewsImage(url: article.urlToImage),
                        // Gradient tipis di bawah gambar biar judul tetap terbaca.
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.scrim.withValues(alpha: 0),
                                  AppColors.scrim.withValues(alpha: 0.75),
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
                            style: theme.textTheme.titleMedium?.copyWith(color: AppColors.onImage),
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: BookmarkButton(article: article),
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
                            article.source.name,
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
                          NewsCard.formatPublishedAt(article.publishedAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gambar artikel dengan placeholder & fallback kalau URL kosong/gagal dimuat.
class NewsImage extends StatelessWidget {
  final String? url;
  final double iconSize;

  const NewsImage({super.key, this.url, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget fallback(IconData icon) => Container(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(icon, size: iconSize, color: colorScheme.onSurfaceVariant),
        );

    if (url == null || url!.isEmpty) return fallback(Icons.image_outlined);

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (context, _) => Container(
        color: colorScheme.surfaceContainerHighest,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, _, _) => fallback(Icons.image_not_supported_outlined),
    );
  }
}

/// Tombol bookmark bulat (untuk di atas gambar) dengan animasi scale bounce.
class BookmarkButton extends StatefulWidget {
  final NewsArticle article;
  final double size;

  const BookmarkButton({super.key, required this.article, this.size = 20});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 55,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsController = Get.find<NewsController>();

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          _controller.forward(from: 0);
          newsController.toggleBookmark(widget.article);
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.scrim.withValues(alpha: 0.35),
              ),
              child: Obx(
                () => Icon(
                  newsController.isBookmarked(widget.article)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: widget.size,
                  color: AppColors.onImage,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
