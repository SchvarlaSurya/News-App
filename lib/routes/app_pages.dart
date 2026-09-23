// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:news_app/bindings/home_binding.dart';
import 'package:news_app/views/bookmark_view.dart';
import 'package:news_app/views/news_detail_view.dart';
import 'package:news_app/views/root_view.dart';
import 'package:news_app/views/search_view.dart';
import 'package:news_app/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: _Paths.SPLASH, page: () => const SplashView()),
    GetPage(
      name: _Paths.HOME,
      page: () => const RootView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.NEWS_DETAIL,
      page: () => const NewsDetailView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      transition: Transition.downToUp,
    ),
    GetPage(name: _Paths.BOOKMARKS, page: () => const BookmarkView()),
  ];
}
