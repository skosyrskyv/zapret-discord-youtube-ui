import 'package:flutter/material.dart';

class AppTheme {
  final AppColorScheme _colorScheme = AppColorScheme();

  ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme.dark,
    highlightColor: Colors.transparent,
    splashColor: const Color.fromARGB(31, 80, 80, 80),
  );
}

class AppColorScheme {
  ColorScheme get dark => ColorScheme.fromSeed(
    brightness: Brightness.dark,
    primary: const Color.fromARGB(255, 255, 255, 255),
    onPrimary: Colors.black,
    seedColor: Colors.grey,
  );
}
