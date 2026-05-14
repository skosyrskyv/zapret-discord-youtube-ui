import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowControlsBar extends StatelessWidget {
  const WindowControlsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: windowManager.minimize,
            icon: Icon(Icons.remove),
          ),
          IconButton(
            onPressed: windowManager.close,
            icon: Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
