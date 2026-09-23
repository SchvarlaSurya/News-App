import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/views/bookmark_view.dart';
import 'package:news_app/views/home_view.dart';
import 'package:news_app/views/search_view.dart';

/// Rangka utama aplikasi: tiga tab yang tetap hidup saat berpindah, jadi
/// posisi scroll dan hasil pencarian tidak hilang.
class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeView(), SearchView(), BookmarkView()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: Obx(
              () => _BookmarkIcon(
                count: controller.bookmarks.length,
                icon: Icons.bookmark_outline,
              ),
            ),
            selectedIcon: Obx(
              () => _BookmarkIcon(
                count: controller.bookmarks.length,
                icon: Icons.bookmark,
              ),
            ),
            label: 'Tersimpan',
          ),
        ],
      ),
    );
  }
}

/// Ikon bookmark dengan jumlah artikel tersimpan.
class _BookmarkIcon extends StatelessWidget {
  final int count;
  final IconData icon;

  const _BookmarkIcon({required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return Icon(icon);

    return Badge.count(
      count: count,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(icon),
    );
  }
}
