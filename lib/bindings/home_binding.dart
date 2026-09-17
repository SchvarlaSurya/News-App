import 'package:get/get.dart';

import '../controllers/news_controller.dart';
import '../services/news_service.dart';

/// DI untuk halaman home. NewsController juga dipakai NewsDetailView
/// (bookmark), jadi tetap hidup selama home ada di stack.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(
      () => NewsController(newsService: Get.find<NewsService>()),
    );
  }
}
