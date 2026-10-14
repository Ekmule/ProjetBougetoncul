import 'package:package_info_plus/package_info_plus.dart';

/// Version sémantique MYA (x.y.z + build).
class AppVersion implements Comparable<AppVersion> {
  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.build = 0,
  });

  final int major;
  final int minor;
  final int patch;
  final int build;

  static final RegExp _installerPattern = RegExp(
    r'^MYA-Setup-(\d+)\.(\d+)\.(\d+)(?:-build(\d+))?\.exe$',
    caseSensitive: false,
  );

  static final RegExp _tagPattern = RegExp(
    r'^v?(\d+)\.(\d+)\.(\d+)(?:-build(\d+))?$',
    caseSensitive: false,
  );

  factory AppVersion.fromPackageInfo(PackageInfo info) {
    final parsed = AppVersion.parse(info.version);
    final build = int.tryParse(info.buildNumber);
    return AppVersion(
      major: parsed.major,
      minor: parsed.minor,
      patch: parsed.patch,
      build: build ?? parsed.build,
    );
  }

  factory AppVersion.parse(String value, {int build = 0}) {
    final trimmed = value.trim();
    final tagMatch = _tagPattern.firstMatch(trimmed);
    if (tagMatch != null) {
      return AppVersion(
        major: int.parse(tagMatch.group(1)!),
        minor: int.parse(tagMatch.group(2)!),
        patch: int.parse(tagMatch.group(3)!),
        build: tagMatch.group(4) == null
            ? build
            : int.parse(tagMatch.group(4)!),
      );
    }

    final parts = trimmed.split('.');
    if (parts.length < 3) {
      throw FormatException('Version MYA invalide : $value');
    }

    return AppVersion(
      major: int.parse(parts[0]),
      minor: int.parse(parts[1]),
      patch: int.parse(parts[2]),
      build: build,
    );
  }

  static AppVersion? fromInstallerAssetName(String fileName) {
    final match = _installerPattern.firstMatch(fileName.trim());
    if (match == null) return null;
    return AppVersion(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
      build: match.group(4) == null ? 0 : int.parse(match.group(4)!),
    );
  }

  String get versionKey => '$major.$minor.$patch+$build';

  String get displayName => build > 0
      ? '$major.$minor.$patch (build $build)'
      : '$major.$minor.$patch';

  bool isNewerThan(AppVersion other) => compareTo(other) > 0;

  @override
  int compareTo(AppVersion other) {
    final nameCompare = _compareTriple(
      major,
      minor,
      patch,
      other.major,
      other.minor,
      other.patch,
    );
    if (nameCompare != 0) return nameCompare;
    return build.compareTo(other.build);
  }

  @override
  bool operator ==(Object other) {
    return other is AppVersion &&
        major == other.major &&
        minor == other.minor &&
        patch == other.patch &&
        build == other.build;
  }

  @override
  int get hashCode => Object.hash(major, minor, patch, build);

  static int _compareTriple(
    int major,
    int minor,
    int patch,
    int otherMajor,
    int otherMinor,
    int otherPatch,
  ) {
    if (major != otherMajor) return major.compareTo(otherMajor);
    if (minor != otherMinor) return minor.compareTo(otherMinor);
    return patch.compareTo(otherPatch);
  }
}
