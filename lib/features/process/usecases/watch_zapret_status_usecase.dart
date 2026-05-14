import 'package:injectable/injectable.dart';
import 'package:zapret_ui/core/utils/precess_runner.dart';

@injectable
class WatchZapretUseCase {
  WatchZapretUseCase({
    required ProcessRunner processRunner,
  }) : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  Stream<bool> call() {
    return _processRunner.watch();
  }
}
