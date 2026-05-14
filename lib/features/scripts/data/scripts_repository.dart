import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zapret_ui/core/utils/constants.dart';
import 'package:zapret_ui/features/scripts/data/models/script_model.dart';

@injectable
class ScriptsRepository {
  ScriptsRepository({required this.prefs});

  final SharedPreferences prefs;

  Future<List<ScriptModel>> getScripts() async {
    try {
      final zapretDirPath = join(
        (await getApplicationCacheDirectory()).path,
        Constants.zapretFolderName,
      );
      final directory = Directory(zapretDirPath);

      if (!(await directory.exists())) return [];

      return directory
          .listSync()
          .where(
            (entity) =>
                entity is File &&
                entity.path.endsWith('.bat') &&
                basename(entity.path) != 'service.bat',
          )
          .map((file) => ScriptModel(name: basename(file.path)))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  ScriptModel? getSelectedScript() {
    final result = prefs.getString(PrefsKeys.selectedScript);

    if (result == null) return null;

    return ScriptModel.fromJson(result);
  }

  Future<void> setSelectedScript(ScriptModel? script) async {
    if (script == null) {
      await prefs.remove(PrefsKeys.selectedScript);
      return;
    }
    await prefs.setString(PrefsKeys.selectedScript, script.toJson());
  }
}
