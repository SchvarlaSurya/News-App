import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/article_card_skeleton.dart';
import '../widgets/category_chip.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/state_views.dart';
import 'article_detail_screen.dart';
import 'bookmark_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Map<String, String> _categories = {
    'general': 'General',
    'business': 'Business',
    'technology': 'Technology',
    'sports': 'Sports',
    'health': 'Health',
    'entertainment': 'Entertainment',
  };

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchTopHeadlines();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<NewsProvider>();
      if (!provider.isLoading && provider.errorMessage == null) {
        provider.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Hari Ini'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(themeProvider.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              onPressed: themeProvider.toggleTheme,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookmarkScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryBar(context),
          const Divider(height: 1),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final entry = _categories.entries.elementAt(index);
              final isSelected = provider.selectedCategory == entry.key;

              return CategoryChip(
                label: entry.value,
                selected: isSelected,
                onTap: () => provider.changeCategory(entry.key),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.articles.isEmpty) {
          return const ArticleListSkeleton();
        }

        if (provider.errorMessage != null && provider.articles.isEmpty) {
          return ErrorStateView(
            message: provider.errorMessage!,
            onRetry: provider.fetchTopHeadlines,
          );
        }

        if (provider.articles.isEmpty) {
          return const EmptyStateView(
            icon: Icons.newspaper_rounded,
            title: 'Sepi banget di sini',
            subtitle: 'Belum ada berita untuk kategori ini.',
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchTopHeadlines,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.articles.length + (provider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.articles.length) {
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
              final article = provider.articles[index];
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
          ),
        );
      },
    );
  }
}
