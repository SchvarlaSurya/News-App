import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  /// [raw] berupa string ISO 8601 dari API (bisa null / tidak valid).
  static String formatPublishedAt(String? raw) {
    final publishedAt = parsePublishedAt(raw);
    if (publishedAt == null) return '';

    final diff = DateTime.now().difference(publishedAt);

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM yyyy').format(publishedAt);
  }

  /// Ubah string `publishedAt` dari API menjadi [DateTime] waktu lokal.
  /// Return null kalau tidak bisa dipakai.
  static DateTime? parsePublishedAt(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    // tryParse: format rusak -> null, bukan exception yang bikin UI crash.
    final parsed = DateTime.tryParse(raw.trim())?.toLocal();
    if (parsed == null) return null;

    // Jam server bisa sedikit di depan jam HP; jangan tampilkan "-3 menit lalu".
    final now = DateTime.now();
    return parsed.isAfter(now) ? now : parsed;
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
                            article.title ?? 'Tanpa judul',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(color: AppColors.onImage),
                          ),
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
                            article.source?.name ?? 'Tidak diketahui',
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
