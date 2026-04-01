import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/main_tab_bar.dart';
import 'constants/app_colors.dart';
import 'services/db_helper.dart';
import 'services/download_service.dart';
import 'services/novel_service.dart';
import 'services/ad_service.dart';
import 'services/reading_settings_service.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await DBHelper.instance.initDB();
  Get.put(NovelService());
  Get.put(ReadingSettingsService());
  Get.put(DownloadService());
  Get.put(SubscriptionService());
  Get.put(AdService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: '小說閱讀器',
          debugShowCheckedModeBanner: false,
          theme: MaterialTheme(
            GoogleFonts.notoSansTextTheme(),
          ).light(),
          darkTheme: MaterialTheme(
            GoogleFonts.notoSansTextTheme(),
          ).dark(),
          themeMode: ThemeMode.system,
          home: const MainTabBar(),
        );
      },
    );
  }
}
