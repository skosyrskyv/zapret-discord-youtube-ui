import 'package:flutter/material.dart';

class AppTheme {
  ThemeData get light => ThemeData.light(useMaterial3: true);

  ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme().dark,
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
