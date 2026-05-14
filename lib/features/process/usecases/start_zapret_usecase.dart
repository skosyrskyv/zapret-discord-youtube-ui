import 'package:injectable/injectable.dart';
import 'package:zapret_ui/core/utils/precess_runner.dart';
import 'package:zapret_ui/features/scripts/data/scripts_repository.dart';

@injectable
class StartZapretUseCase {
  StartZapretUseCase({
    required ProcessRunner processRunner,
    required ScriptsRepository repository,
  }) : _processRunner = processRunner,
       _repository = repository;

  final ScriptsRepository _repository;
  final ProcessRunner _processRunner;

  Future<void> call() async {
    try {
      final selectedScript = _repository.getSelectedScript();

      if (selectedScript == null) {
        throw Exception('Выберете скрипт');
      }

      await _processRunner.run(selectedScript.name);
    } catch (e) {
      rethrow;
    }
  }
}
