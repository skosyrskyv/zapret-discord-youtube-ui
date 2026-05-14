import 'package:flutter/material.dart';
import 'package:zapret_ui/core/utils/theme.dart';
import 'package:zapret_ui/features/home/home_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().dark,
      home: HomeScreen(),
    );
  }
}
