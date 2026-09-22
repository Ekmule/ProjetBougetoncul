import 'package:equatable/equatable.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/core/constants/window_constants.dart';

/// Apparence de la pastille Windows (taille + icône).
class BubbleAppearance extends Equatable {
  const BubbleAppearance({
    this.size = WindowConstants.defaultBubbleSize,
    this.iconId = BubbleIconCatalog.defaultIconId,
  });

  final double size;
  final String iconId;

  String get assetPath => BubbleIconCatalog.assetPathFor(iconId);

  BubbleAppearance copyWith({
    double? size,
    String? iconId,
  }) {
    return BubbleAppearance(
      size: size ?? this.size,
      iconId: iconId ?? this.iconId,
    );
  }

  @override
  List<Object?> get props => [size, iconId];
}
