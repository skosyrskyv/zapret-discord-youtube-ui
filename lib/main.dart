import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zapret_ui/app.dart';
import 'package:path/path.dart' as path;

final logger = Logger('main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await _setupWindowOptions();
  await _setupLogger();

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

Future<void> _setupLogger() async {
  final logsFile = File(path.join(Directory.current.path, 'logs.txt'));

  if (!logsFile.existsSync()) {
    await logsFile.create();
  }

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) async {
    logsFile.writeAsString(
      '${record.time.toString().substring(0, 18)} [${record.level.name}] : ${record.message} | ${record.error} \n${record.stackTrace}\n',
      mode: FileMode.writeOnlyAppend,
    );
  });
}
