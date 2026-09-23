import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/views/state_views.dart';
import 'package:news_app/widgets/category_chip.dart';
import 'package:news_app/widgets/loading_shimmer.dart';
import 'package:news_app/widgets/news_card.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Beranda: satu berita utama, lalu daftar berita per kategori.
class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  void _openDetail(NewsArticle article) {
    controller.markAsRead(article);
    Get.toNamed(Routes.NEWS_DETAIL, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        // Kepala halaman ikut tergulung saat membaca, lalu muncul lagi
        // begitu jari digeser ke bawah.
        headerSliverBuilder: (context, innerScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            toolbarHeight: 64,
            titleSpacing: AppSpacing.lg,
            title: const _Masthead(),
            actions: [
              Obx(
                () => IconButton(
                  tooltip: controller.isDarkMode.value
                      ? 'Pakai tema terang'
                      : 'Pakai tema gelap',
                  onPressed: controller.toggleTheme,
                  icon: Icon(
                    controller.isDarkMode.value
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: Obx(
                      () => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        itemCount: Constants.categories.length,
                        itemBuilder: (context, index) {
                          final category = Constants.categories[index];
                          return CategoryChip(
                            label: Constants.labelOf(category),
                            isSelected:
                                controller.selectedCategory.value == category,
                            onTap: () => controller.selectCategory(category),
                          );
                        },
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Obx(_buildBody),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value && controller.articles.isEmpty) {
      return const LoadingShimmer();
    }

    if (controller.errorMessage.value != null && controller.articles.isEmpty) {
      return ErrorStateView(
        message: controller.errorMessage.value!,
        onRetry: controller.fetchHeadlines,
      );
    }

    if (controller.articles.isEmpty) {
      return EmptyStateView(
        icon: Icons.inbox_outlined,
        title: 'Belum ada berita di rubrik ini',
        message:
            'Coba rubrik lain, atau tarik layar ke bawah untuk memuat ulang.',
        onRefresh: controller.refreshHeadlines,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshHeadlines,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final position = notification.metrics;
          if (position.pixels >= position.maxScrollExtent - 400) {
            controller.loadMoreHeadlines();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          // +1 untuk lead story, +1 untuk penanda akhir daftar.
          itemCount: controller.articles.length + 1,
          separatorBuilder: (context, index) => index == 0
              ? const SizedBox.shrink()
              : Divider(
                  height: 1,
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
          itemBuilder: (context, index) {
            if (index == controller.articles.length) {
              return ListFooter(
                isLoading: controller.isLoadingMore.value,
                hasMore: controller.hasMore.value,
              );
            }

            final article = controller.articles[index];
            if (index == 0) {
              return Column(
                children: [
                  if (controller.isShowingCache.value)
                    OfflineBanner(
                      lastUpdated: controller.lastUpdated.value,
                      onRetry: controller.refreshHeadlines,
                    ),
                  FeaturedNewsCard(
                    article: article,
                    onTap: () => _openDetail(article),
                  ),
                ],
              );
            }
            return NewsListItem(
              article: article,
              onTap: () => _openDetail(article),
            );
          },
        ),
      ),
    );
  }
}

/// Nama aplikasi + waktu pembaruan terakhir.
class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<NewsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Constants.appName,
          style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: -0.5),
        ),
        Obx(() {
          final updated = controller.lastUpdated.value;
          return Text(
            updated == null
                ? Constants.appTagline
                : 'Diperbarui ${timeago.format(updated, locale: 'id')}',
            style: theme.textTheme.labelMedium,
          );
        }),
      ],
    );
  }
}
