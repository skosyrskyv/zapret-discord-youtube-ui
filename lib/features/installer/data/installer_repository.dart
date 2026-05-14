import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zapret_ui/core/utils/constants.dart';
import 'package:zapret_ui/core/utils/downloader.dart';
import 'package:zapret_ui/core/utils/precess_runner.dart';

@injectable
class InstallerRepository {
  InstallerRepository({
    required this.prefs,
    required this.processRunner,
  });

  final SharedPreferences prefs;
  final ProcessRunner processRunner;

  Future<void> downloadAndInstall() async {
    await processRunner.stop();
    await GitHubRepoDownloader.downloadAndExtract(
      WebLinks.zapretRepositoryUrl,
      Constants.zapretFolderName,
    );
    await installMainScript();
  }

  // Скачивает с репозитория запрета файл version.txt и достают оттуда версию.
  // Частые запросы делать нельзя тк git кидает в бан лист.
  Future<String?> getRemoteVersion() async {
    try {
      int? diff;
      DateTime? lastFetch;

      final lastFetchString = prefs.getString(
        PrefsKeys.lastVersionFetchDateTime,
      );

      if (lastFetchString != null) {
        lastFetch = DateTime.tryParse(lastFetchString);
      }

      if (lastFetch != null) {
        diff = DateTime.now().difference(lastFetch).abs().inHours;
      }

      if (diff != null && diff <= 12) {
        return prefs.getString(PrefsKeys.remoteZapretVersion);
      }

      final response = await http.get(
        Uri.parse(WebLinks.zapretVersionUrl),
        headers: {
          'User-Agent': 'ZapretUI/1.0 (Windows; Flutter)',
          'Accept': 'text/plain',
        },
      );

      bool ok = await prefs.setString(
        PrefsKeys.remoteZapretVersion,
        response.body,
      );

      if (!ok) throw Exception('Set Zapret remote version error');

      ok = await prefs.setString(
        PrefsKeys.lastVersionFetchDateTime,
        DateTime.now().toIso8601String(),
      );

      if (!ok) throw Exception('Set last version fetch error');

      return response.body;
    } catch (e) {
      rethrow;
    }
  }

  // Ищет в папке с установленным запретом файл version.txt и берет из него версию.
  Future<String?> getLocalVersion() async {
    try {
      final zapretPath = join(
        (await getApplicationCacheDirectory()).path,
        Constants.zapretFolderName,
      );
      final zapretDir = Directory(zapretPath);
      final isNotInstalled =
          !(await zapretDir.exists()) || (await zapretDir.list().isEmpty);

      if (isNotInstalled) return null;

      final versionFile = File(
        join(zapretPath, '.service', 'version.txt'),
      );

      if (!(await versionFile.exists())) {
        throw Exception('Version file does not exist');
      }

      final version = await versionFile.readAsString();

      final ok = await prefs.setString(
        PrefsKeys.installedZapretVersion,
        version,
      );

      if (!ok) throw Exception('Set installed zapret version error');

      return version;
    } catch (_) {
      rethrow;
    }
  }

  /// Копирует bat файл из папки с ассетами в локальную директорию (../AppData/Local/zapret_ui/bin/).
  Future<void> installMainScript() async {
    try {
      final targetFilePath = join(
        (await getApplicationCacheDirectory()).path,
        Constants.serviceFilePath,
      );

      final byteData = await rootBundle.load(
        // не понимает путь с "\" слешами
        join(
          Constants.assetsPath,
          Constants.serviceFilePath,
        ).replaceAll('\\', '/'),
      );
      final bytes = byteData.buffer.asUint8List();

      final targetFile = File(targetFilePath);
      await targetFile.parent.create(recursive: true);

      await File(targetFilePath).writeAsBytes(bytes);
    } catch (e) {
      rethrow;
    }
  }
}
