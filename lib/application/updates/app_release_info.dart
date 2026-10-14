import 'package:mya/application/updates/app_version.dart';

/// Métadonnées d'une release GitHub prête à installer.
class AppReleaseInfo {
  const AppReleaseInfo({
    required this.version,
    required this.downloadUrl,
    required this.fileName,
    this.releaseNotes,
    this.publishedAt,
  });

  final AppVersion version;
  final Uri downloadUrl;
  final String fileName;
  final String? releaseNotes;
  final DateTime? publishedAt;

  String get versionKey => version.versionKey;
}
