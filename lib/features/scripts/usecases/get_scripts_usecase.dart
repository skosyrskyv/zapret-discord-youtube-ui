import 'package:injectable/injectable.dart';
import 'package:zapret_ui/features/scripts/data/models/script_model.dart';
import 'package:zapret_ui/features/scripts/data/scripts_repository.dart';

@injectable
class GetScriptsUsecase {
  GetScriptsUsecase({required this.repository});

  final ScriptsRepository repository;

  Future<List<ScriptModel>> call() async {
    return await repository.getScripts();
  }
}
