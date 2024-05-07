import 'package:modkeeper/serialization/module_item_raw.dart';
import 'component_view_item.dart';

// the view state for the module cell
class ModuleViewItem {
  // Primary key: (modOrder, name)

  // the order of the module in the list, 0 will be the first to be installed
  final int modOrder;

  // the tp2 file name. allow duplicates
  final String name;

  // the module name which is displayed to user. allow duplicates
  final String moduleName;
  // short description of the module, which will be displayed at the top of ModInfoScreen
  final String? description;
  final List<ComponentViewItem> components;

  ModuleViewItem({
    required this.modOrder,
    required this.name,
    required this.moduleName,
    this.description,
    required this.components,
  });

  factory ModuleViewItem.fromModuleItemRaw(int modOrder, ModuleItemRaw moduleItemRaw) {
    return ModuleViewItem(
      modOrder: modOrder,
      name: moduleItemRaw.name,
      moduleName: moduleItemRaw.moduleName ?? moduleItemRaw.name, // you should provide module name to see if it is supported by EET
      description: moduleItemRaw.description,
      components: moduleItemRaw.components
          .map((componentItemRaw) => ComponentViewItem.fromComponentItemRaw(componentItemRaw))
          .toList(),
    );
  }

  ModuleViewItem selectingAllComponents(bool enabled) {
    final updatedComponents = components.map((component) => component.selecting(enabled)).toList();
    return ModuleViewItem(
      modOrder: modOrder,
      name: name,
      moduleName: moduleName,
      description: description,
      components: updatedComponents,
    );
  }

  ModuleViewItem selectingComponent(ComponentViewItem component, bool enabled) {
    final updatedComponents = components.map((c) => c == component ? c.selecting(enabled) : c).toList();
    return ModuleViewItem(
      modOrder: modOrder,
      name: name,
      moduleName: moduleName,
      description: description,
      components: updatedComponents,
    );
  }
}
