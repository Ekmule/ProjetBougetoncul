import 'dart:convert';

import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:mya/application/updates/app_release_info.dart';

import 'package:mya/application/updates/app_version.dart';

import 'package:mya/application/updates/update_asset_kind.dart';

import 'package:mya/application/updates/update_service.dart';
import 'package:mya/core/configuration/product_config.dart';

import 'package:open_filex/open_filex.dart';

import 'package:path/path.dart' as p;

const windowsSilentInstallerArguments = [
  '/VERYSILENT',
  '/SUPPRESSMSGBOXES',
  '/CLOSEAPPLICATIONS',
  '/RESTARTAPPLICATIONS',
];

/// Interroge GitHub Releases et installe la build MYA (Windows ou Android).

class GitHubReleaseUpdateService implements UpdateService {
  GitHubReleaseUpdateService({
    required this.owner,

    required this.repo,

    required this.assetKind,
    this.releaseTagPrefix,
    this.assetPrefix,

    http.Client? client,
  }) : _client = client ?? http.Client();

  final String owner;

  final String repo;

  final UpdateAssetKind assetKind;
  final String? releaseTagPrefix;
  final String? assetPrefix;

  final http.Client _client;

  static final RegExp _installerAssetPattern = RegExp(
    r'^MYA-(?:(?:Complete|Desktop)-)?Setup-.+\.exe$',

    caseSensitive: false,
  );

  static final RegExp _androidApkAssetPattern = RegExp(
    r'^MYA-(?:(?:Complete|Mobile)-)?Android-.+\.apk$',

    caseSensitive: false,
  );

  Uri get _releasesUri => Uri.https(
    'api.github.com',
    '/repos/$owner/$repo/releases',
    const {'per_page': '50'},
  );

  Map<String, String> get _headers => const {
    'Accept': 'application/vnd.github+json',

    'User-Agent': 'MYA-Updater',
  };

  @override
  Future<AppReleaseInfo?> checkForUpdate(AppVersion current) async {
    final response = await _client.get(_releasesUri, headers: _headers);

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw UpdateCheckException(
        'GitHub Releases indisponible (${response.statusCode}).',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! List) {
      throw UpdateCheckException('Réponse GitHub Releases invalide.');
    }

    final expectedTagPrefix =
        releaseTagPrefix ?? ProductConfig.releaseTagPrefix;
    final expectedAssetPrefix =
        assetPrefix ?? ProductConfig.assetPrefixForCurrentPlatform();
    final candidates = <AppReleaseInfo>[];
    for (final item in payload) {
      if (item is! Map<String, dynamic>) continue;
      final tag = item['tag_name'] as String? ?? '';
      if (!tag.toLowerCase().startsWith(expectedTagPrefix.toLowerCase())) {
        continue;
      }
      final release = parseReleasePayload(
        item,
        assetKind: assetKind,
        assetPrefix: expectedAssetPrefix,
      );
      if (release != null) candidates.add(release);
    }
    candidates.sort((a, b) => b.version.compareTo(a.version));
    final release = candidates.firstOrNull;
    return release != null && release.version.isNewerThan(current)
        ? release
        : null;
  }

  static AppReleaseInfo? parseReleasePayload(
    Map<String, dynamic> payload, {

    required UpdateAssetKind assetKind,
    String? assetPrefix,
  }) {
    final assets = payload['assets'];

    if (assets is! List || assets.isEmpty) return null;

    final pattern = switch (assetKind) {
      UpdateAssetKind.windowsInstaller => _installerAssetPattern,

      UpdateAssetKind.androidApk => _androidApkAssetPattern,
    };

    Map<String, dynamic>? selectedAsset;

    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;

      final name = asset['name'] as String?;

      if (name != null &&
          pattern.hasMatch(name) &&
          (assetPrefix == null ||
              name.toLowerCase().startsWith(assetPrefix.toLowerCase()))) {
        selectedAsset = asset;

        break;
      }
    }

    if (selectedAsset == null) return null;

    final fileName = selectedAsset['name'] as String;

    final downloadUrl = selectedAsset['browser_download_url'] as String?;

    if (downloadUrl == null || downloadUrl.isEmpty) return null;

    final version = switch (assetKind) {
      UpdateAssetKind.windowsInstaller => AppVersion.fromInstallerAssetName(
        fileName,
      ),

      UpdateAssetKind.androidApk => AppVersion.fromAndroidApkAssetName(
        fileName,
      ),
    };

    final resolved =
        version ?? AppVersion.parse(payload['tag_name'] as String? ?? '');

    final publishedAtRaw = payload['published_at'] as String?;

    return AppReleaseInfo(
      version: resolved,

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
    if (Platform.isWindows) {
      await Process.start(
        installer.path,
        windowsSilentInstallerArguments,
        runInShell: true,
      );

      exit(0);
    }

    if (Platform.isAndroid) {
      final result = await OpenFilex.open(
        installer.path,

        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        throw UpdateDownloadException(
          result.message.isNotEmpty
              ? result.message
              : 'Installation annulée ou impossible.',
        );
      }

      return;
    }

    throw UnsupportedError('Installation non supportée sur cette plateforme.');
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
