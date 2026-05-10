import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zapret_ui/main.dart';
import 'package:zapret_ui/utils/constants.dart';
import 'package:zapret_ui/utils/downloader.dart';

class MainController extends ChangeNotifier {
  MainController() {
    _init();
  }

  late SharedPreferences _prefs;

  Timer? _timer;
  String? _lastRemoteVersionFetch;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isZapretInstalled = false;
  bool get isZapretInstalled => _isZapretInstalled;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  String? _selectedScript;
  String? get selectedScript => _selectedScript;

  String? _version;
  String? get version => _version;

  String? _remoteVersion;
  String? get remoteVersion => _remoteVersion;

  List<String> scripts = [];

  void _setIsRunning(bool value) {
    if (value != _isRunning) {
      _isRunning = value;
      notifyListeners();
    }
  }

  void _setIsLoading(bool value) {
    if (value != _isLoading) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setIsZapretDirExist(bool value) {
    if (value != _isZapretInstalled) {
      _isZapretInstalled = value;
      notifyListeners();
    }
  }

  void _setIsDownloading(bool value) {
    if (value != _isDownloading) {
      _isDownloading = value;
      notifyListeners();
    }
  }

  void _setSelectedScript(String? value) async {
    if (value != _selectedScript) {
      _selectedScript = value;
      notifyListeners();
      if (value != null) {
        await _prefs.setString(PrefsKeys.lastSelectedScript, value);
      }
    }
  }

  void _setVersion(String? value) async {
    if (value != _version) {
      _version = value;
      notifyListeners();
      if (value != null) {
        await _prefs.setString(PrefsKeys.installedZapretVersion, value);
      }
    }
  }

  void _setRemoteVersion(String? value) async {
    if (value != _remoteVersion) {
      _remoteVersion = value;
      notifyListeners();
      if (value != null) {
        await _prefs.setString(PrefsKeys.remoteZapretVersion, value);
      }
    }
  }

  void changeScript(String? script) async {
    _setSelectedScript(script);
    _restartZapret();
  }

  Future<void> downloadZapret() async {
    if (_isDownloading) return;
    if (isRunning) {
      await _stopZapret();
    }

    _setIsDownloading(true);
    try {
      await GitHubRepoDownloader.downloadAndExtract(
        WebLinks.zapretRepositoryUrl,
        Constants.zapretFolderName,
      );
      _getAvailableScripts();
      _checkZapretInstalled();
    } catch (e, stacktrace) {
      logger.shout('Download Zapret error', e, stacktrace);
    } finally {
      _setIsDownloading(false);
    }
  }

  Future<void> switchZapret() async {
    if (_selectedScript == null) return;
    if (_isRunning) {
      await _stopZapret();
    } else {
      await _startZapret();
    }
  }

  void _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _setupVariables();

    _initMainScript();
    _checkZapretInstalled();
    _startZapretProcessCheck();
    _getAvailableScripts();
    _getRemoteVersion();
  }

