import 'package:flutter/material.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';

/// Galerie d'icônes de pastille — réutilisée en paramètres et au premier lancement.
class BubbleIconGallery extends StatelessWidget {
  const BubbleIconGallery({
    super.key,
    required this.selectedIconId,
    required this.onSelected,
    this.previewSize = 56,
  });

  final String selectedIconId;
  final ValueChanged<String> onSelected;
  final double previewSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final option in BubbleIconCatalog.options)
          _IconChoiceTile(
            option: option,
            selected: option.id == selectedIconId,
            previewSize: previewSize,
            onTap: () => onSelected(option.id),
            theme: theme,
          ),
      ],
    );
  }
}

class _IconChoiceTile extends StatelessWidget {
  const _IconChoiceTile({
    required this.option,
    required this.selected,
    required this.previewSize,
    required this.onTap,
    required this.theme,
  });

  final BubbleIconOption option;
  final bool selected;
  final double previewSize;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? theme.colorScheme.primary : Colors.white24;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: previewSize + 24,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.white10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                option.assetPath,
                width: previewSize,
                height: previewSize,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              option.label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
