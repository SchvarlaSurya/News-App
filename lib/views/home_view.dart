import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/news_controller.dart';
import '../routes/app_pages.dart';
import '../utils/constants.dart';
import '../widgets/category_chip.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/news_card.dart';

/// Daftar berita + filter kategori + search.
class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berita Hari Ini')),
      body: Column(
        children: [
          _SearchField(
            onSubmitted: (query) {
              final trimmed = query.trim();
              // Kolom dikosongkan: kembali ke top headlines kategori aktif.
              trimmed.isEmpty ? controller.refreshNews() : controller.searchNews(trimmed);
            },
          ),
          _buildCategoryBar(),
          const Divider(height: 1),
          Expanded(child: Obx(_buildBody)),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 56,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return CategoryChip(
              label: category.capitalizeFirst!,
              isSelected: controller.selectedCategory == category,
              onTap: () => controller.selectCategory(category),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return LoadingShimmer();
    }

    final articles = controller.articles;

    if (articles.isEmpty) {
      return controller.error.isNotEmpty
          ? _ErrorState(message: controller.error, onRetry: controller.refreshNews)
          : const _EmptyState(
              icon: Icons.newspaper_rounded,
              title: 'Sepi banget di sini',
              subtitle: 'Belum ada berita untuk ditampilkan.',
            );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNews,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return NewsCard(
            article: article,
            onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
          );
        },
      ),
    );
  }
}

/// Kolom pencarian; request dikirim saat user menekan tombol search di keyboard.
class _SearchField extends StatefulWidget {
  final ValueChanged<String> onSubmitted;

  const _SearchField({required this.onSubmitted});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: TextField(
        controller: _textController,
        textInputAction: TextInputAction.search,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: 'Cari berita...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.clear),
            onPressed: () {
              _textController.clear();
              widget.onSubmitted('');
            },
          ),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        ),
      ),
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
