import 'package:flutter/material.dart';
import 'package:zapret_ui/app/runner.dart';
import 'package:zapret_ui/core/extensions/padding_extension.dart';
import 'package:zapret_ui/core/utils/custom_icons.dart';
import 'package:zapret_ui/core/widgets/fade_in_animation.dart';
import 'package:zapret_ui/features/installer/presentation/controllers/version_controller.dart';

class VersionBar extends StatefulWidget {
  const VersionBar({super.key});

  @override
  State<VersionBar> createState() => _VersionBarState();
}

class _VersionBarState extends State<VersionBar> {
  final VersionController _state = getIt.get<VersionController>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final hasNewVersion =
            _state.version != null &&
            _state.remoteVersion != null &&
            _state.version != _state.remoteVersion;
        return Container(
          width: 400,
          padding: const EdgeInsets.only(left: 16, bottom: 8, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Версия: ${_state.version}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              _NewVersionCard(
                newVersion: _state.remoteVersion,
                hasNewVersion: hasNewVersion,
                isDownloading: _state.isDownloading,
                onDownloadTap: _state.downloadZapret,
              ),
            ],
          ),
        );
      },
    );
  }
}

//
// NEW VERSION CARD
//
class _NewVersionCard extends StatelessWidget {
  final String? newVersion;
  final bool hasNewVersion;
  final bool isDownloading;
  final VoidCallback onDownloadTap;
  const _NewVersionCard({
    required this.newVersion,
    required this.hasNewVersion,
    required this.onDownloadTap,
    required this.isDownloading,
  });

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      show: hasNewVersion,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.only(
            left: 4,
            right: 4,
            top: 4,
            bottom: 4,
          ),
          child: Row(
            children: [
              if (newVersion != null) ...[
                Paddings.w8,
                Text(
                  newVersion ?? '',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Paddings.w12,
              ],
              InkWell(
                onTap: isDownloading ? null : onDownloadTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 50,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isDownloading
                      ? Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              padding: EdgeInsets.all(3),
                            ),
                          ),
                        )
                      : Icon(
                          CustomIcons.download,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary,
                          size: 15,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
