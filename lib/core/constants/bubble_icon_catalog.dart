/// Icônes de pastille proposées par MYA (galerie curatée).
class BubbleIconOption {
  const BubbleIconOption({
    required this.id,
    required this.label,
    required this.assetPath,
  });

  final String id;
  final String label;
  final String assetPath;
}

abstract final class BubbleIconCatalog {
  static const defaultIconId = 'icon01';

  static const options = <BubbleIconOption>[
    BubbleIconOption(
      id: 'icon01',
      label: 'Style 1',
      assetPath: 'assets/icons/Icon01.png',
    ),
    BubbleIconOption(
      id: 'icon02',
      label: 'Style 2',
      assetPath: 'assets/icons/Icon02.png',
    ),
    BubbleIconOption(
      id: 'icon03',
      label: 'Style 3',
      assetPath: 'assets/icons/Icon03.png',
    ),
  ];

  static BubbleIconOption resolve(String? id) {
    if (id == null || id.isEmpty) {
      return options.first;
    }
    return options.firstWhere(
      (option) => option.id == id,
      orElse: () => options.first,
    );
  }

  static String assetPathFor(String? id) => resolve(id).assetPath;
}
