import 'package:injectable/injectable.dart';
import 'package:zapret_ui/features/scripts/data/models/script_model.dart';
import 'package:zapret_ui/features/scripts/data/scripts_repository.dart';

@injectable
class GetSelectedScriptUsecase {
  GetSelectedScriptUsecase({required this.repository});

  final ScriptsRepository repository;

  ScriptModel? call() {
    return repository.getSelectedScript();
  }
}
