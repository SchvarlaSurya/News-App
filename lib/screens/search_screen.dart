import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/article_card_skeleton.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/state_views.dart';
import 'article_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  bool _hasSearched = false;

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _debounceTimer = null;
      setState(() => _hasSearched = false);
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      setState(() => _hasSearched = true);
      context.read<NewsProvider>().searchNews(trimmed);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari berita...',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!_hasSearched) {
      return const EmptyStateView(
        icon: Icons.search_rounded,
        title: 'Cari berita apa hari ini?',
        subtitle: 'Ketik kata kunci di atas.',
      );
    }

    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.articles.isEmpty) {
          return const ArticleListSkeleton();
        }

        if (provider.errorMessage != null && provider.articles.isEmpty) {
          return ErrorStateView(
            message: provider.errorMessage!,
            onRetry: () => provider.searchNews(_controller.text.trim()),
          );
        }

        if (provider.articles.isEmpty) {
          return const EmptyStateView(
            icon: Icons.search_off_rounded,
            title: 'Gak ketemu, nih',
            subtitle: 'Coba kata kunci lain ya.',
          );
        }

        return ListView.builder(
          itemCount: provider.articles.length,
          itemBuilder: (context, index) {
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
        );
      },
    );
  }
}

