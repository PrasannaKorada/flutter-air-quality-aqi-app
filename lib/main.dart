import 'package:flutter/material.dart';
import 'home_screen.dart'; // ✅ correct path if in lib/

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AQIHome(), // ✅ AQIHome is the main screen now
    );
  }
}
