/// Clés partagées Flutter ↔ widget Android (D17a).
abstract final class AndroidHomeWidgetKeys {
  static const iconId = 'mya_icon_id';
  static const syncBadgeVisible = 'mya_sync_badge_visible';
  static const todayAttentionVisible = 'mya_today_attention_visible';
  static const todayHeadline = 'mya_today_headline';

  /// Longueur max stockée pour le widget 2×2 (RemoteViews).
  static const todayHeadlineMaxLength = 80;

  static const providerName = 'MyaHomeWidgetProvider';
  static const qualifiedProviderName = 'com.mya.mya.MyaHomeWidgetProvider';
}

/// Données affichées par le widget 1×1.
class AndroidHomeWidgetSnapshot {
  const AndroidHomeWidgetSnapshot({
    required this.iconId,
    required this.showSyncBadge,
    required this.showTodayAttention,
    required this.todayHeadline,
  });

  final String iconId;
  final bool showSyncBadge;

  /// Pastille ambre : au moins une tâche active en section « aujourd'hui ».
  final bool showTodayAttention;

  /// Première tâche « aujourd'hui » (widget 2×2), vide sinon.
  final String todayHeadline;
}
