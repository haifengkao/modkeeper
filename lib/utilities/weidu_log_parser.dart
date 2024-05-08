
class WeiduComponentItem {
  final String tp2File;
  final int componentNumber;
  final String componentName;
  final int languageNumber;
  WeiduComponentItem(
      {required this.tp2File,
        required this.componentNumber,
        required this.componentName,
        required this.languageNumber});
}

// Weidu.log example
// // Log of Currently Installed WeiDU Mods
// // The top of the file is the 'oldest' mod
// // ~TP2_File~ #language_number #component_number // [Subcomponent Name -> ] Component Name [ : Version]
// ~./EEFIXPACK/SETUP-EEFIXPACK.TP2~ #0 #0 // Core Fixes: Beta 1
// ~EEFIXPACK/SETUP-EEFIXPACK.TP2~ #0 #2 // Game Text Update: Beta 1
// ~DLCMERGER/DLCMERGER.TP2~ #0 #1 // Merge DLC into game -> Merge "Siege of Dragonspear" DLC: 1.3
class WeiduLogParser {
  final List<WeiduComponentItem> components;

  WeiduLogParser(this.components);

  static WeiduLogParser fromString(String log) {
    final components = <WeiduComponentItem>[];
    final lines = log.split('\n');

    for (final line in lines) {
      if (line.startsWith('~') && line.contains('~')) {
        final parts = line.split('~');
        if (parts.length >= 3) {
          final tp2File = parts[1].trim();
          final languageAndComponent = parts[2].split('#');
          if (languageAndComponent.length >= 3) {
            final languageNumber = int.parse(languageAndComponent[1].trim());
            final componentParts = languageAndComponent[2].split('//');
            if (componentParts.length >= 2) {
              final componentNumber = int.parse(componentParts[0].trim());
              final componentName = componentParts[1].trim();

              components.add(
                WeiduComponentItem(
                  tp2File: tp2File,
                  componentNumber: componentNumber,
                  componentName: componentName,
                  languageNumber: languageNumber,
                ),
              );
            }
          }
        }
      }
    }

    return WeiduLogParser(components);
  }
}
