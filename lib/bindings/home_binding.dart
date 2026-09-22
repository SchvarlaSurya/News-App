import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';

/// Jaring pengaman: kalau halaman home dibuka langsung (mis. deep link)
/// tanpa melewati AppBindings, controller tetap tersedia.
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NewsController>()) {
      Get.put<NewsController>(NewsController(), permanent: true);
    }
  }
}
