import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';

/// Tombol bookmark dengan animasi scale bounce saat ditekan.
/// [overlayStyle] = true untuk dipakai di atas gambar (background gelap bulat).
class BookmarkButton extends StatefulWidget {
  final Article article;
  final double size;
  final bool overlayStyle;

  const BookmarkButton({
    super.key,
    required this.article,
    this.size = 20,
    this.overlayStyle = false,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, _) {
        final isBookmarked = bookmarkProvider.isBookmarked(widget.article.url);

        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              _controller.forward(from: 0);
              bookmarkProvider.toggleBookmark(widget.article);
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  padding: widget.overlayStyle ? const EdgeInsets.all(6) : EdgeInsets.zero,
                  decoration: widget.overlayStyle
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.35),
                        )
                      : null,
                  child: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: widget.size,
                    color: widget.overlayStyle
                        ? Colors.white
                        : (isBookmarked ? colorScheme.primary : colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
