import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/updates/app_release_info.dart';
import 'package:mya/application/updates/app_version.dart';
import 'package:mya/application/updates/github_release_update_service.dart';
import 'package:mya/application/updates/update_asset_kind.dart';
import 'package:mya/application/updates/update_service.dart';
import 'package:mya/core/configuration/update_config.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  if (!UpdateConfig.isConfigured || kDebugMode) {
    return const NoOpUpdateService();
  }

  final UpdateAssetKind? kind = switch (Platform.operatingSystem) {
    'windows' => UpdateAssetKind.windowsInstaller,
    'android' => UpdateAssetKind.androidApk,
    _ => null,
  };
  if (kind == null) return const NoOpUpdateService();

  return GitHubReleaseUpdateService(
    owner: UpdateConfig.githubOwner,
    repo: UpdateConfig.githubRepo,
    assetKind: kind,
  );
});

class UpdateCheckState {
  const UpdateCheckState({
    this.checking = false,
    this.downloading = false,
    this.progress,
    this.currentVersion,
    this.availableRelease,
    this.errorMessage,
    this.infoMessage,
  });

  final bool checking;
  final bool downloading;
  final double? progress;
  final AppVersion? currentVersion;
  final AppReleaseInfo? availableRelease;
  final String? errorMessage;
  final String? infoMessage;

  bool get hasUpdate => availableRelease != null;

  UpdateCheckState copyWith({
    bool? checking,
    bool? downloading,
    double? progress,
    AppVersion? currentVersion,
    AppReleaseInfo? availableRelease,
    bool clearAvailableRelease = false,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return UpdateCheckState(
      checking: checking ?? this.checking,
      downloading: downloading ?? this.downloading,
      progress: progress ?? this.progress,
      currentVersion: currentVersion ?? this.currentVersion,
      availableRelease: clearAvailableRelease
          ? null
          : availableRelease ?? this.availableRelease,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
    );
  }
}

class UpdateCheckNotifier extends Notifier<UpdateCheckState> {
  @override
  UpdateCheckState build() => const UpdateCheckState();

  Future<void> checkForUpdates({required bool userInitiated}) async {
    if (state.checking || state.downloading) return;

    state = state.copyWith(
      checking: true,
      clearError: true,
      clearInfo: true,
      clearAvailableRelease: true,
    );

    try {
      final packageInfo = await ref.read(packageInfoProvider.future);
      final current = AppVersion.fromPackageInfo(packageInfo);
      final release = await ref
          .read(updateServiceProvider)
          .checkForUpdate(current);

      if (userInitiated) {
        await ref.read(deviceSettingsStoreProvider).markUpdateCheckPerformed();
      }

      if (release == null) {
        state = state.copyWith(
          checking: false,
          currentVersion: current,
          infoMessage: userInitiated
              ? 'MYA est déjà à jour (${current.displayName}).'
              : null,
        );
        return;
      }

      if (!userInitiated &&
          ref
              .read(deviceSettingsStoreProvider)
              .isUpdateDismissed(release.versionKey)) {
        state = state.copyWith(checking: false, currentVersion: current);
        return;
      }

      state = state.copyWith(
        checking: false,
        currentVersion: current,
        availableRelease: release,
      );
    } on UpdateCheckException catch (error) {
      state = state.copyWith(checking: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        checking: false,
        errorMessage: 'Impossible de vérifier les mises à jour.',
      );
    }
  }

  Future<void> checkOnStartupIfNeeded() async {
    if (!UpdateConfig.isConfigured || kDebugMode) return;
    final store = ref.read(deviceSettingsStoreProvider);
    if (!store.shouldCheckForUpdates(
      interval: Duration(hours: UpdateConfig.checkIntervalHours),
    )) {
      return;
    }

    await store.markUpdateCheckPerformed();
    await checkForUpdates(userInitiated: false);
  }

  Future<void> dismissAvailableUpdate() async {
    final release = state.availableRelease;
    if (release == null) return;
    await ref
        .read(deviceSettingsStoreProvider)
        .dismissUpdateVersion(release.versionKey);
    state = state.copyWith(clearAvailableRelease: true);
  }

  Future<void> installAvailableUpdate() async {
    final release = state.availableRelease;
    if (release == null || state.downloading) return;

    state = state.copyWith(downloading: true, progress: 0, clearError: true);

    try {
      final service = ref.read(updateServiceProvider);
      final installer = await service.downloadInstaller(
        release,
        onProgress: (received, total) {
          if (total == null || total <= 0) return;
          state = state.copyWith(progress: received / total);
        },
      );
      await service.launchInstaller(installer);
    } on UpdateDownloadException catch (error) {
      state = state.copyWith(downloading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        downloading: false,
        errorMessage: 'Installation impossible.',
      );
    }
  }
}

final updateCheckProvider =
    NotifierProvider<UpdateCheckNotifier, UpdateCheckState>(
      UpdateCheckNotifier.new,
    );

/// Lance une vérification différée au démarrage (Windows / Android).
final updateLifecycleProvider = Provider<void>((ref) {
  final supported = Platform.isWindows || Platform.isAndroid;
  if (!supported || kDebugMode || !UpdateConfig.isConfigured) {
    return;
  }

  Future<void>.delayed(const Duration(seconds: 20), () {
    unawaited(ref.read(updateCheckProvider.notifier).checkOnStartupIfNeeded());
  });
});
