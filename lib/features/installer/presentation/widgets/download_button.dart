import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  final bool isDownloading;
  final VoidCallback? onTap;
  const DownloadButton({
    super.key,
    required this.isDownloading,
    required this.onTap,
  });

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
