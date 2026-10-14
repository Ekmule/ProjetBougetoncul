import 'dart:io';

import 'package:mya/application/updates/app_release_info.dart';
import 'package:mya/application/updates/app_version.dart';

/// Vérification et installation des mises à jour MYA.
abstract class UpdateService {
  Future<AppReleaseInfo?> checkForUpdate(AppVersion current);

  Future<File> downloadInstaller(
    AppReleaseInfo release, {
    void Function(int received, int? total)? onProgress,
  });

  Future<void> launchInstaller(File installer);
}

class NoOpUpdateService implements UpdateService {
  const NoOpUpdateService();

  @override
  Future<AppReleaseInfo?> checkForUpdate(AppVersion current) async => null;

  @override
  Future<File> downloadInstaller(
    AppReleaseInfo release, {
    void Function(int received, int? total)? onProgress,
  }) {
    throw UnsupportedError('Mises à jour indisponibles sur cette plateforme.');
  }

  @override
  Future<void> launchInstaller(File installer) async {}
}
