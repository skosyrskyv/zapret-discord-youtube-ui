abstract class WebLinks {
  static const String zapretRepositoryUrl =
      'https://github.com/Flowseal/zapret-discord-youtube/';

  static const String zapretVersionUrl =
      'https://raw.githubusercontent.com/Flowseal/zapret-discord-youtube/main/.service/version.txt';
}

abstract class Constants {
  static const String zapretFolderName = 'zapret';
  static const String serviceFileName = 'zapret_ui_service.bat';
  static const String serviceFilePath = 'bin\\$serviceFileName';
  static const String assetsPath = 'assets';
}

abstract class PrefsKeys {
  static const String selectedScript = 'selected_script';
  static const String installedZapretVersion = 'installed_zapret_version';
  static const String remoteZapretVersion = 'remote_zapret_version';
  static const String lastVersionFetchDateTime = 'last_version_fetch_datetime';
}
