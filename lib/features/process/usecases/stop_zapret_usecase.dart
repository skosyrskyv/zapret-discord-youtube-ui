import 'package:injectable/injectable.dart';
import 'package:zapret_ui/core/utils/precess_runner.dart';

@injectable
class StopZapretUseCase {
  StopZapretUseCase({required ProcessRunner processRunner})
    : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  Future<void> call() async {
    try {
      await _processRunner.stop();
    } catch (e) {
      rethrow;
    }
  }
}
