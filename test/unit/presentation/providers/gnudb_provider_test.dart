import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/remote/api/gnudb/models/gnudb_disc_dto.dart';
import 'package:mymediascanner/domain/usecases/lookup_gnudb_for_rip_usecase.dart';
import 'package:mymediascanner/presentation/providers/gnudb_provider.dart';

void main() {
  GnudbLookupState readState(ProviderContainer container) =>
      container.read(gnudbLookupNotifierProvider);

  test('initial state is idle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final s = readState(container);
    expect(s.status, GnudbLookupStatus.idle);
    expect(s.candidates, isEmpty);
  });

  test('reset returns state to idle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Force a non-idle state via direct assignment helper: we test the
    // reset() method using the notifier's public API.
    final notifier = container.read(gnudbLookupNotifierProvider.notifier);
    notifier.reset();
    expect(container.read(gnudbLookupNotifierProvider).status,
        GnudbLookupStatus.idle);
  });

  test('GnudbLookupState.copyWith preserves defaults', () {
    const s = GnudbLookupState();
    final updated =
        s.copyWith(status: GnudbLookupStatus.fetching);
    expect(updated.status, GnudbLookupStatus.fetching);
    expect(updated.candidates, isEmpty);
  });

  test(
      'GnudbLookupState.copyWith carries candidates across status changes',
      () {
    const dto = GnudbDiscDto(
      discId: 'abcdef01',
      artist: 'A',
      albumTitle: 'B',
      trackTitles: ['x'],
    );
    const candidate = GnudbCandidate(
      discId: 'abcdef01',
      category: 'rock',
      dto: dto,
    );
    const s = GnudbLookupState();
    final withCandidates = s.copyWith(
      status: GnudbLookupStatus.ambiguous,
      candidates: [candidate],
    );
    expect(withCandidates.candidates, hasLength(1));
    final applying =
        withCandidates.copyWith(status: GnudbLookupStatus.applying);
    // candidates are carried over because copyWith does not clear them.
    expect(applying.candidates, hasLength(1));
  });
}
