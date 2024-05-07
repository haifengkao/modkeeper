import 'package:flutter/foundation.dart';
import 'package:modkeeper/data/component_view_item.dart';
import 'package:modkeeper/data/module_view_item.dart';
import 'package:modkeeper/data/mod_db.dart';

class ModDBNotifier extends ChangeNotifier {
  final ModDB _modDB;

  ModDBNotifier(this._modDB);

  ModDB get modDB => _modDB;

  void selectWholeModule(ModuleViewItem module, bool enabled) {
    _modDB.selectWholeModule(module, enabled);
    notifyListeners();
  }

  void selectComponent(ModuleViewItem module, ComponentViewItem component, bool enabled) {
    _modDB.selectComponent(module, component, enabled);
    notifyListeners();
  }
}