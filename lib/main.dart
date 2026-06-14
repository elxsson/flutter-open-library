import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/screens/book_detail_screen.dart';
import 'ui/screens/author_screen.dart';
import 'ui/screens/subject_screen.dart';
import 'ui/screens/about_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Book Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/search', page: () => const SearchScreen()),
        GetPage(name: '/book', page: () => const BookDetailScreen()),
        GetPage(name: '/author', page: () => const AuthorScreen()),
        GetPage(name: '/subject', page: () => const SubjectScreen()),
        GetPage(name: '/about', page: () => const AboutScreen()),
      ],
    );
  }
}
