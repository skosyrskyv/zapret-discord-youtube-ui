import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:zapret_ui/app/runner.dart';
import 'package:zapret_ui/core/utils/controller.dart';
import 'package:zapret_ui/core/utils/event_manager.dart';
import 'package:zapret_ui/features/installer/usecases/get_local_version_usecase.dart';
import 'package:zapret_ui/features/installer/usecases/get_remote_version_usecase.dart';
import 'package:zapret_ui/features/installer/usecases/install_usecase.dart';

class StartDownloadingEvent extends Event {}

class DownloadedEvent extends Event {}

@singleton
final class VersionController extends StateController {
  VersionController({
    required GetLocalVersionUsecase getLocalVersionUsecase,
    required GetRemoteVersionUsecase getRemoteVersionUsecase,
    required DownloadAndInstallUsecase downloadAndInstallUsecase,
    required EventManager eventManager,
  }) : _getLocalVersionUsecase = getLocalVersionUsecase,
       _getRemoteVersionUsecase = getRemoteVersionUsecase,
       _downloadAndInstallUsecase = downloadAndInstallUsecase,
       _eventManager = eventManager;

  final GetLocalVersionUsecase _getLocalVersionUsecase;
  final GetRemoteVersionUsecase _getRemoteVersionUsecase;
  final DownloadAndInstallUsecase _downloadAndInstallUsecase;
  final EventManager _eventManager;

  bool _isInstalled = false;
  bool get isInstalled => _isInstalled;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  String? _version;
  String? get version => _version;

  String? _remoteVersion;

  String? get remoteVersion => _remoteVersion;

  void _setIsInstalled(bool value) {
    if (value != _isInstalled) {
      _isInstalled = value;
      notifyListeners();
      l.info(
        '[VERSION CONTROLLER] Zapret status: ${_isInstalled ? 'INSTALLED' : 'NOT INSTALLED'}',
      );
    }
  }

  void _setIsDownloading(bool value) {
    if (value != _isDownloading) {
      _isDownloading = value;
      notifyListeners();
      l.info(
        '[VERSION CONTROLLER] Zapret downloading: ${_isDownloading ? 'START' : 'FINISH'}',
      );
    }
  }

  void _setVersion(String? value) async {
    if (value != _version) {
      _version = value;
      notifyListeners();
      l.info('[VERSION CONTROLLER] Zapret version: $_version');
    }
  }

  void _setRemoteVersion(String? value) async {
    if (value != _remoteVersion) {
      _remoteVersion = value;
      notifyListeners();
    }
  }

  Future<void> downloadZapret() async {
    if (_isDownloading) return;

    _setIsDownloading(true);
    try {
      _eventManager.emit(StartDownloadingEvent());
      await _downloadAndInstallUsecase();
      _eventManager.emit(DownloadedEvent());
      _checkZapretInstalled();
    } catch (exception, stacktrace) {
      l.shout(
        '[VERSION CONTROLLER] Zapret downloading error',
        exception,
        stacktrace,
      );
    } finally {
      _setIsDownloading(false);
    }
  }

  @override
  Future<void> init() async {
    super.init();
    await _checkZapretInstalled();
    await _getRemoteVersion();
  }

  Future<void> _getRemoteVersion() async {
    startLoading();
    try {
      final version = await _getRemoteVersionUsecase();
      _setRemoteVersion(version);
    } catch (exception, stacktrace) {
      l.shout(
        '[VERSION CONTROLLER] Get Zapret remote version error',
        exception,
        stacktrace,
      );
    } finally {
      stopLoading();
    }
  }

  Future<void> _checkZapretInstalled() async {
    startLoading();
    try {
      final version = await _getLocalVersionUsecase();
      _setIsInstalled(version != null);
      _setVersion(version);
    } catch (exception, stacktrace) {
      l.shout(
        '[VERSION CONTROLLER] Check Zapret installed error',
        exception,
        stacktrace,
      );
    } finally {
      stopLoading();
    }
  }
}
