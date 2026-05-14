import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zapret_ui/app/runner.dart';
import 'package:zapret_ui/core/extensions/string_extension.dart';
import 'package:zapret_ui/core/widgets/fade_in_animation.dart';
import 'package:zapret_ui/features/scripts/data/models/script_model.dart';
import 'package:zapret_ui/features/scripts/presentation/controllers/scripts_controller.dart';

class ScriptsList extends StatefulWidget {
  const ScriptsList({
    super.key,
  });

  @override
  State<ScriptsList> createState() => _ScriptsListState();
}

class _ScriptsListState extends State<ScriptsList> {
  final _state = getIt.get<ScriptsController>();
  final _expansibleController = ExpansibleController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, child) => RadioGroup<ScriptModel?>(
        groupValue: _state.selectedScript,
        onChanged: _onChange,
        child: Center(
          child: FadeAnimation(
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              constraints: BoxConstraints(maxWidth: 400),
              child: Expansible(
                animationStyle: AnimationStyle(
                  curve: Curves.easeInOutCubic,
                  duration: Duration(milliseconds: 400),
                ),
                controller: _expansibleController,
                headerBuilder: _headerBuilder,
                bodyBuilder: _bodyBuilder,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerBuilder(BuildContext context, Animation<double> animation) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _switchExpanded,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _state.selectedScript?.nameWithoutExtension.capitalize() ??
                      'Выберете стратегию',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_state.scripts.isNotEmpty)
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

  Widget _bodyBuilder(BuildContext context, Animation<double> animation) {
    return FadeAnimation(
      show: animation.value != 1,
      fadeInDuration: Duration(milliseconds: 300),
      fadeOutDuration: Duration(milliseconds: 300),
      child: Container(
        height: 400,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20),
          children: _state.scripts
              .map(
                (item) => _Item(
                  value: item,
                  label: item.nameWithoutExtension,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _switchExpanded() {
    if (_state.scripts.isEmpty) return;
    _expansibleController.isExpanded
        ? _expansibleController.collapse()
        : _expansibleController.expand();
  }

  void _onChange(ScriptModel? value) async {
    _state.changeScript(value);
    _switchExpanded();
  }
}

//
// LIST ITEM
//
class _Item extends StatelessWidget {
  final ScriptModel value;
  final String label;
  const _Item({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          RadioGroup.maybeOf<ScriptModel?>(context)?.onChanged(value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.capitalize(),
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        RadioGroup.maybeOf<ScriptModel?>(context)?.groupValue ==
                            value
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.blueGrey,
                    fontWeight:
                        RadioGroup.maybeOf<ScriptModel?>(context)?.groupValue ==
                            value
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (RadioGroup.maybeOf<ScriptModel?>(context)?.groupValue ==
                  value)
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
