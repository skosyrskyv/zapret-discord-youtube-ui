import 'dart:io';

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

      final sourceFilePath = join(
        Directory.current.path,
        Constants.assetsPath,
        Constants.serviceFilePath,
      );

      final targetDir = Directory(dirname(targetFilePath));

      if (!(await targetDir.exists())) {
        await targetDir.create();
      }

      await File(sourceFilePath).copy(targetFilePath);
    } catch (e) {
      rethrow;
    }
  }
}
