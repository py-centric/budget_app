import 'dart:io';

void main(List<String> args) async {
  final dryRun = args.contains('--dry-run');

  final bumpArg = args.where((a) => !a.startsWith('--')).firstOrNull;
  String bumpType;

  if (bumpArg != null && ['patch', 'minor', 'major'].contains(bumpArg.toLowerCase())) {
    bumpType = bumpArg.toLowerCase();
  } else {
    bumpType = _detectBumpType();
    if (bumpArg == null) {
      print('Auto-detected bump: $bumpType');
    } else {
      print('Invalid bump type "$bumpArg". Use: patch, minor, or major.');
      exit(1);
    }
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

  if (dryRun) {
    print('[dry-run] $oldVersion → $newVersion (bump: $bumpType)');
    exit(0);
  }

  content = content.replaceFirst(
    RegExp(r"^version:\s*.*$", multiLine: true),
    'version: $newVersion',
  );

  pubspecFile.writeAsStringSync(content);
  print('$oldVersion → $newVersion');
}

String _detectBumpType() {
  final result = Process.runSync(
    'git',
    ['log', '--format=%s', '--no-merges'],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    print('Warning: git log failed. Defaulting to patch bump.');
    return 'patch';
  }

  final commits = (result.stdout as String).split('\n').where((l) => l.trim().isNotEmpty);

  var hasBreaking = false;
  var hasFeat = false;
  var hasFix = false;

  for (final commit in commits) {
    final trimmed = commit.trim();

    if (trimmed.contains(RegExp(r'!\s*:')) ||
        trimmed.contains(RegExp(r'BREAKING\s+CHANGE', caseSensitive: false))) {
      hasBreaking = true;
    }

    if (trimmed.startsWith(RegExp(r'\w+\(?.+\)?!?\s*:'))) {
      final type = trimmed.split(RegExp(r'[(!]')).first.toLowerCase();
      if (type == 'feat') hasFeat = true;
      if (type == 'fix') hasFix = true;
    }
  }

  if (hasBreaking) return 'major';
  if (hasFeat) return 'minor';
  return 'patch';
}
