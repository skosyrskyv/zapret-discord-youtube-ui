import 'package:injectable/injectable.dart';
import 'package:zapret_ui/features/scripts/data/models/script_model.dart';
import 'package:zapret_ui/features/scripts/data/scripts_repository.dart';

@injectable
class SetSelectedScriptUsecase {
  SetSelectedScriptUsecase({required this.repository});

  final ScriptsRepository repository;

  Future<void> call(ScriptModel? script) async {
    return await repository.setSelectedScript(script);
  }
}
