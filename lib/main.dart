import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // 這一行就是修正紅字的關鍵！

void main() {
  runApp(const SoraTalkApp());
}

class SoraTalkApp extends StatelessWidget {
  const SoraTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoraTalk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // 這裡指向我們新寫好的主選單頁面
      home: const HomePage(), 
    );
  }
}