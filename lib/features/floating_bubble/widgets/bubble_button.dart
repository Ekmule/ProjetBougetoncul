import 'package:flutter/material.dart';
import 'package:mya/core/constants/window_constants.dart';

/// La pastille MYA — cercle rouge cliquable remplissant la fenêtre.
class BubbleButton extends StatelessWidget {
  const BubbleButton({super.key, required this.alwaysOnTop});

  final bool alwaysOnTop;

  @override
  Widget build(BuildContext context) {
    final tooltip = alwaysOnTop
        ? 'Toujours au-dessus (activé) — double-clic pour désactiver'
        : 'Toujours au-dessus (désactivé) — double-clic pour activer';

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: WindowConstants.bubbleSize,
        height: WindowConstants.bubbleSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: WindowConstants.bubbleColor,
            border: Border.all(
              color: alwaysOnTop ? Colors.amber : Colors.white,
              width: alwaysOnTop ? 3 : 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
