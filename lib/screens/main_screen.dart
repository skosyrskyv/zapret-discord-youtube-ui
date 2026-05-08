import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zapret_ui/controllers/main_controller.dart';
import 'package:zapret_ui/widgets/animated_background.dart';
import 'package:zapret_ui/widgets/fade_in_animation.dart';
import 'package:zapret_ui/widgets/scripts_list.dart';
import 'package:zapret_ui/utils/custom_icons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final MainController _controller;

  @override
  void initState() {
    _controller = MainController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(
              colors: [
                Theme.of(context).colorScheme.surfaceContainer.withAlpha(0),
                Theme.of(context).colorScheme.onSurface.withAlpha(126),
              ],
              isInBackground: true,
              horizontalSpeed: 2,
              verticalSpeed: .01,
              waveAmplitude: .5,
              strokeWidth: 1,
              numberOfLines: (MediaQuery.of(context).size.width * .1).round(),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (_) {
                windowManager.startDragging();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (_, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_controller.isZapretInstalled)
                      _SwitchButton(
                        isLoading: _controller.isLoading,
                        isRunning: _controller.isRunning,
                        onTap: _controller.switchZapret,
                      ),
                    if (!_controller.isZapretInstalled)
                      _DownloadButton(
                        isDownloading: _controller.isDownloading,
                        onTap: _controller.downloadZapret,
                      ),
                    if (_controller.isZapretInstalled)
                      SizedBox(
                        height: 20,
                      ),
                    if (_controller.isZapretInstalled)
                      _Version(
                        version: _controller.version,
                        remoteVersion: _controller.remoteVersion,
                        isDownloading: _controller.isDownloading,
                        onDownload: _controller.downloadZapret,
                      ),
                    if (_controller.isZapretInstalled)
                      ScriptsList(
                        items: _controller.scripts,
                        selected: _controller.selectedScript,
                        onChange: _controller.isLoading
                            ? null
                            : _controller.changeScript,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            right: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    windowManager.minimize();
                  },
                  icon: Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: () {
                    windowManager.close();
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// SWITCH BUTTON
//
class _SwitchButton extends StatelessWidget {
  final bool isRunning;
  final bool isLoading;
  final Future<void> Function() onTap;
  const _SwitchButton({
    required this.isRunning,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeInAnimation(
        playWhenRebuilds: false,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 40),
          height: 200,
          width: 200,
          decoration: BoxDecoration(),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                AnimatedContainer(
                  margin: EdgeInsets.all(8),
                  duration: Duration(milliseconds: 400),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 6,
                      color: isRunning
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(10),
                    ),
                  ),
                  child: Icon(
                    CustomIcons.power,
                    color: isRunning
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withAlpha(30),
                    size: 30,
                  ),
                ),
                Positioned.fill(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: onTap,
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: CircularProgressIndicator(
                        color: isRunning
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                        strokeWidth: 6,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// DOWNLOAD BUTTON
//
class _DownloadButton extends StatelessWidget {
  final bool isDownloading;
  final VoidCallback? onTap;
  const _DownloadButton({required this.isDownloading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final animationDuration = Duration(milliseconds: 600);
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(20);
    final backgroundColor = isDownloading
        ? colorScheme.surfaceContainer
        : colorScheme.primary;
    final foregroundColor = isDownloading
        ? colorScheme.onSurface
        : colorScheme.onPrimary;

    return Center(
      child: AnimatedContainer(
        height: 50,
        width: isDownloading ? 50 : 300,
        duration: animationDuration,
        curve: Curves.easeInOutExpo,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: backgroundColor,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isDownloading ? null : onTap,
            borderRadius: borderRadius,
            child: AnimatedCrossFade(
              duration: animationDuration,
              reverseDuration: animationDuration,
              firstCurve: Curves.easeOutExpo,
              secondCurve: Curves.easeInExpo,
              layoutBuilder: layoutBuilder,
              crossFadeState: isDownloading
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Center(
                child: Text(
                  'Установить',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 20,
                    height: -.2,
                    letterSpacing: .2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              secondChild: Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    color: foregroundColor,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget layoutBuilder(
    Widget topChild,
    Key topChildKey,
    Widget bottomChild,
    Key bottomChildKey,
  ) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        bottomChild,
        topChild,
      ],
    );
  }
}

//
// VERSION BAR
//
class _Version extends StatelessWidget {
  final String? version;
  final String? remoteVersion;
  final bool isDownloading;
  final VoidCallback onDownload;
  const _Version({
    required this.version,
    required this.remoteVersion,
    required this.isDownloading,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final hasNewVersion =
        version != null && remoteVersion != null && version != remoteVersion;

    if (version == null) return SizedBox.shrink();
    return Center(
      child: FadeInAnimation(
        playWhenRebuilds: false,
        child: Container(
          width: 400,
          padding: EdgeInsets.only(left: 16, bottom: 8, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Версия: $version',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              if (hasNewVersion)
                Material(
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
                        if (remoteVersion != null) ...[
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            remoteVersion ?? '',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                        ],
                        InkWell(
                          onTap: isDownloading ? null : onDownload,
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
            ],
          ),
        ),
      ),
    );
  }
}
