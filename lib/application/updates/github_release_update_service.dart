import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mya/application/updates/app_release_info.dart';
import 'package:mya/application/updates/app_version.dart';
import 'package:mya/application/updates/update_service.dart';
import 'package:path/path.dart' as p;

/// Interroge GitHub Releases et installe l'installateur Inno Setup MYA.
class GitHubReleaseUpdateService implements UpdateService {
  GitHubReleaseUpdateService({
    required this.owner,
    required this.repo,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String owner;
  final String repo;
  final http.Client _client;

  static final RegExp _installerAssetPattern = RegExp(
    r'^MYA-Setup-.+\.exe$',
    caseSensitive: false,
  );

  Uri get _latestReleaseUri =>
      Uri.https('api.github.com', '/repos/$owner/$repo/releases/latest');

  Map<String, String> get _headers => const {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'MYA-Desktop-Updater',
  };

  @override
  Future<AppReleaseInfo?> checkForUpdate(AppVersion current) async {
    final response = await _client.get(_latestReleaseUri, headers: _headers);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw UpdateCheckException(
        'GitHub Releases indisponible (${response.statusCode}).',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final release = parseReleasePayload(payload);
    if (release == null || !release.version.isNewerThan(current)) {
      return null;
    }
    return release;
  }

  static AppReleaseInfo? parseReleasePayload(Map<String, dynamic> payload) {
    final assets = payload['assets'];
    if (assets is! List || assets.isEmpty) return null;

    Map<String, dynamic>? selectedAsset;
    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      final name = asset['name'] as String?;
      if (name != null && _installerAssetPattern.hasMatch(name)) {
        selectedAsset = asset;
        break;
      }
    }
    if (selectedAsset == null) return null;

    final fileName = selectedAsset['name'] as String;
    final downloadUrl = selectedAsset['browser_download_url'] as String?;
    if (downloadUrl == null || downloadUrl.isEmpty) return null;

    final version =
        AppVersion.fromInstallerAssetName(fileName) ??
        AppVersion.parse(payload['tag_name'] as String? ?? '');
    final publishedAtRaw = payload['published_at'] as String?;

    return AppReleaseInfo(
      version: version,
      downloadUrl: Uri.parse(downloadUrl),
      fileName: fileName,
      releaseNotes: _cleanReleaseNotes(payload['body'] as String?),
      publishedAt: publishedAtRaw == null
          ? null
          : DateTime.tryParse(publishedAtRaw)?.toLocal(),
    );
  }

  @override
  Future<File> downloadInstaller(
    AppReleaseInfo release, {
    void Function(int received, int? total)? onProgress,
  }) async {
    final request = http.Request('GET', release.downloadUrl);
    request.headers.addAll(_headers);
    final streamed = await _client.send(request);
    if (streamed.statusCode != 200) {
      throw UpdateDownloadException(
        'Téléchargement impossible (${streamed.statusCode}).',
      );
    }

    final total = streamed.contentLength;
    final directory = await Directory.systemTemp.createTemp('mya-update-');
    final destination = File(p.join(directory.path, release.fileName));
    final sink = destination.openWrite();
    var received = 0;

    try {
      await for (final chunk in streamed.stream) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, total != null && total > 0 ? total : null);
      }
    } catch (error) {
      await destination.delete().catchError((_) => destination);
      rethrow;
    } finally {
      await sink.close();
    }

    return destination;
  }

  @override
  Future<void> launchInstaller(File installer) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('Installation réservée à Windows.');
    }

    await Process.start(installer.path, const [
      '/CLOSEAPPLICATIONS',
      '/RESTARTAPPLICATIONS',
    ], runInShell: true);
    exit(0);
  }

  static String? _cleanReleaseNotes(String? body) {
    if (body == null) return null;
    final trimmed = body.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class UpdateCheckException implements Exception {
  UpdateCheckException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UpdateDownloadException implements Exception {
  UpdateDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
