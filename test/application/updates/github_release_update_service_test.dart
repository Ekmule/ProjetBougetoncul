import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mya/application/updates/app_version.dart';
import 'package:mya/application/updates/github_release_update_service.dart';
import 'package:mya/application/updates/update_asset_kind.dart';

void main() {
  test('mise à jour Windows lance Inno silencieusement', () {
    expect(windowsSilentInstallerArguments, contains('/VERYSILENT'));
    expect(windowsSilentInstallerArguments, contains('/SUPPRESSMSGBOXES'));
    expect(windowsSilentInstallerArguments, contains('/CLOSEAPPLICATIONS'));
    expect(windowsSilentInstallerArguments, contains('/RESTARTAPPLICATIONS'));
  });

  test('parseReleasePayload extrait l installateur MYA', () {
    final release = GitHubReleaseUpdateService.parseReleasePayload({
      'tag_name': 'v1.0.2',
      'body': 'Correctifs sync',
      'published_at': '2026-09-30T08:00:00Z',
      'assets': [
        {
          'name': 'notes.txt',
          'browser_download_url': 'https://example.com/notes.txt',
        },
        {
          'name': 'MYA-Setup-1.0.2-build5.exe',
          'browser_download_url':
              'https://example.com/MYA-Setup-1.0.2-build5.exe',
        },
      ],
    }, assetKind: UpdateAssetKind.windowsInstaller);

    expect(release, isNotNull);
    expect(
      release!.version,
      const AppVersion(major: 1, minor: 0, patch: 2, build: 5),
    );
    expect(release.fileName, 'MYA-Setup-1.0.2-build5.exe');
    expect(release.releaseNotes, 'Correctifs sync');
  });

  test('parseReleasePayload extrait l APK Android MYA', () {
    final release = GitHubReleaseUpdateService.parseReleasePayload({
      'tag_name': 'v1.0.2',
      'assets': [
        {
          'name': 'MYA-Android-1.0.2-build3.apk',
          'browser_download_url':
              'https://example.com/MYA-Android-1.0.2-build3.apk',
        },
      ],
    }, assetKind: UpdateAssetKind.androidApk);

    expect(release, isNotNull);
    expect(release!.fileName, 'MYA-Android-1.0.2-build3.apk');
    expect(
      release.version,
      const AppVersion(major: 1, minor: 0, patch: 2, build: 3),
    );
  });

  test('sélectionne la dernière release du produit demandé', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/repos/owner/repo/releases');
      return http.Response(
        jsonEncode([
          {
            'tag_name': 'desktop-v9.0.0-build1',
            'assets': [
              {
                'name': 'MYA-Desktop-Setup-9.0.0.exe',
                'browser_download_url': 'https://example.com/desktop.exe',
              },
            ],
          },
          {
            'tag_name': 'complete-v1.2.0-build4',
            'assets': [
              {
                'name': 'MYA-Complete-Setup-1.2.0-build4.exe',
                'browser_download_url': 'https://example.com/complete.exe',
              },
            ],
          },
        ]),
        200,
      );
    });
    final service = GitHubReleaseUpdateService(
      owner: 'owner',
      repo: 'repo',
      assetKind: UpdateAssetKind.windowsInstaller,
      releaseTagPrefix: 'complete-v',
      assetPrefix: 'MYA-Complete-Setup-',
      client: client,
    );

    final release = await service.checkForUpdate(
      const AppVersion(major: 1, minor: 1, patch: 0),
    );

    expect(release?.fileName, 'MYA-Complete-Setup-1.2.0-build4.exe');
  });
}
