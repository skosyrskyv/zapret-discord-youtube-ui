import 'package:injectable/injectable.dart';
import 'package:zapret_ui/features/installer/data/installer_repository.dart';

@injectable
class GetLocalVersionUsecase {
  GetLocalVersionUsecase({required this.repository});
  final InstallerRepository repository;

  Future<String?> call() async {
    return await repository.getLocalVersion();
  }
}
