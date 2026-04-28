import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/services/tmdb_deep_link_handler.dart';
import 'package:mymediascanner/domain/entities/tmdb_connection_state.dart';
import 'package:mymediascanner/domain/entities/tmdb_deep_link_event.dart';
import 'package:mymediascanner/domain/usecases/connect_tmdb_account_usecase.dart';

class _MockConnect extends Mock implements ConnectTmdbAccountUseCase {}

void main() {
  late StreamController<Uri> uriController;
  late _MockConnect connect;
  late TmdbDeepLinkHandler handler;
  late List<TmdbDeepLinkEvent> events;

  setUp(() {
    uriController = StreamController<Uri>.broadcast();
    connect = _MockConnect();
    handler = TmdbDeepLinkHandler(
      connect: connect,
      uriStream: uriController.stream,
    );
    events = [];
    handler.events.listen(events.add);
    handler.start();
  });

  tearDown(() async {
    await handler.dispose();
    await uriController.close();
  });

  Future<void> flush() async {
    await Future<void>.delayed(Duration.zero);
  }

  test('happy path: matching token + approved=true calls finishConnect',
      () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');
    when(() => connect.finishConnect()).thenAnswer((_) async =>
        const TmdbConnected(accountId: 42, username: 'paul'));

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=tok-1&approved=true'));
    await flush();

    verify(() => connect.finishConnect()).called(1);
    expect(events, [isA<TmdbDeepLinkSuccess>()]);
  });

  test('approved=false emits Cancelled and calls connect.cancel', () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');
    when(() => connect.cancel()).thenReturn(null);

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=tok-1&approved=false'));
    await flush();

    verifyNever(() => connect.finishConnect());
    verify(() => connect.cancel()).called(1);
    expect(events, [isA<TmdbDeepLinkCancelled>()]);
  });

  test('token mismatch emits Mismatch without calling finishConnect',
      () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=other&approved=true'));
    await flush();

    verifyNever(() => connect.finishConnect());
    expect(events, [isA<TmdbDeepLinkMismatch>()]);
  });

  test('no pending token emits NoPending', () async {
    when(() => connect.pendingRequestToken).thenReturn(null);

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=tok-1&approved=true'));
    await flush();

    verifyNever(() => connect.finishConnect());
    expect(events, [isA<TmdbDeepLinkNoPending>()]);
  });

  test('malformed URI emits Mismatch', () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');

    uriController.add(Uri.parse('mymediascanner://wrong-host?foo=bar'));
    await flush();

    verifyNever(() => connect.finishConnect());
    expect(events, [isA<TmdbDeepLinkMismatch>()]);
  });

  test('finishConnect failure emits Mismatch', () async {
    when(() => connect.pendingRequestToken).thenReturn('tok-1');
    when(() => connect.finishConnect()).thenAnswer(
        (_) async => const TmdbConnectionError('upstream rejected'));

    uriController.add(Uri.parse(
        'mymediascanner://tmdb-callback?request_token=tok-1&approved=true'));
    await flush();

    verify(() => connect.finishConnect()).called(1);
    expect(events.single, isA<TmdbDeepLinkMismatch>());
    expect((events.single as TmdbDeepLinkMismatch).reason,
        contains('upstream rejected'));
  });
}
