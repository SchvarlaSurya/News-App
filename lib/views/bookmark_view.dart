import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/views/state_views.dart';
import 'package:news_app/widgets/news_card.dart';

/// Artikel yang disimpan pengguna. Tersimpan di perangkat, jadi tetap ada
/// setelah aplikasi ditutup.
class BookmarkView extends GetView<NewsController> {
  const BookmarkView({super.key});

  void _openDetail(NewsArticle article) {
    controller.markAsRead(article);
    Get.toNamed(Routes.NEWS_DETAIL, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacaan tersimpan'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.bookmarks.isEmpty) {
          return const EmptyStateView(
            icon: Icons.bookmark_border,
            title: 'Belum ada yang disimpan',
            message:
                'Ketuk ikon bookmark di sebuah berita untuk membacanya lagi nanti.',
          );
        }

        final saved = controller.bookmarks.toList();

        return ListView.separated(
          itemCount: saved.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          itemBuilder: (context, index) {
            final article = saved[index];
            return Dismissible(
              key: ValueKey(article.url),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => controller.toggleBookmark(article),
              background: ColoredBox(
                color: Theme.of(context).colorScheme.primary,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: AppSpacing.xl),
                    child: Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ),
              ),
              child: NewsListItem(
                article: article,
                onTap: () => _openDetail(article),
              ),
            );
          },
        );
      }),
    );
  }
}
