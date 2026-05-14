import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class GitHubRepoDownloader {
  /// Скачивает ZIP-архив репозитория и распаковывает его
  /// [repoUrl] - URL репозитория GitHub (например, https://github.com/username/repo)
  /// [targetFolderName] - имя новой папки для распаковки (без пути)
  /// Возвращает путь к распакованной папке
  static Future<String> downloadAndExtract(
    String repoUrl,
    String targetFolderName,
  ) async {
    try {
      String zipUrl = _getZipUrl(repoUrl);
      Directory tempDir = await getTemporaryDirectory();
      Directory appCacheDir = await getApplicationCacheDirectory();
      Directory targetDir = Directory(join(appCacheDir.path, targetFolderName));

      String tempZipPath = join(tempDir.path, 'temp_repo.zip');

      if (await targetDir.exists()) {
        await targetDir.delete(recursive: true);
      }
      await targetDir.create(recursive: true);

      await _downloadFile(zipUrl, tempZipPath);
      await _extractZip(tempZipPath, targetDir.path);

      await File(tempZipPath).delete();
      return targetDir.path;
    } catch (e) {
      throw Exception('Ошибка при скачивании/распаковке: $e');
    }
  }

  static String _getZipUrl(String repoUrl) {
    String cleanUrl = repoUrl.endsWith('.git')
        ? repoUrl.substring(0, repoUrl.length - 4)
        : repoUrl;
    return '$cleanUrl/archive/refs/heads/main.zip';
  }

  static Future<void> _downloadFile(String url, String savePath) async {
    final request = http.Request('GET', Uri.parse(url));

    request.headers.addAll({
      'User-Agent': 'ZapretUI',
      'Accept': 'application/zip, application/octet-stream, */*',
      'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'cross-site',
    });

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception(
        'Не удалось скачать файл. Статус: ${response.statusCode}',
      );
    }

    final file = File(savePath);
    final sink = file.openWrite();

    await response.stream.pipe(sink);
    await sink.flush();
    await sink.close();
  }

  static Future<void> _extractZip(String zipPath, String targetPath) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    String? rootFolderName;
    for (var file in archive) {
      if (file.isFile) {
        List<String> parts = file.name.split('/');

        if (parts.isNotEmpty) {
          rootFolderName = parts[0];
          break;
        }
      }
    }

    for (var file in archive) {
      if (file.isFile) {
        String relativePath = file.name;

        if (rootFolderName != null && relativePath.startsWith(rootFolderName)) {
          relativePath = relativePath.substring(rootFolderName.length + 1);
        }

        if (relativePath.isNotEmpty) {
          String fullPath = join(targetPath, relativePath);
          File(fullPath).createSync(recursive: true);
          List<int>? content = file.content;
          await File(fullPath).writeAsBytes(content);
        }
      }
    }
  }
}
