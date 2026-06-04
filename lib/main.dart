import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const BaishamenApp());
}

class BaishamenApp extends StatelessWidget {
  const BaishamenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '白沙门 AR 寻宝',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
