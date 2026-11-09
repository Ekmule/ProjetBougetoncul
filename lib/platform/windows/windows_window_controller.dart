import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mya/application/bubble/bubble_position.dart';
import 'package:mya/core/constants/window_constants.dart';
import 'package:mya/features/floating_bubble/bubble_debug.dart';
import 'package:mya/platform/window_service.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

/// Contrôle la fenêtre native Windows (taille, position, Always-on-Top).
///
/// Tout appel à window_manager passe par cette classe — jamais depuis un widget.
class WindowsWindowController implements WindowService, ScreenListener {
  WindowsWindowController({
    double bubbleSize = WindowConstants.defaultBubbleSize,
  }) : _bubbleSize = bubbleSize,
       _lastSize = Size(bubbleSize, bubbleSize);

  Offset? _lastPosition;
  var _alwaysOnTop = true;
  double _bubbleSize;
  Size _lastSize;
  var _lastWasBubble = true;
  BubbleAnchor? _preferredAnchor;
  String? _preferredDisplayId;
  Offset? _freeMovePointerOffset;

  /// Initialise la pastille : fenêtre petite, opaque, sans bordure.
  @override
  Future<void> initializeBubbleWindow({
    Offset? initialPosition,
    BubbleAnchor? initialAnchor,
    String? initialDisplayId,
    bool alwaysOnTop = true,
  }) async {
    await windowManager.ensureInitialized();

    _alwaysOnTop = alwaysOnTop;
    _preferredAnchor = initialAnchor;
    _preferredDisplayId = initialDisplayId;
    final position = await _resolveInitialPosition(initialPosition);
    _lastPosition = position;
    _lastSize = Size(_bubbleSize, _bubbleSize);

    final windowOptions = WindowOptions(
      size: _lastSize,
      minimumSize: _lastSize,
      center: false,
      backgroundColor: WindowConstants.bubbleHitTestColor,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(false);
      await windowManager.setBackgroundColor(
        WindowConstants.bubbleHitTestColor,
      );
      await windowManager.setSize(_lastSize);
      await windowManager.setPosition(position);
      await windowManager.setAlwaysOnTop(alwaysOnTop);
      await windowManager.show();
      await windowManager.focus();
    });
    screenRetriever.addListener(this);
  }

  /// Adapte la taille de la fenêtre au mode d'affichage (pastille / aperçu / panneau).
  @override
  Future<void> applyViewMode({
    required bool isBubble,
    required bool isPreview,
    required bool isPanel,
  }) async {
    _lastWasBubble = isBubble;
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
      targetSize = Size(_bubbleSize, _bubbleSize);
    }

    final currentPosition = _lastPosition ?? await windowManager.getPosition();
    final adjustedPosition = _adjustPositionForResize(
      currentPosition,
      _lastSize,
      targetSize,
    );

    if (isBubble) {
      await windowManager.setHasShadow(false);
      await windowManager.setBackgroundColor(
        WindowConstants.bubbleHitTestColor,
      );
    } else {
      await windowManager.setHasShadow(true);
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

  @override
  Future<void> applyBubbleSize(double size) async {
    _bubbleSize = size.clamp(
      WindowConstants.minBubbleSize,
      WindowConstants.maxBubbleSize,
    );

    final currentSize = await windowManager.getSize();
    final bubbleSize = Size(_bubbleSize, _bubbleSize);
    if (currentSize == bubbleSize) return;

    final currentPosition = _lastPosition ?? await windowManager.getPosition();
    final adjustedPosition = _adjustPositionForResize(
      currentPosition,
      _lastSize,
      bubbleSize,
    );

    await windowManager.setHasShadow(false);
    await windowManager.setMinimumSize(bubbleSize);
    await windowManager.setSize(bubbleSize);
    await windowManager.setPosition(adjustedPosition);
    _lastPosition = adjustedPosition;
    _lastSize = bubbleSize;
    await _ensureAlwaysOnTop();

    BubbleDebug.log('applyBubbleSize', {
      'size': '${_bubbleSize.toInt()}x${_bubbleSize.toInt()}',
    });
  }

  @override
  Future<WindowLayoutSnapshot> enterSuperAlertLayout(
    double screenFraction,
  ) async {
    final currentSize = await windowManager.getSize();
    final currentPosition = await windowManager.getPosition();
    final snapshot = WindowLayoutSnapshot(
      size: currentSize,
      position: currentPosition,
      wasBubble: _lastWasBubble,
    );

    final displays = await getDisplays();
    final currentCenter =
        currentPosition + Offset(currentSize.width / 2, currentSize.height / 2);
    final display = BubblePositioning.nearestDisplay(currentCenter, displays);
    final fraction = screenFraction.clamp(0.5, 1.0);
    final targetSize = Size(
      display.workArea.width * fraction,
      display.workArea.height * fraction,
    );
    final targetPosition = Offset(
      display.workArea.left + (display.workArea.width - targetSize.width) / 2,
      display.workArea.top + (display.workArea.height - targetSize.height) / 2,
    );

    await windowManager.setHasShadow(fraction < 1);
    await windowManager.setBackgroundColor(const Color(0xFF1E1E1E));
    await windowManager.setMinimumSize(const Size(1, 1));
    await windowManager.setSize(targetSize);
    await windowManager.setPosition(targetPosition);
    _lastSize = targetSize;
    _lastPosition = targetPosition;
    _lastWasBubble = false;
    await _ensureAlwaysOnTop();
    await windowManager.focus();
    return snapshot;
  }

  @override
  Future<void> restoreLayout(WindowLayoutSnapshot snapshot) async {
    await windowManager.setMinimumSize(const Size(1, 1));
    await windowManager.setSize(snapshot.size);
    await windowManager.setPosition(snapshot.position);
    await windowManager.setHasShadow(!snapshot.wasBubble);
    await windowManager.setBackgroundColor(
      snapshot.wasBubble
          ? WindowConstants.bubbleHitTestColor
          : const Color(0xFF1E1E1E),
    );
    await windowManager.setMinimumSize(
      snapshot.wasBubble
          ? snapshot.size
          : Size(snapshot.size.width, WindowConstants.previewHeight),
    );
    _lastSize = snapshot.size;
    _lastPosition = snapshot.position;
    _lastWasBubble = snapshot.wasBubble;
    await _ensureAlwaysOnTop();
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

  @override
  Future<List<BubbleDisplay>> getDisplays() async {
    final nativeDisplays = await screenRetriever.getAllDisplays();
    final primary = await screenRetriever.getPrimaryDisplay();

    return [
      for (var index = 0; index < nativeDisplays.length; index++)
        _toBubbleDisplay(
          nativeDisplays[index],
          index: index,
          primaryId: primary.id,
        ),
    ];
  }

  @override
  Future<Offset> moveToAnchor(BubbleAnchor anchor, {String? displayId}) async {
    final displays = await getDisplays();
    final display = _displayById(displays, displayId);
    final size = await windowManager.getSize();
    final position = BubblePositioning.anchoredPosition(
      workArea: display.workArea,
      windowSize: size,
      anchor: anchor,
      margin: WindowConstants.screenMargin,
    );

    _preferredAnchor = anchor;
    _preferredDisplayId = display.id;
    await windowManager.setPosition(position);
    _lastPosition = position;
    return position;
  }

  @override
  Future<void> beginFreeMove() async {
    final cursor = await screenRetriever.getCursorScreenPoint();
    final position = await windowManager.getPosition();
    _freeMovePointerOffset = cursor - position;
    _preferredAnchor = null;
    _preferredDisplayId = null;
  }

  @override
  Future<void> updateFreeMove() async {
    final pointerOffset = _freeMovePointerOffset;
    if (pointerOffset == null) return;

    final cursor = await screenRetriever.getCursorScreenPoint();
    final size = await windowManager.getSize();
    final displays = await getDisplays();
    final display = BubblePositioning.nearestDisplay(cursor, displays);
    final position = BubblePositioning.clampToWorkArea(
      cursor - pointerOffset,
      windowSize: size,
      workArea: display.workArea,
    );

    await windowManager.setPosition(position);
    _lastPosition = position;
  }

  @override
  Future<Offset> endFreeMove() async {
    await updateFreeMove();
    _freeMovePointerOffset = null;
    return getPosition();
  }

  /// Masque complètement la fenêtre.
  @override
  Future<void> hide() async {
    await windowManager.hide();
  }

  /// Réaffiche la fenêtre.
  @override
  Future<void> show() async {
    await _restoreSafePosition();
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
    _preferredAnchor = null;
    _preferredDisplayId = null;
  }

  @override
  void onScreenEvent(String eventName) {
    unawaited(_restoreSafePosition());
  }

  Future<Offset> _resolveInitialPosition(Offset? savedPosition) async {
    final displays = await getDisplays();
    final size = Size(_bubbleSize, _bubbleSize);

    if (_preferredAnchor case final anchor?) {
      final display = _displayById(displays, _preferredDisplayId);
      _preferredDisplayId = display.id;
      return BubblePositioning.anchoredPosition(
        workArea: display.workArea,
        windowSize: size,
        anchor: anchor,
        margin: WindowConstants.screenMargin,
      );
    }

    if (savedPosition != null) {
      final center = savedPosition + Offset(size.width / 2, size.height / 2);
      final display = BubblePositioning.nearestDisplay(center, displays);
      return BubblePositioning.clampToWorkArea(
        savedPosition,
        windowSize: size,
        workArea: display.workArea,
      );
    }

    final primary = _displayById(displays, null);
    return BubblePositioning.anchoredPosition(
      workArea: primary.workArea,
      windowSize: size,
      anchor: BubbleAnchor.bottomRight,
      margin: WindowConstants.screenMargin,
    );
  }

  Future<void> _restoreSafePosition() async {
    final displays = await getDisplays();
    final size = await windowManager.getSize();

    final Offset position;
    if (_preferredAnchor case final anchor?) {
      final display = _displayById(displays, _preferredDisplayId);
      _preferredDisplayId = display.id;
      position = BubblePositioning.anchoredPosition(
        workArea: display.workArea,
        windowSize: size,
        anchor: anchor,
        margin: WindowConstants.screenMargin,
      );
    } else {
      final current = await windowManager.getPosition();
      final center = current + Offset(size.width / 2, size.height / 2);
      final display = BubblePositioning.nearestDisplay(center, displays);
      position = BubblePositioning.clampToWorkArea(
        current,
        windowSize: size,
        workArea: display.workArea,
      );
    }

    await windowManager.setPosition(position);
    _lastPosition = position;
  }

  BubbleDisplay _displayById(List<BubbleDisplay> displays, String? displayId) {
    if (displayId != null) {
      for (final display in displays) {
        if (display.id == displayId) return display;
      }
    }
    return displays.firstWhere(
      (display) => display.isPrimary,
      orElse: () => displays.first,
    );
  }

  BubbleDisplay _toBubbleDisplay(
    Display display, {
    required int index,
    required String primaryId,
  }) {
    final position = display.visiblePosition ?? Offset.zero;
    final size = display.visibleSize ?? display.size;
    return BubbleDisplay(
      id: display.id,
      name: display.name?.trim().isNotEmpty == true
          ? display.name!.trim()
          : 'Écran ${index + 1}',
      workArea: position & size,
      isPrimary: display.id == primaryId,
    );
  }

  Offset _adjustPositionForResize(Offset current, Size fromSize, Size toSize) {
    final anchor = _preferredAnchor;
    if (anchor == null) {
      // Compatibilité avec les anciennes positions libres.
      return Offset(
        current.dx + fromSize.width - toSize.width,
        current.dy + fromSize.height - toSize.height,
      );
    }

    final dx = switch (anchor.horizontal) {
      -1 => 0.0,
      0 => (fromSize.width - toSize.width) / 2,
      _ => fromSize.width - toSize.width,
    };
    final dy = switch (anchor.vertical) {
      -1 => 0.0,
      0 => (fromSize.height - toSize.height) / 2,
      _ => fromSize.height - toSize.height,
    };
    return Offset(current.dx + dx, current.dy + dy);
  }
}
