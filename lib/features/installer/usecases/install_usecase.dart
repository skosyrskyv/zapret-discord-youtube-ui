import 'package:injectable/injectable.dart';
import 'package:zapret_ui/features/installer/data/installer_repository.dart';

@injectable
class DownloadAndInstallUsecase {
  DownloadAndInstallUsecase({required this.repository});
  final InstallerRepository repository;
  Future<void> call() async {
    await repository.downloadAndInstall();
  }
}
