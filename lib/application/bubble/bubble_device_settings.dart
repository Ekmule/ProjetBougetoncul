import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/core/constants/window_constants.dart';

/// Paramètres locaux de la pastille Windows (non synchronisés).
class BubbleDeviceSettings extends Equatable {
  const BubbleDeviceSettings({
    this.position,
    this.bubbleVisible = true,
    this.alwaysOnTop = true,
    this.startupEnabled = false,
    this.bubbleSize = WindowConstants.defaultBubbleSize,
    this.bubbleIconId = BubbleIconCatalog.defaultIconId,
  });

  final Offset? position;
  final bool bubbleVisible;
  final bool alwaysOnTop;
  final bool startupEnabled;
  final double bubbleSize;
  final String bubbleIconId;

  BubbleDeviceSettings copyWith({
    Offset? position,
    bool clearPosition = false,
    bool? bubbleVisible,
    bool? alwaysOnTop,
    bool? startupEnabled,
    double? bubbleSize,
    String? bubbleIconId,
  }) {
    return BubbleDeviceSettings(
      position: clearPosition ? null : position ?? this.position,
      bubbleVisible: bubbleVisible ?? this.bubbleVisible,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      startupEnabled: startupEnabled ?? this.startupEnabled,
      bubbleSize: bubbleSize ?? this.bubbleSize,
      bubbleIconId: bubbleIconId ?? this.bubbleIconId,
    );
  }

  @override
  List<Object?> get props => [
        position,
        bubbleVisible,
        alwaysOnTop,
        startupEnabled,
        bubbleSize,
        bubbleIconId,
      ];
}
