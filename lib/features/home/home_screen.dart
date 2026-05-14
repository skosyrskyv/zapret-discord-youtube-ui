import 'package:flutter/material.dart';
import 'package:zapret_ui/app/runner.dart';
import 'package:zapret_ui/core/extensions/padding_extension.dart';
import 'package:zapret_ui/core/widgets/animated_background.dart';
import 'package:zapret_ui/core/widgets/nothing.dart';
import 'package:zapret_ui/core/widgets/window_draggable_area.dart';
import 'package:zapret_ui/features/home/home_app_bar.dart';
import 'package:zapret_ui/features/installer/presentation/controllers/version_controller.dart';
import 'package:zapret_ui/features/installer/presentation/widgets/download_button.dart';
import 'package:zapret_ui/features/installer/presentation/widgets/version_bar.dart';
import 'package:zapret_ui/features/process/presentation/controllers/process_controller.dart';
import 'package:zapret_ui/features/process/presentation/widgets/Process_switch_button.dart';
import 'package:zapret_ui/features/scripts/presentation/widgets/scripts_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          _Background(),
          WindowDraggableArea(),
          _Content(),
        ],
      ),
    );
  }
}

//
// CONTENT
//
class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => __ContentState();
}

class __ContentState extends State<_Content> {
  final VersionController _controller = getIt.get<VersionController>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProcessSwitchButton(),
          Paddings.h20,
          VersionBar(),
          ScriptsList(),
        ],
      ),
      builder: (_, child) {
        if (!_controller.isInstalled && !_controller.isLoading) {
          return DownloadButton(
            isDownloading: _controller.isDownloading,
            onTap: _controller.downloadZapret,
          );
        }
        return child ?? const Nothing();
      },
    );
  }
}

//
// BACKGROUND
//
class _Background extends StatefulWidget {
  const _Background();

  @override
  State<_Background> createState() => __BackgroundState();
}

class __BackgroundState extends State<_Background> {
  late final ProcessController _state = getIt.get<ProcessController>();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final backgroundColors = [
      colorScheme.surface.withAlpha(0),
      colorScheme.primary.withAlpha(200),
    ];

    return AnimatedBackground(
      colors: backgroundColors,
      horizontalSpeed: 1.8,
      verticalSpeed: .01,
      waveAmplitude: .6,
      numberOfLines: (MediaQuery.of(context).size.width * .10).round(),
      child: ListenableBuilder(
        listenable: _state,
        builder: _blackoutBuilder,
      ),
    );
  }

  Widget _blackoutBuilder(BuildContext context, _) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
      color: Theme.of(context).colorScheme.surface.withAlpha(
        _state.isRunning ? 0 : 180,
      ),
    );
  }
}
