import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/updates/app_version.dart';
import 'package:mya/application/updates/github_release_update_service.dart';

void main() {
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
    });

    expect(release, isNotNull);
    expect(
      release!.version,
      const AppVersion(major: 1, minor: 0, patch: 2, build: 5),
    );
    expect(release.fileName, 'MYA-Setup-1.0.2-build5.exe');
    expect(release.releaseNotes, 'Correctifs sync');
  });
}
