import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bindings/app_bindings.dart';
import 'routes/app_pages.dart';
import 'utils/app_colors.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: 'assets/.env');

  await initializeDateFormatting('id_ID');

  // Baca tema tersimpan sebelum runApp biar gak kedip light -> dark.
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool(StorageKeys.isDarkMode) ?? false;

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
      initialBinding: AppBindings(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
