import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowDraggableArea extends StatelessWidget {
  const WindowDraggableArea({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) async {
        try {
          await windowManager.startDragging();
        } catch (e) {
          log(e.toString());
        }
      },
      child: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.transparent,
      ),
    );
  }
}
