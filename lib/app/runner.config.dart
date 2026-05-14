// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../core/utils/event_manager.dart' as _i730;
import '../core/utils/precess_runner.dart' as _i660;
import '../features/installer/data/installer_repository.dart' as _i273;
import '../features/installer/presentation/controllers/version_controller.dart'
    as _i313;
import '../features/installer/usecases/get_local_version_usecase.dart' as _i738;
import '../features/installer/usecases/get_remote_version_usecase.dart'
    as _i715;
import '../features/installer/usecases/install_usecase.dart' as _i400;
import '../features/process/presentation/controllers/process_controller.dart'
    as _i521;
import '../features/process/usecases/start_zapret_usecase.dart' as _i744;
import '../features/process/usecases/stop_zapret_usecase.dart' as _i60;
import '../features/process/usecases/watch_zapret_status_usecase.dart' as _i935;
import '../features/scripts/data/scripts_repository.dart' as _i179;
import '../features/scripts/presentation/controllers/scripts_controller.dart'
    as _i309;
import '../features/scripts/usecases/get_scripts_usecase.dart' as _i180;
import '../features/scripts/usecases/get_selected_script_usecase.dart' as _i403;
import '../features/scripts/usecases/set_selected_script_usecase.dart' as _i991;
import 'runner.dart' as _i257;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final injectableModule = _$InjectableModule();
  await gh.singletonAsync<_i460.SharedPreferences>(
    () => injectableModule.prefs,
    preResolve: true,
  );
  gh.singleton<_i730.EventManager>(() => _i730.EventManager());
  gh.singleton<_i660.ProcessRunner>(() => _i660.ProcessRunner());
  gh.factory<_i179.ScriptsRepository>(
    () => _i179.ScriptsRepository(prefs: gh<_i460.SharedPreferences>()),
  );
  gh.factory<_i273.InstallerRepository>(
    () => _i273.InstallerRepository(
      prefs: gh<_i460.SharedPreferences>(),
      processRunner: gh<_i660.ProcessRunner>(),
    ),
  );
  gh.factory<_i738.GetLocalVersionUsecase>(
    () => _i738.GetLocalVersionUsecase(
      repository: gh<_i273.InstallerRepository>(),
    ),
  );
  gh.factory<_i715.GetRemoteVersionUsecase>(
    () => _i715.GetRemoteVersionUsecase(
      repository: gh<_i273.InstallerRepository>(),
    ),
  );
  gh.factory<_i400.DownloadAndInstallUsecase>(
    () => _i400.DownloadAndInstallUsecase(
      repository: gh<_i273.InstallerRepository>(),
    ),
  );
  gh.factory<_i744.StartZapretUseCase>(
    () => _i744.StartZapretUseCase(
      processRunner: gh<_i660.ProcessRunner>(),
      repository: gh<_i179.ScriptsRepository>(),
    ),
  );
  gh.factory<_i180.GetScriptsUsecase>(
    () => _i180.GetScriptsUsecase(repository: gh<_i179.ScriptsRepository>()),
  );
  gh.factory<_i403.GetSelectedScriptUsecase>(
    () => _i403.GetSelectedScriptUsecase(
      repository: gh<_i179.ScriptsRepository>(),
    ),
  );
  gh.factory<_i991.SetSelectedScriptUsecase>(
    () => _i991.SetSelectedScriptUsecase(
      repository: gh<_i179.ScriptsRepository>(),
    ),
  );
  gh.factory<_i60.StopZapretUseCase>(
    () => _i60.StopZapretUseCase(processRunner: gh<_i660.ProcessRunner>()),
  );
  gh.factory<_i935.WatchZapretUseCase>(
    () => _i935.WatchZapretUseCase(processRunner: gh<_i660.ProcessRunner>()),
  );
  gh.singleton<_i309.ScriptsController>(
    () => _i309.ScriptsController(
      eventManager: gh<_i730.EventManager>(),
      getScriptsUsecase: gh<_i180.GetScriptsUsecase>(),
      setSelectedScriptUsecase: gh<_i991.SetSelectedScriptUsecase>(),
      getSelectedScriptUsecase: gh<_i403.GetSelectedScriptUsecase>(),
    ),
  );
  gh.singleton<_i313.VersionController>(
    () => _i313.VersionController(
      getLocalVersionUsecase: gh<_i738.GetLocalVersionUsecase>(),
      getRemoteVersionUsecase: gh<_i715.GetRemoteVersionUsecase>(),
      downloadAndInstallUsecase: gh<_i400.DownloadAndInstallUsecase>(),
      eventManager: gh<_i730.EventManager>(),
    ),
  );
  gh.singleton<_i521.ProcessController>(
    () => _i521.ProcessController(
      eventManager: gh<_i730.EventManager>(),
      startZapretUseCase: gh<_i744.StartZapretUseCase>(),
      stopZapretUseCase: gh<_i60.StopZapretUseCase>(),
      watchZapretUseCase: gh<_i935.WatchZapretUseCase>(),
    ),
  );
  return getIt;
}

class _$InjectableModule extends _i257.InjectableModule {}
