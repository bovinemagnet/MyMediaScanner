import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/tmdb_approval_callback.dart';

void main() {
  group('TmdbApprovalCallback.parse', () {
    test('approved=true yields TmdbApprovalApproved', () {
      final uri = Uri.parse(
          'mymediascanner://tmdb-callback?request_token=abc&approved=true');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalApproved>());
      expect((result as TmdbApprovalApproved).requestToken, 'abc');
    });

    test('approved=false yields TmdbApprovalDenied', () {
      final uri = Uri.parse(
          'mymediascanner://tmdb-callback?request_token=abc&approved=false');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalDenied>());
      expect((result as TmdbApprovalDenied).requestToken, 'abc');
    });

    test('approved missing yields TmdbApprovalMalformed', () {
      final uri =
          Uri.parse('mymediascanner://tmdb-callback?request_token=abc');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalMalformed>());
    });

    test('request_token missing yields TmdbApprovalMalformed', () {
      final uri =
          Uri.parse('mymediascanner://tmdb-callback?approved=true');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalMalformed>());
    });

    test('wrong host yields TmdbApprovalMalformed', () {
      final uri = Uri.parse(
          'mymediascanner://other-callback?request_token=abc&approved=true');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalMalformed>());
    });

    test('wrong scheme yields TmdbApprovalMalformed', () {
      final uri =
          Uri.parse('https://tmdb-callback?request_token=abc&approved=true');
      final result = TmdbApprovalCallback.parse(uri);
      expect(result, isA<TmdbApprovalMalformed>());
    });

    test('approved value is case-insensitive (TRUE / True)', () {
      for (final v in const ['TRUE', 'True', 'true']) {
        final uri = Uri.parse(
            'mymediascanner://tmdb-callback?request_token=x&approved=$v');
        expect(TmdbApprovalCallback.parse(uri), isA<TmdbApprovalApproved>(),
            reason: 'value=$v should approve');
      }
    });
  });
}
