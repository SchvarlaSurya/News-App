import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news_app/bindings/app_bindings.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Tanggal & waktu relatif dalam bahasa Indonesia.
  await initializeDateFormatting('id_ID');
  timeago.setLocaleMessages('id', timeago.IdMessages());

  // Baca pilihan tema sebelum aplikasi tampil supaya tidak berkedip terang.
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool(StorageKeys.darkMode) ?? false;

  runApp(MyApp(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;

  const MyApp({super.key, this.themeMode = ThemeMode.light});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
    );
  }
}
