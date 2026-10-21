import 'package:flutter/material.dart';
import 'package:mya/application/bubble/bubble_position.dart';
import 'package:mya/l10n/mya_localizations.dart';

class BubblePositionPicker extends StatelessWidget {
  const BubblePositionPicker({
    super.key,
    required this.displays,
    required this.selectedDisplayId,
    required this.selectedAnchor,
    required this.freeDragEnabled,
    required this.onDisplayChanged,
    required this.onAnchorChanged,
    required this.onFreeDragChanged,
  });

  final List<BubbleDisplay> displays;
  final String? selectedDisplayId;
  final BubbleAnchor? selectedAnchor;
  final bool freeDragEnabled;
  final ValueChanged<String?> onDisplayChanged;
  final ValueChanged<BubbleAnchor> onAnchorChanged;
  final ValueChanged<bool> onFreeDragChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveDisplayId =
        displays.any((display) => display.id == selectedDisplayId)
        ? selectedDisplayId
        : displays.firstOrNull?.id;

    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.bubblePositionTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (displays.length > 1)
          DropdownButtonFormField<String>(
            initialValue: effectiveDisplayId,
            decoration: InputDecoration(
              labelText: l10n.displayLabel,
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final display in displays)
                DropdownMenuItem(
                  value: display.id,
                  child: Text(
                    display.isPrimary
                        ? '${display.name}${l10n.displayPrimarySuffix}'
                        : display.name,
                  ),
                ),
            ],
            onChanged: onDisplayChanged,
          ),
        if (displays.length > 1) const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 168,
            child: Column(
              children: [
                _anchorRow(context, l10n, const [
                  BubbleAnchor.topLeft,
                  BubbleAnchor.topCenter,
                  BubbleAnchor.topRight,
                ]),
                _anchorRow(context, l10n, const [
                  BubbleAnchor.centerLeft,
                  null,
                  BubbleAnchor.centerRight,
                ]),
                _anchorRow(context, l10n, const [
                  BubbleAnchor.bottomLeft,
                  BubbleAnchor.bottomCenter,
                  BubbleAnchor.bottomRight,
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          selectedAnchor != null
              ? l10n.anchorLabel(selectedAnchor!)
              : l10n.bubbleFreePositionHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.bubbleFreeDragTitle),
          subtitle: Text(l10n.bubbleFreeDragSubtitle),
          value: freeDragEnabled,
          onChanged: onFreeDragChanged,
        ),
      ],
    );
  }

  Widget _anchorRow(
    BuildContext context,
    MyaLocalizations l10n,
    List<BubbleAnchor?> anchors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final anchor in anchors)
          SizedBox(
            width: 56,
            height: 48,
            child: anchor == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(3),
                    child: IconButton(
                      tooltip: l10n.anchorLabel(anchor),
                      isSelected: anchor == selectedAnchor,
                      style: IconButton.styleFrom(
                        backgroundColor: anchor == selectedAnchor
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                      ),
                      onPressed: () => onAnchorChanged(anchor),
                      icon: Icon(_iconFor(anchor)),
                    ),
                  ),
          ),
      ],
    );
  }

  IconData _iconFor(BubbleAnchor anchor) {
    return switch (anchor) {
      BubbleAnchor.topLeft => Icons.north_west,
      BubbleAnchor.topCenter => Icons.north,
      BubbleAnchor.topRight => Icons.north_east,
      BubbleAnchor.centerLeft => Icons.west,
      BubbleAnchor.centerRight => Icons.east,
      BubbleAnchor.bottomLeft => Icons.south_west,
      BubbleAnchor.bottomCenter => Icons.south,
      BubbleAnchor.bottomRight => Icons.south_east,
    };
  }
}
