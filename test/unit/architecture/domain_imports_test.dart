import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture guard: `lib/domain/` must have zero dependencies on
/// `lib/data/` or `lib/presentation/`.
///
/// Author: Paul Snow
/// Since: 0.0.0
void main() {
  test('lib/domain has no imports from lib/data or lib/presentation', () {
    final domainDir = Directory('lib/domain');
    expect(domainDir.existsSync(), isTrue,
        reason: 'Run tests from the project root');

    final forbidden = RegExp(
        r'''import\s+['"]package:mymediascanner/(data|presentation)/''');

    final violations = <String>[];
    final files = domainDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (forbidden.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(violations, isEmpty,
        reason: 'Domain layer must not import data/presentation code:\n'
            '${violations.join('\n')}');
  });
}
