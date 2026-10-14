import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/updates/app_version.dart';

void main() {
  group('AppVersion', () {
    test('parse depuis le nom d installateur', () {
      expect(
        AppVersion.fromInstallerAssetName('MYA-Setup-1.0.2-build5.exe'),
        const AppVersion(major: 1, minor: 0, patch: 2, build: 5),
      );
      expect(
        AppVersion.fromInstallerAssetName('MYA-Setup-1.0.2.exe'),
        const AppVersion(major: 1, minor: 0, patch: 2),
      );
    });

    test('compare semver puis build', () {
      const current = AppVersion(major: 1, minor: 0, patch: 1, build: 4);
      const newerPatch = AppVersion(major: 1, minor: 0, patch: 2);
      const newerBuild = AppVersion(major: 1, minor: 0, patch: 1, build: 5);

      expect(newerPatch.isNewerThan(current), isTrue);
      expect(newerBuild.isNewerThan(current), isTrue);
      expect(current.isNewerThan(current), isFalse);
    });
  });
}
