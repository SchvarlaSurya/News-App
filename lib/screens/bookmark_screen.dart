import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bookmark_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/state_views.dart';
import 'article_detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkProvider>().loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, provider, _) {
          if (!provider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.bookmarks.isEmpty) {
            return const EmptyStateView(
              icon: Icons.bookmark_border_rounded,
              title: 'Belum ada yang disimpan',
              subtitle: 'Ketuk ikon bookmark di berita buat simpan di sini.',
            );
          }

          return ListView.builder(
            itemCount: provider.bookmarks.length,
            itemBuilder: (context, index) {
              final article = provider.bookmarks[index];
              return FadeSlideIn(
                index: index,
                child: ArticleCard(
                  article: article,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: article),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
