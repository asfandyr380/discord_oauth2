import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/mobile_screen.dart';
import 'screens/web_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discord OAuth2 Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5865F2),
          brightness: kIsWeb ? Brightness.dark : Brightness.light,
        ),
      ),
      home: kIsWeb ? const WebScreen() : const MobileScreen(),
    );
  }
}
