import 'package:get/get.dart';

import '../services/news_service.dart';

/// Dependency injection global, di-load sekali saat aplikasi start.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<NewsService>(NewsService(), permanent: true);
  }
}
