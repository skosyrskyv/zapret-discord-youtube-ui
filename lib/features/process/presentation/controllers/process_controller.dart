import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:zapret_ui/app/runner.dart';
import 'package:zapret_ui/core/utils/controller.dart';
import 'package:zapret_ui/core/utils/event_manager.dart';
import 'package:zapret_ui/features/process/usecases/start_zapret_usecase.dart';
import 'package:zapret_ui/features/process/usecases/stop_zapret_usecase.dart';
import 'package:zapret_ui/features/process/usecases/watch_zapret_status_usecase.dart';
import 'package:zapret_ui/features/scripts/presentation/controllers/scripts_controller.dart';

@singleton
final class ProcessController extends StateController {
  ProcessController({
    required EventManager eventManager,
    required StartZapretUseCase startZapretUseCase,
    required StopZapretUseCase stopZapretUseCase,
    required WatchZapretUseCase watchZapretUseCase,
  }) : _eventManager = eventManager,
       _startZapretUseCase = startZapretUseCase,
       _stopZapretUseCase = stopZapretUseCase,
       _watchZapretUseCase = watchZapretUseCase;

  final EventManager _eventManager;
  final StartZapretUseCase _startZapretUseCase;
  final StopZapretUseCase _stopZapretUseCase;
  final WatchZapretUseCase _watchZapretUseCase;

  bool _isRunning = false;
  Action? _onScriptChangedEvent;
  StreamSubscription? _processStatusSubscription;

  bool get isRunning => _isRunning;
  void _setIsRunning(bool value) {
    if (value != _isRunning) {
      _isRunning = value;
      notifyListeners();
      l.info(
        '[PROCESS CONTROLLER] Zapret process status: ${_isRunning ? 'RUNNING' : 'STOPPING'}',
      );
    }
  }

  Future<void> switchZapret() async {
    if (_isRunning) {
      await _stopZapret();
    } else {
      await _startZapret();
    }
  }

  @override
  Future<void> init() async {
    _processStatusSubscription = _watchZapretUseCase().listen(_setIsRunning);
    _onScriptChangedEvent = _eventManager.on<ScriptChangedEvent>(
      _restartZapret,
    );
    super.init();
  }

  @override
  void dispose() {
    _processStatusSubscription?.cancel();
    _onScriptChangedEvent?.unsubscribe();
    super.dispose();
  }

  Future<void> _startZapret() async {
    if (isLoading || _isRunning) return;
    startLoading();
    try {
      await _startZapretUseCase();
      await _watchZapretUseCase()
          .firstWhere((value) => value == true)
          .timeout(const Duration(seconds: 10));
    } catch (e, stacktrace) {
      l.shout('[PROCESS CONTROLLER] Start zapret error', e, stacktrace);
    } finally {
      stopLoading();
    }
  }

  Future<void> _stopZapret() async {
    if (isLoading || !_isRunning) return;
    startLoading();
    try {
      await _stopZapretUseCase();
      await _watchZapretUseCase()
          .firstWhere((value) => value == false)
          .timeout(const Duration(seconds: 10));
    } catch (e, stacktrace) {
      l.shout('[PROCESS CONTROLLER] Stop zapret error:', e, stacktrace);
    } finally {
      stopLoading();
    }
  }

  Future<void> _restartZapret() async {
    if (!_isRunning) return;
    await _stopZapret();
    await Future.delayed(const Duration(seconds: 1));
    await _startZapret();
  }
}
