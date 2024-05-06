
import 'dart:collection';

import 'component_item.dart';
import 'location_item.dart';

// the view state for the module cell
class ModuleItem {
  // Primary key: (modOrder, name)

  // the order of the module in the list, 0 will be the first to be installed
  final int modOrder;

  // the tp2 file name. allow duplicates
  final String name;

  // the module name which is displayed to user. allow duplicates
  final String? moduleName;
  // short description of the module, which will be displayed at the top of ModInfoScreen
  final String? description;
  final List<ComponentItem> components;
  final LocationItem? location;

  ModuleItem({
    required this.modOrder,
    required this.name,
    this.moduleName,
    this.description,
    required this.components,
    this.location,
  });
}
