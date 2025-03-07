import 'package:flutter/material.dart';
import 'package:modkeeper/data/module_view_item.dart';
import 'mod_db_notifier.dart';
import 'package:provider/provider.dart';

class ModuleSelectionScreen extends StatefulWidget {
  const ModuleSelectionScreen({super.key});

  @override
  ModuleSelectionScreenState createState() => ModuleSelectionScreenState();
}

class ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final modDBNotifier = Provider.of<ModDBNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable List'),
      ),
      body: ListView.builder(
        itemCount: modDBNotifier.modDB.moduleViewItems.length,
        itemBuilder: (context, index) {
          final module = modDBNotifier.modDB.moduleViewItems[index];
          return ExpandableListItem(module: module);
        },
      ),
    );
  }
}

class ExpandableListItem extends StatefulWidget {
  final ModuleViewItem module;

  const ExpandableListItem({super.key, required this.module});

  @override
  ExpandableListItemState createState() => ExpandableListItemState();
}

class ExpandableListItemState extends State<ExpandableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final modDBNotifier = Provider.of<ModDBNotifier>(context);

    return Column(
      children: [
        CheckBoxWithText(
          text: widget.module.name,
          isSelected: isAllSelected(),
          onClick: () {
            setState(() {
              _toggleExpansion();
            });
          },
          onCheck: (value) {
            setState(() {
              modDBNotifier.selectWholeModule(widget.module, value!);

              if (!isExpanded) {
                _toggleExpansion();
              }
            });
          },
        ),
        SizeTransition(
          sizeFactor: _animation,
          axisAlignment: 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: widget.module.components.map((component) {
                return CheckBoxWithText(
                  text: component.componentName ?? '',
                  isSelected: component.isSelected,
                  onClick: () {},
                  onCheck: (value) {
                    modDBNotifier.selectComponent(
                      widget.module,
                      component,
                      value!,
                    );

                    setState(() {
                      if (isAllSelected() && !isExpanded) {
                        _toggleExpansion();
                      }

                      if (isAllUnselected() && !isExpanded) {
                        _toggleExpansion();
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  bool isAllSelected() {
    if (widget.module.components.isEmpty) {
      return false;
    }

    return widget.module.components.every((component) => component.isSelected);
  }

  bool isAllUnselected() {
    if (widget.module.components.isEmpty) {
      return false;
    }

    return widget.module.components.every((component) => !component.isSelected);
  }
}

class CheckBoxWithText extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onClick;
  final ValueChanged<bool?> onCheck;

  const CheckBoxWithText({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onClick,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Transform.scale(
                scale: 0.7,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onCheck,
                ),
              );
            },
          ),
          Expanded(
            child: Text(
              text,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}