import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:mya/core/constants/android_home_widget_keys.dart';
import 'package:mya/core/utils/app_logger.dart';

/// Pousse l'état MYA vers le widget Android (icône + pastille sync).
abstract final class AndroidHomeWidgetBridge {
  static Future<void> register() async {
    if (!Platform.isAndroid) return;
  }

  static Future<bool> isPinSupported() async {
    if (!Platform.isAndroid) return false;
    return await HomeWidget.isRequestPinWidgetSupported() ?? false;
  }

  /// Demande au launcher d'épingler le widget 1×1 (Android 8+).
  static Future<void> requestPin() async {
    if (!Platform.isAndroid) return;
    await HomeWidget.requestPinWidget(
      name: AndroidHomeWidgetKeys.providerName,
      androidName: AndroidHomeWidgetKeys.providerName,
      qualifiedAndroidName: AndroidHomeWidgetKeys.qualifiedProviderName,
    );
  }

  static Future<void> update(AndroidHomeWidgetSnapshot snapshot) async {
    if (!Platform.isAndroid) return;

    try {
      await HomeWidget.saveWidgetData<String>(
        AndroidHomeWidgetKeys.iconId,
        BubbleIconCatalog.resolve(snapshot.iconId).id,
      );
      await HomeWidget.saveWidgetData<bool>(
        AndroidHomeWidgetKeys.syncBadgeVisible,
        snapshot.showSyncBadge,
      );
      await HomeWidget.saveWidgetData<bool>(
        AndroidHomeWidgetKeys.todayAttentionVisible,
        snapshot.showTodayAttention,
      );
      await HomeWidget.saveWidgetData<String>(
        AndroidHomeWidgetKeys.todayHeadline,
        snapshot.todayHeadline,
      );
      await HomeWidget.updateWidget(
        name: AndroidHomeWidgetKeys.providerName,
        androidName: AndroidHomeWidgetKeys.providerName,
        qualifiedAndroidName: AndroidHomeWidgetKeys.qualifiedProviderName,
      );
    } catch (error, stackTrace) {
      appLogger.w(
        'Mise à jour widget Android impossible',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
