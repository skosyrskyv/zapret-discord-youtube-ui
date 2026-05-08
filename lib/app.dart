import 'package:flutter/material.dart';
import 'package:zapret_ui/screens/main_screen.dart';
import 'package:zapret_ui/utils/theme.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().dark,
      home: MainScreen(),
    );
  }
}
