import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zapret_ui/app/runner.dart';
import 'package:zapret_ui/core/utils/constants.dart';

@singleton
class ProcessRunner {
  ProcessRunner() {
    _streamController = StreamController<bool>.broadcast(
      onListen: _startWatching,
    );
  }

  late final StreamController<bool> _streamController;
  Timer? _polingTimer;

  Future<void> run(String scriptName) async {
    final appDir = await getApplicationCacheDirectory();
    final scriptPath = join(appDir.path, Constants.serviceFilePath);

    try {
      l.info('[PROCESS RUNNER] Starting zapret process: $scriptName');

      await Process.start(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          'Start-Process cmd -ArgumentList \'/c "$scriptPath install "$scriptName" "\' -Verb RunAs -WindowStyle Hidden',
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stop() async {
    final appDir = await getApplicationCacheDirectory();
    final scriptPath = join(appDir.path, Constants.serviceFilePath);

    try {
      l.info('[PROCESS RUNNER] Stopping zapret process');

      await Process.start(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          'Start-Process cmd -ArgumentList \'/c "$scriptPath remove"\' -Verb RunAs -WindowStyle Hidden',
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> status() async {
    try {
      final result = await Process.run('tasklist', [
        '/FI',
        'IMAGENAME eq winws.exe',
      ]);

      return result.stdout.toString().contains('winws.exe');
    } catch (_) {
      rethrow;
    }
  }

  Stream<bool> watch() {
    return _streamController.stream;
  }

  void _startWatching() {
    _polingTimer ??= Timer.periodic(Duration(seconds: 3), _processListener);
  }

  void _processListener(_) async {
    _streamController.add(await status());
  }
}
