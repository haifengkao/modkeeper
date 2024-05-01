import 'package:flutter/material.dart';
import 'package:modkeeper/main.dart';

import 'module_item.dart';

class ModuleSelectionScreen extends StatefulWidget {
  final List<ModuleItem> modules;

  const ModuleSelectionScreen({super.key, required this.modules});

  @override
  ModuleSelectionScreenState createState() => ModuleSelectionScreenState();
}

class ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  List<ModuleItem> get selectedModules => widget.modules
      .where((module) =>
          module.components.any((component) => component.isSelected))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable List'),
      ),
      body: ListView.builder(
        itemCount: widget.modules.length,
        itemBuilder: (context, index) {
          final module = widget.modules[index];
          return ExpandableListItem(module: module);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          copyToBeInstalledYaml(selectedModules);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

class ExpandableListItem extends StatefulWidget {
  final ModuleItem module;

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
    return Column(
      children: [
        ListTile(
          leading: Checkbox(
            value: isAllSelected(),
            onChanged: (value) {
              setState(() {
                for (var component in widget.module.components) {
                  component.isSelected = value!;
                }

                if (!isExpanded) {
                  _toggleExpansion();
                }
              });
            },
          ),
          title: Text(widget.module.name),
          onTap: () {
            setState(() {
              _toggleExpansion();
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
                return CheckboxListTile(
                  dense: true,
                  title: Text(component.componentName ?? ''),
                  value: component.isSelected,
                  onChanged: (value) {
                    setState(() {
                      component.isSelected = value!;
                      // Update the parent checkbox state based on the children's state
                      if (isAllSelected() && !isExpanded) {
                        _toggleExpansion();
                      }

                      if (isAllUnselected() && !isExpanded) {
                        _toggleExpansion();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
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
