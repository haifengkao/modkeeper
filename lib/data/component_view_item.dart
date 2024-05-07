
// to display the component in the list view
import 'package:modkeeper/serialization/component_item_raw.dart';

class ComponentViewItem {
  final String? componentName;
  final int index;
  final bool isSelected;

  ComponentViewItem({
    this.componentName,
    required this.index,
    this.isSelected = false,
  });

  factory ComponentViewItem.fromComponentItemRaw(ComponentItemRaw componentItemRaw) {
    return ComponentViewItem(
      componentName: componentItemRaw.componentName,
      index: componentItemRaw.index,
    );
  }

  ComponentItemRaw toComponentItemRaw() {
    return ComponentItemRaw(
      componentName: componentName,
      index: index,
    );
  }

  selected(bool enabled) {}

  ComponentViewItem selecting(bool enabled) {
    return ComponentViewItem(
      componentName: componentName,
      index: index,
      isSelected: enabled,
    );
  }
}
