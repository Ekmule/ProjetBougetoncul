import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Paramètres locaux de la pastille Windows (non synchronisés).
class BubbleDeviceSettings extends Equatable {
  const BubbleDeviceSettings({
    this.position,
    this.bubbleVisible = true,
    this.alwaysOnTop = true,
    this.startupEnabled = false,
  });

  final Offset? position;
  final bool bubbleVisible;
  final bool alwaysOnTop;
  final bool startupEnabled;

  BubbleDeviceSettings copyWith({
    Offset? position,
    bool clearPosition = false,
    bool? bubbleVisible,
    bool? alwaysOnTop,
    bool? startupEnabled,
  }) {
    return BubbleDeviceSettings(
      position: clearPosition ? null : position ?? this.position,
      bubbleVisible: bubbleVisible ?? this.bubbleVisible,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      startupEnabled: startupEnabled ?? this.startupEnabled,
    );
  }

  @override
  List<Object?> get props => [
        position,
        bubbleVisible,
        alwaysOnTop,
        startupEnabled,
      ];
}
