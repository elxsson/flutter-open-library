import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AboutScreen extends HookWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(child: Text('About Screen - Coming Soon')),
    );
  }
}
