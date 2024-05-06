
class ComponentItem {
  final String? componentName;
  final int index;
  bool isSelected;

  ComponentItem({
    this.componentName,
    required this.index,
    this.isSelected = false,
  });
}
