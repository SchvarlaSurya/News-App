import 'package:get/get.dart';

import '../bindings/home_binding.dart';
import '../views/home_view.dart';
import '../views/news_detail_view.dart';
import '../views/splash_view.dart';
import 'app_routes.dart';

/// Definisi semua GetPage.
class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.newsDetail,
      page: () => const NewsDetailView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
