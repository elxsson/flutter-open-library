import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class AppBottomNav extends HookWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    return BottomNavigationBar(
      currentIndex: selectedIndex.value,
      onTap: (index) {
        selectedIndex.value = index;
        switch (index) {
          case 0:
            Get.toNamed('/');
            break;
          case 1:
            Get.toNamed('/search');
            break;
          case 2:
            Get.toNamed('/about');
            break;
        }
      },
      backgroundColor: AppColors.secondary,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.accent,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          activeIcon: Icon(Icons.info),
          label: 'About',
        ),
      ],
    );
  }
}
