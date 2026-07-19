import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run scripts/version_bump.dart <patch|minor|major>');
    print('  patch  — increment patch version (1.0.0 → 1.0.1)');
    print('  minor  — increment minor version (1.0.0 → 1.1.0)');
    print('  major  — increment major version (1.0.0 → 2.0.0)');
    exit(1);
  }

  final bumpType = args[0].toLowerCase();
  if (!['patch', 'minor', 'major'].contains(bumpType)) {
    print('Invalid bump type. Use: patch, minor, or major.');
    exit(1);
  }

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found in current directory.');
    print('Run this script from the Flutter project root.');
    exit(1);
  }

  var content = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)$", multiLine: true);
  final match = versionRegex.firstMatch(content);

  if (match == null) {
    print('Error: Could not parse version from pubspec.yaml.');
    print('Expected format: version: <major>.<minor>.<patch>+<build>');
    exit(1);
  }

  var major = int.parse(match.group(1)!);
  var minor = int.parse(match.group(2)!);
  var patch = int.parse(match.group(3)!);
  var build = int.parse(match.group(4)!);

  switch (bumpType) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
    case 'minor':
      minor++;
      patch = 0;
    case 'patch':
      patch++;
  }
  build++;

  final oldVersion = '${match.group(1)}.${match.group(2)}.${match.group(3)}+${match.group(4)}';
  final newVersion = '$major.$minor.$patch+$build';
  content = content.replaceFirst(
    RegExp(r"^version:\s*.*$", multiLine: true),
    'version: $newVersion',
  );

  pubspecFile.writeAsStringSync(content);
  print('$oldVersion → $newVersion');
}
