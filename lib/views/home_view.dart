import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/news_controller.dart';
import '../models/news_article.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/category_chip.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/news_card.dart';

/// Daftar berita + filter kategori + search.
class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  void _openDetail(NewsArticle article) {
    Get.toNamed(AppRoutes.newsDetail, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        // Tombol back menutup search dulu sebelum keluar aplikasi.
        canPop: !controller.isSearching.value,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.closeSearch();
        },
        child: Scaffold(
          appBar: controller.isSearching.value ? _buildSearchAppBar() : _buildAppBar(),
          body: Column(
            children: [
              _buildCategoryBar(),
              const Divider(height: 1),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Berita Hari Ini'),
      actions: [
        IconButton(
          tooltip: 'Cari',
          icon: const Icon(Icons.search),
          onPressed: controller.openSearch,
        ),
        IconButton(
          tooltip: 'Ganti tema',
          icon: Icon(
            controller.isDarkMode.value ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          onPressed: controller.toggleTheme,
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: controller.closeSearch,
      ),
      title: TextField(
        controller: controller.searchTextController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Cari berita...',
          border: InputBorder.none,
        ),
        onChanged: controller.onSearchChanged,
        onSubmitted: controller.onSearchChanged,
      ),
      actions: [
        IconButton(
          tooltip: 'Hapus',
          icon: const Icon(Icons.clear),
          onPressed: () {
            controller.searchTextController.clear();
            controller.onSearchChanged('');
          },
        ),
      ],
    );
  }

  Widget _buildCategoryBar() {
    // Kategori disembunyikan selama hasil pencarian tampil (search lintas kategori).
    if (controller.isSearchMode) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        // +1 untuk chip "Tersimpan" (bookmark) di akhir.
        itemCount: Constants.categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isBookmarkChip = index == Constants.categories.length;
          final category =
              isBookmarkChip ? Constants.bookmarksCategory : Constants.categories[index];

          return CategoryChip(
            label: isBookmarkChip ? 'Tersimpan' : category.capitalizeFirst!,
            icon: isBookmarkChip ? Icons.bookmark_rounded : null,
            selected: controller.selectedCategory.value == category,
            onTap: () => controller.changeCategory(category),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isBookmarkMode && !controller.isSearchMode) {
      return _buildBookmarkList();
    }

    if (controller.isLoading.value) {
      return const LoadingShimmer();
    }

    if (controller.errorMessage.value != null) {
      return _ErrorState(
        message: controller.errorMessage.value!,
        onRetry: controller.fetchNews,
      );
    }

    if (controller.articles.isEmpty) {
      return controller.isSearchMode
          ? const _EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Gak ketemu, nih',
              subtitle: 'Coba kata kunci lain ya.',
            )
          : const _EmptyState(
              icon: Icons.newspaper_rounded,
              title: 'Sepi banget di sini',
              subtitle: 'Belum ada berita untuk kategori ini.',
            );
    }

    final articles = controller.articles;
    final showFooter = controller.isLoadingMore.value;

    return RefreshIndicator(
      onRefresh: controller.fetchNews,
      child: ListView.builder(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: articles.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final article = articles[index];
          return NewsCard(
            key: ValueKey(article.url),
            article: article,
            index: index,
            onTap: () => _openDetail(article),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkList() {
    final bookmarks = controller.bookmarks;

    if (bookmarks.isEmpty) {
      return const _EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'Belum ada yang disimpan',
        subtitle: 'Ketuk ikon bookmark di berita buat simpan di sini.',
      );
    }

    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final article = bookmarks[index];
        return NewsCard(
          key: ValueKey(article.url),
          article: article,
          index: index,
          onTap: () => _openDetail(article),
        );
      },
    );
  }
}

/// Ilustrasi kosong: icon besar dalam lingkaran lembut + copy santai.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _EmptyState({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Icon(icon, size: 56, color: colorScheme.primary.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle!, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state dengan copy manusiawi + tombol retry.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.error.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.wifi_off_rounded, size: 56, color: colorScheme.error),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Yah, koneksi lagi ngambek 😅',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
