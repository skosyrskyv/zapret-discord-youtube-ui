import "package:injectable/injectable.dart";
import "package:zapret_ui/app/runner.dart";
import "package:zapret_ui/core/utils/controller.dart";
import "package:zapret_ui/core/utils/event_manager.dart";
import "package:zapret_ui/features/installer/presentation/controllers/version_controller.dart";
import "package:zapret_ui/features/scripts/data/models/script_model.dart";
import "package:zapret_ui/features/scripts/usecases/get_scripts_usecase.dart";
import "package:zapret_ui/features/scripts/usecases/get_selected_script_usecase.dart";
import "package:zapret_ui/features/scripts/usecases/set_selected_script_usecase.dart";

class ScriptChangedEvent extends Event {}

@singleton
final class ScriptsController extends StateController {
  ScriptsController({
    required EventManager eventManager,
    required GetScriptsUsecase getScriptsUsecase,
    required SetSelectedScriptUsecase setSelectedScriptUsecase,
    required GetSelectedScriptUsecase getSelectedScriptUsecase,
  }) : _eventManager = eventManager,
       _getScriptsUsecase = getScriptsUsecase,
       _getSelectedScriptUsecase = getSelectedScriptUsecase,
       _setSelectedScriptUsecase = setSelectedScriptUsecase;

  final EventManager _eventManager;
  final GetScriptsUsecase _getScriptsUsecase;
  final SetSelectedScriptUsecase _setSelectedScriptUsecase;
  final GetSelectedScriptUsecase _getSelectedScriptUsecase;

  List<ScriptModel> scripts = [];
  ScriptModel? _selectedScript;

  ScriptModel? get selectedScript => _selectedScript;

  void _setSelectedScript(ScriptModel? value) async {
    if (value == _selectedScript) return;
    startLoading();
    try {
      _selectedScript = value;
      await _setSelectedScriptUsecase(value);
      _eventManager.emit(ScriptChangedEvent());
      l.info("[SCRIPTS CONTROLLER] Script changed: ${value?.name}");
    } catch (exception, stacktrace) {
      l.shout(
        "[SCRIPTS CONTROLLER] Setting selected script error",
        exception,
        stacktrace,
      );
    } finally {
      stopLoading();
    }
  }

  void _getSelectedScript() {
    try {
      _selectedScript = _getSelectedScriptUsecase();
      notifyListeners();
      l.info(
        "[SCRIPTS CONTROLLER] Current selected script: ${_selectedScript?.name}",
      );
    } catch (exception, stacktrace) {
      l.shout(
        "[SCRIPTS CONTROLLER] Getting selected script error",
        exception,
        stacktrace,
      );
    }
  }

  void changeScript(ScriptModel? script) {
    if (script == null) return;
    _setSelectedScript(script);
  }

  @override
  Future<void> init() async {
    super.init();
    _getSelectedScript();
    await _getAvailableScripts();
    _eventManager.on<StartDownloadingEvent>(_resetState);
    _eventManager.on<DownloadedEvent>(_getAvailableScripts);
  }

  Future<void> _getAvailableScripts() async {
    startLoading();
    try {
      scripts = await _getScriptsUsecase();
      l.info("[SCRIPTS CONTROLLER] Available scripts count: ${scripts.length}");
    } catch (exception, stacktrace) {
      l.shout(
        "[SCRIPTS CONTROLLER] Scripts loading error",
        exception,
        stacktrace,
      );
    } finally {
      stopLoading();
    }
  }

  Future<void> _resetState() async {
    try {
      scripts = [];
      _setSelectedScriptUsecase(null);
      _setSelectedScript(null);
    } catch (exception, stacktrace) {
      l.shout('[SCRIPTS CONTROLLER] Reset state error:', exception, stacktrace);
    }
  }
}
