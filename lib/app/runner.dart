import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zapret_ui/app/main_app.dart';
import 'package:zapret_ui/features/installer/presentation/controllers/version_controller.dart';
import 'package:zapret_ui/features/process/presentation/controllers/process_controller.dart';
import 'package:zapret_ui/features/scripts/presentation/controllers/scripts_controller.dart';

import 'runner.config.dart';

final l = Logger.root;
final getIt = GetIt.instance;

class Runner {
  static Future<void> run() async {
    runZonedGuarded(_runApp, _errorHandler);
  }

  static Future<void> _initializeFlutterPluginsAndDependencies() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    await _setupWindowOptions();
    await _configureDependencies();
  }

  static Future<void> _initializeControllers() async {
    await getIt.get<VersionController>().init();
    await getIt.get<ProcessController>().init();
    await getIt.get<ScriptsController>().init();
  }

  static void _runApp() async {
    try {
      await _setupLogger();
      await _initializeFlutterPluginsAndDependencies();
      await _initializeControllers();
    } catch (exception, stacktrace) {
      l.shout("App initialization error", exception, stacktrace);
      return;
    }
    runApp(const MainApp());
  }

  static Future<void> _errorHandler(
    Object? exception,
    StackTrace stacktrace,
  ) async {
    Logger.root.shout('UNHANDLED', exception, stacktrace);
  }
}

// WINDOW
Future<void> _setupWindowOptions() async {
  WindowOptions windowOptions = WindowOptions(
    size: Size(600, 900),
    minimumSize: Size(600, 900),
    backgroundColor: Colors.transparent,
    title: "Zapret UI",
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

// LOGGER
Future<void> _setupLogger() async {
  final logFileName = DateTime.now().toString().split(' ').first;
  final logsDir = Directory(
    join((await getApplicationCacheDirectory()).path, 'logs'),
  );

  if (!(await logsDir.exists())) {
    await logsDir.create();
  }

  final logsFile = File(join(logsDir.path, '$logFileName.txt'));

  if (!logsFile.existsSync()) {
    await logsFile.create();
  }

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) async {
    debugPrint(
      '${record.time.toString().split(' ').last} [${record.level.name}] ${record.message} ${record.error ?? ''} ${record.stackTrace == null ? '' : '\n'} ${record.stackTrace ?? ''}'
          .trimRight(),
    );
    await logsFile.writeAsString(
      '\n${record.time.toString().split(' ').last} [${record.level.name}] ${record.message} ${record.error ?? ''} ${record.stackTrace == null ? '' : '\n'} ${record.stackTrace ?? ''}'
          .trimRight(),
      mode: FileMode.writeOnlyAppend,
    );
  });
}

// GET IT INITIALIZATION
@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> _configureDependencies() async {
  await $initGetIt(getIt);
}

@module
abstract class InjectableModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs async => SharedPreferences.getInstance();
}
