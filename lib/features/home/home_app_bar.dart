import 'package:flutter/material.dart';
import 'package:zapret_ui/core/widgets/window_controls_bar.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) => const WindowControlsBar();

  @override
  Size get preferredSize => Size(double.infinity, 60);
}
