import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/views/state_views.dart';
import 'package:news_app/widgets/loading_shimmer.dart';
import 'package:news_app/widgets/news_card.dart';

/// Pencarian: mengetik langsung mencari (jeda 500ms), riwayat pencarian
/// tersimpan supaya kata kunci yang sering dipakai gampang diulang.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NewsController controller = Get.find<NewsController>();
  final TextEditingController _field = TextEditingController();

  @override
  void initState() {
    super.initState();
    _field.text = controller.searchQuery.value;
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _runSearch(String query) {
    _field.text = query;
    _field.selection = TextSelection.collapsed(offset: query.length);
    FocusScope.of(context).unfocus();
    controller.search(query);
  }

  void _openDetail(NewsArticle article) =>
      Get.toNamed(Routes.NEWS_DETAIL, arguments: article);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: TextField(
            controller: _field,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: controller.onSearchChanged,
            onSubmitted: controller.search,
            decoration: InputDecoration(
              hintText: 'Cari berita, tokoh, atau topik',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: Obx(
                () =>
                    controller.searchQuery.value.isEmpty && _field.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Kosongkan',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _field.clear();
                          controller.clearSearch();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(_buildBody),
    );
  }

  Widget _buildBody() {
    if (controller.isSearchLoading.value) {
      return const LoadingShimmer(itemCount: 3);
    }

    if (controller.searchError.value != null) {
      return ErrorStateView(
        message: controller.searchError.value!,
        onRetry: () => controller.search(controller.searchQuery.value),
      );
    }

    if (controller.searchQuery.value.isEmpty) return _buildHistory();

    if (controller.searchResults.isEmpty) {
      return const EmptyStateView(
        icon: Icons.search_off_outlined,
        title: 'Tidak ada hasil',
        message:
            'Coba kata kunci lain, misalnya nama tokoh atau topik dalam bahasa Inggris.',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final position = notification.metrics;
        if (position.pixels >= position.maxScrollExtent - 400) {
          controller.loadMoreSearchResults();
        }
        return false;
      },
      child: ListView.separated(
        itemCount: controller.searchResults.length + 1,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: AppSpacing.lg,
          endIndent: AppSpacing.lg,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          if (index == controller.searchResults.length) {
            return ListFooter(
              isLoading: controller.isSearchLoadingMore.value,
              hasMore: controller.searchHasMore.value,
            );
          }
          final article = controller.searchResults[index];
          return NewsListItem(
            article: article,
            onTap: () => _openDetail(article),
          );
        },
      ),
    );
  }

  Widget _buildHistory() {
    final theme = Theme.of(context);

    if (controller.searchHistory.isEmpty) {
      return const EmptyStateView(
        icon: Icons.search_outlined,
        title: 'Mau baca tentang apa?',
        message:
            'Ketik kata kunci di atas. Hasil diambil dari ribuan sumber berita berbahasa Inggris.',
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Pencarian terakhir',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: controller.clearSearchHistory,
                child: const Text('Hapus semua'),
              ),
            ],
          ),
        ),
        for (final query in controller.searchHistory)
          ListTile(
            leading: const Icon(Icons.history, size: 20),
            title: Text(query, style: theme.textTheme.titleSmall),
            trailing: IconButton(
              tooltip: 'Hapus $query',
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => controller.removeSearchHistory(query),
            ),
            onTap: () => _runSearch(query),
          ),
      ],
    );
  }
}
