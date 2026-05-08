import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zapret_ui/widgets/fade_in_animation.dart';

class ScriptsList extends StatelessWidget {
  final String? selected;
  final void Function(String? value)? onChange;
  final List<String> items;
  ScriptsList({
    super.key,
    required this.items,
    this.selected,
    required this.onChange,
  });

  final controller = ExpansibleController();

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return RadioGroup<String?>(
      groupValue: selected,
      onChanged: onChange ?? (_) {},
      child: Center(
        child: FadeInAnimation(
          playWhenRebuilds: false,
          child: Container(
            padding: EdgeInsets.only(bottom: 20),
            constraints: BoxConstraints(maxWidth: 400),
            child: Expansible(
              controller: controller,
              headerBuilder: _buildHeader,
              bodyBuilder: _buildBody,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Animation<double> animation) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            controller.isExpanded ? controller.collapse() : controller.expand(),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.replaceAll('.bat', '').toUpperCase() ??
                      'Выберете скрипт',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (items.isNotEmpty)
                Transform.rotate(
                  angle:
                      lerpDouble((-pi / 2), (pi / 2), animation.value) ??
                      (-pi / 2),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Animation<double> animation) {
    return Container(
      height: 400,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 20),
        children: items
            .map(
              (item) => _Item(
                value: item,
                label: item.replaceAll('.bat', ''),
              ),
            )
            .toList(),
      ),
    );
  }
}

//
// LIST ITEM
//
class _Item extends StatelessWidget {
  final String value;
  final String label;
  const _Item({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          RadioGroup.maybeOf<String?>(context)?.onChanged(value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.replaceFirst('g', 'G'),
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        RadioGroup.maybeOf<String?>(context)?.groupValue ==
                            value
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.blueGrey,
                    fontWeight:
                        RadioGroup.maybeOf<String?>(context)?.groupValue ==
                            value
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (RadioGroup.maybeOf<String?>(context)?.groupValue == value)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
