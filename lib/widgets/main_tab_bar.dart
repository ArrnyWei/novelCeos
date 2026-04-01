import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/home/home_controller.dart';
import '../pages/home/home_page.dart';
import '../pages/library/library_controller.dart';
import '../pages/library/library_page.dart';
import '../pages/settings/settings_page.dart';

class MainTabController extends GetxController {
  var currentIndex = 0.obs;

  int _lastTappedIndex = -1;
  DateTime? _lastTapTime;

  void changeTab(int index) {
    if (_lastTappedIndex == index && _lastTapTime != null) {
      final diff = DateTime.now().difference(_lastTapTime!);
      if (diff.inMilliseconds < 600) {
        _handleDoubleTap(index);
        _lastTapTime = null;
        _lastTappedIndex = -1;
        return;
      }
    }

    _lastTappedIndex = index;
    _lastTapTime = DateTime.now();
    currentIndex.value = index;

    if (index == 0 && Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchHome();
    }
    if (index == 1 && Get.isRegistered<LibraryController>()) {
      Get.find<LibraryController>().refresh();
    }
  }

  void _handleDoubleTap(int index) {
    switch (index) {
      case 0:
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().scrollToTop();
        }
        break;
      case 1:
        if (Get.isRegistered<LibraryController>()) {
          Get.find<LibraryController>().scrollToTop();
        }
        break;
    }
  }
}

class MainTabBar extends StatelessWidget {
  const MainTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainTabController());

    const List<Widget> pages = [
      HomePage(),
      LibraryPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: '首頁',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: '書庫',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: '設定',
              ),
            ],
          )),
    );
  }
}
