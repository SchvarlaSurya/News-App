import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';

/// Controller dibuat sekali untuk seluruh aplikasi, supaya bookmark, tema,
/// dan riwayat pencarian tetap sama di semua halaman.
class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<NewsController>(NewsController(), permanent: true);
  }
}
