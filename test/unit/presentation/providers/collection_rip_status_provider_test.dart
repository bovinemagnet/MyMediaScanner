import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';

void main() {
  group('RipStatus', () {
    test('has expected values', () {
      expect(RipStatus.values, [
        RipStatus.noRip,
        RipStatus.ripped,
        RipStatus.verified,
        RipStatus.qualityIssues,
      ]);
    });

    test('noRip is first value', () {
      expect(RipStatus.values.first, RipStatus.noRip);
    });

    test('verified is distinct from ripped', () {
      expect(RipStatus.verified, isNot(RipStatus.ripped));
    });

    test('qualityIssues is distinct from verified', () {
      expect(RipStatus.qualityIssues, isNot(RipStatus.verified));
    });
  });

  group('RipStatusFilter', () {
    test('has expected values', () {
      expect(RipStatusFilter.values, [
        RipStatusFilter.all,
        RipStatusFilter.hasRip,
        RipStatusFilter.noRip,
        RipStatusFilter.verified,
        RipStatusFilter.qualityIssues,
      ]);
    });

    test('all is first value', () {
      expect(RipStatusFilter.values.first, RipStatusFilter.all);
    });

    test('hasRip is distinct from noRip', () {
      expect(RipStatusFilter.hasRip, isNot(RipStatusFilter.noRip));
    });

    test('verified is distinct from qualityIssues', () {
      expect(RipStatusFilter.verified, isNot(RipStatusFilter.qualityIssues));
    });
  });
}
