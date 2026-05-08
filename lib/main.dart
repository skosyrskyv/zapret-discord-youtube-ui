import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zapret_ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await _setupWindowOptions();

  runApp(const MainApp());
}

Future<void> _setupWindowOptions() async {
  WindowOptions windowOptions = WindowOptions(
    size: Size(600, 900),
    minimumSize: Size(600, 900),
    backgroundColor: Colors.transparent,
    title: "Zapret UI",
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
