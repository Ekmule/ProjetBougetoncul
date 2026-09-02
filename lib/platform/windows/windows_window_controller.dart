import 'package:flutter/material.dart';
import 'package:mya/core/constants/window_constants.dart';
import 'package:mya/features/floating_bubble/bubble_debug.dart';
import 'package:mya/platform/window_service.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

/// Contrôle la fenêtre native Windows (taille, position, Always-on-Top).
///
/// Tout appel à window_manager passe par cette classe — jamais depuis un widget.
class WindowsWindowController implements WindowService {
  WindowsWindowController();

  Offset? _lastPosition;
  var _alwaysOnTop = true;
  Size _lastSize = const Size(
    WindowConstants.bubbleSize,
    WindowConstants.bubbleSize,
  );

  /// Initialise la pastille : fenêtre petite, opaque, sans bordure.
  @override
  Future<void> initializeBubbleWindow({
    Offset? initialPosition,
    bool alwaysOnTop = true,
  }) async {
    await windowManager.ensureInitialized();

    _alwaysOnTop = alwaysOnTop;
    final position = initialPosition ?? await _defaultBubblePosition();
    _lastPosition = position;
    _lastSize = const Size(
      WindowConstants.bubbleSize,
      WindowConstants.bubbleSize,
    );

    const windowOptions = WindowOptions(
      size: Size(WindowConstants.bubbleSize, WindowConstants.bubbleSize),
      minimumSize: Size(WindowConstants.bubbleSize, WindowConstants.bubbleSize),
      center: false,
      backgroundColor: WindowConstants.bubbleColor,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(true);
      await windowManager.setBackgroundColor(WindowConstants.bubbleColor);
      await windowManager.setSize(_lastSize);
      await windowManager.setPosition(position);
      await windowManager.setAlwaysOnTop(alwaysOnTop);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// Adapte la taille de la fenêtre au mode d'affichage (pastille / aperçu / panneau).
  @override
  Future<void> applyViewMode({
    required bool isBubble,
    required bool isPreview,
    required bool isPanel,
  }) async {
    final Size targetSize;
    if (isPanel) {
      targetSize = const Size(
        WindowConstants.panelWidth,
        WindowConstants.panelHeight,
      );
    } else if (isPreview) {
      targetSize = const Size(
        WindowConstants.previewWidth,
        WindowConstants.previewHeight,
      );
    } else {
      targetSize = const Size(
        WindowConstants.bubbleSize,
        WindowConstants.bubbleSize,
      );
    }

    final currentPosition = _lastPosition ?? await windowManager.getPosition();
    final adjustedPosition = _adjustPositionForResize(
      currentPosition,
      _lastSize,
      targetSize,
    );

    if (isBubble) {
      await windowManager.setBackgroundColor(WindowConstants.bubbleColor);
    } else {
      await windowManager.setBackgroundColor(const Color(0xFF1E1E1E));
    }

    // Pour réduire, abaisser d'abord la contrainte minimale. Sinon Windows
    // refuse setSize(64x64) et conserve la grande fenêtre du panneau.
    if (isBubble) {
      await windowManager.setMinimumSize(targetSize);
      await windowManager.setSize(targetSize);
    } else {
      await windowManager.setMinimumSize(
        Size(targetSize.width, WindowConstants.previewHeight),
      );
      await windowManager.setSize(targetSize);
    }
    await windowManager.setPosition(adjustedPosition);
    _lastPosition = adjustedPosition;
    _lastSize = targetSize;
    await _ensureAlwaysOnTop();

    BubbleDebug.log('applyViewMode', {
      'bubble': isBubble,
      'preview': isPreview,
      'panel': isPanel,
      'size': '${targetSize.width.toInt()}x${targetSize.height.toInt()}',
      'pos': '${adjustedPosition.dx.toInt()},${adjustedPosition.dy.toInt()}',
    });
  }

  /// Active ou désactive le mode « toujours au-dessus ».
  @override
  Future<void> setAlwaysOnTop(bool enabled) async {
    _alwaysOnTop = enabled;
    await windowManager.setAlwaysOnTop(enabled);
  }

  /// Réapplique Always-on-Top après resize/show (workaround window_manager).
  Future<void> _ensureAlwaysOnTop() async {
    await windowManager.setAlwaysOnTop(_alwaysOnTop);
  }

  /// Déplace la fenêtre (appelé pendant le glisser-déposer de la pastille).
  @override
  Future<void> moveBy(Offset delta) async {
    final position = await windowManager.getPosition();
    final newPosition = position + delta;
    await windowManager.setPosition(newPosition);
    _lastPosition = newPosition;
  }

  /// Accroche la pastille au bord gauche ou droit si elle est assez proche.
  @override
  Future<void> snapToEdgeIfNeeded() async {
    final display = await screenRetriever.getPrimaryDisplay();
    final visibleSize = display.visibleSize ?? display.size;
    final position = await windowManager.getPosition();
    final size = await windowManager.getSize();

    var newX = position.dx;

    if (position.dx < WindowConstants.snapThreshold) {
      newX = WindowConstants.screenMargin;
    } else if (position.dx + size.width >
        visibleSize.width - WindowConstants.snapThreshold) {
      newX = visibleSize.width - size.width - WindowConstants.screenMargin;
    }

    final newPosition = Offset(newX, position.dy);
    await windowManager.setPosition(newPosition);
    _lastPosition = newPosition;
  }

  /// Masque complètement la fenêtre.
  @override
  Future<void> hide() async {
    await windowManager.hide();
  }

  /// Réaffiche la fenêtre.
  @override
  Future<void> show() async {
    await windowManager.show();
    await _ensureAlwaysOnTop();
    await windowManager.focus();
  }

  @override
  Future<Offset> getPosition() async {
    final position = await windowManager.getPosition();
    _lastPosition = position;
    return position;
  }

  @override
  Future<void> setPosition(Offset position) async {
    await windowManager.setPosition(position);
    _lastPosition = position;
  }

  Future<Offset> _defaultBubblePosition() async {
    final display = await screenRetriever.getPrimaryDisplay();
    final visibleSize = display.visibleSize ?? display.size;
    final scale = display.scaleFactor ?? 1.0;

    // Position physique en pixels (tenir compte du scale DPI).
    final bubblePx = WindowConstants.bubbleSize * scale;
    final marginPx = WindowConstants.screenMargin * scale;

    final x = visibleSize.width - bubblePx - marginPx;
    final y = visibleSize.height * 0.8 - bubblePx / 2;

    return Offset(
      x / scale,
      (y / scale).clamp(
        WindowConstants.screenMargin,
        visibleSize.height / scale,
      ),
    );
  }

  Offset _adjustPositionForResize(Offset current, Size fromSize, Size toSize) {
    // Ancre le coin bas-droit : la pastille reste sous le curseur au survol.
    return Offset(
      current.dx + fromSize.width - toSize.width,
      current.dy + fromSize.height - toSize.height,
    );
  }
}