  Future<void> _startZapret() async {
    if (_isLoading || _isRunning || !isZapretInstalled || _isDownloading) {
      return;
    }
    _setIsLoading(true);
    try {
      final appDirPath = Directory.current.path;
      final scriptPath = path.join(appDirPath, 'main.bat');

      await Process.start(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          'Start-Process cmd -ArgumentList \'/c "$scriptPath install "$_selectedScript" "\' -Verb RunAs -WindowStyle Hidden',
        ],
      );
      await Future.delayed(Duration(seconds: 2));
    } catch (e, stacktrace) {
      logger.shout('Start zapret error', e, stacktrace);
    } finally {
      _setIsLoading(false);
    }
  }

  // STOP
  Future<void> _stopZapret() async {
    if (_isLoading || !_isRunning) return;
    _setIsLoading(true);
    try {
      final appDirPath = Directory.current.path;
      final scriptPath = path.join(appDirPath, 'main.bat');

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
      await Future.delayed(Duration(seconds: 2));
    } catch (e, stacktrace) {
      logger.shout('Stop zapret error:', e, stacktrace);
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> _restartZapret() async {
    if (!_isRunning) return;
    await _stopZapret();
    await _startZapret();
  }

  void _getAvailableScripts() {
    final zapretDirPath = path.join(
      Directory.current.path,
      Constants.zapretFolderName,
    );
    try {
      final directory = Directory(zapretDirPath);
      if (directory.existsSync()) {
        final files = directory
            .listSync()
            .where(
              (entity) =>
                  entity is File &&
                  entity.path.endsWith('.bat') &&
                  path.basename(entity.path)[0] == 'g',
            )
            .map((file) => path.basename(file.path))
            .toList();
        scripts = [...files];
        notifyListeners();
      } else {
        throw Exception('Zapret directory doesn`t exist');
      }
    } catch (e, stacktrace) {
      logger.shout('Error scanning directory', e, stacktrace);
    }
  }

  Future<void> _checkProcessStatus(_) async {
    try {
      final result = await Process.run('tasklist', [
        '/FI',
        'IMAGENAME eq winws.exe',
      ]);

      final res = result.stdout.toString().contains('winws.exe');
      _setIsRunning(res);
    } catch (e, stacktrace) {
      logger.shout(
        'Process winws.exe checking status error',
        e,
        stacktrace,
      );
    }
  }

  Future<void> _getRemoteVersion() async {
    try {
      if (_lastRemoteVersionFetch != null) {
        final lastFetch = DateTime.parse(_lastRemoteVersionFetch!);
        if (DateTime.now().difference(lastFetch).abs().inHours <= 12) {
          return;
        }
      }

      final uri = Uri.parse(WebLinks.zapretVersionUrl);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'ZapretUI/1.0 (Windows; Flutter)',
          'Accept': 'text/plain',
        },
      );

      _setRemoteVersion(response.body);
      await _prefs.setString(
        PrefsKeys.lastVersionFetchDateTime,
        DateTime.now().toIso8601String(),
      );
    } catch (e, stacktrace) {
      logger.shout('Checking new version error', e, stacktrace);
    }
  }

  Future<void> _checkZapretInstalled() async {
    try {
      final zapretDir = Directory(
        path.join(Directory.current.path, Constants.zapretFolderName),
      );
      _setIsZapretDirExist(
        zapretDir.existsSync() && zapretDir.listSync().isNotEmpty,
      );
      final zapretVersion = await File(
        path.join(zapretDir.path, '.service', 'version.txt'),
      ).readAsString();
      _setVersion(zapretVersion);
    } catch (e, stacktrace) {
      logger.shout('Directory reading error', e, stacktrace);
    }
  }

  Future<void> _initMainScript() async {
    final mainScriptPath = path.join(Directory.current.path, 'main.bat');
    final mainScriptFile = File(mainScriptPath);

    if (mainScriptFile.existsSync()) return;

    try {
      final mainBatContent = await rootBundle.loadString('assets/bin/main.bat');
      await mainScriptFile.writeAsString(mainBatContent);
    } catch (e, stacktrace) {
      logger.shout('main.bat init error', e, stacktrace);
    }
  }

  Future<void> _setupVariables() async {
    _selectedScript = _prefs.getString(PrefsKeys.lastSelectedScript);
    _version = _prefs.getString(PrefsKeys.installedZapretVersion);
    _remoteVersion = _prefs.getString(PrefsKeys.remoteZapretVersion);
    _lastRemoteVersionFetch = _prefs.getString(
      PrefsKeys.lastVersionFetchDateTime,
    );
    notifyListeners();
  }

  void _startZapretProcessCheck() {
    _timer = Timer.periodic(Duration(seconds: 1), _checkProcessStatus);
  }

  void _stopZapretProcessCheck() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopZapretProcessCheck();
    super.dispose();
  }
}
