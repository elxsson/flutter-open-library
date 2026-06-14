import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BookDetailScreen extends HookWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Detail')),
      body: const Center(child: Text('Book Detail Screen - Coming Soon')),
    );
  }
}
