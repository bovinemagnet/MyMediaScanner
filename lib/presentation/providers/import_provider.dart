import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mymediascanner/domain/entities/import_row.dart';
import 'package:mymediascanner/domain/entities/import_source.dart';
import 'package:mymediascanner/domain/usecases/import_collection_usecase.dart';
import 'package:mymediascanner/domain/usecases/save_media_item_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

part 'import_provider.freezed.dart';

enum ImportPhase { idle, parsing, enriching, ready, saving, done, error }

@freezed
sealed class ImportState with _$ImportState {
  const factory ImportState({
    @Default(ImportPhase.idle) ImportPhase phase,
    ImportSource? source,
    @Default([]) List<ImportRow> rows,
    @Default(0) int enrichedCount,
    @Default(0) int savedCount,
    String? errorMessage,
  }) = _ImportState;
}

final importUseCaseProvider = Provider<ImportCollectionUseCase>((ref) {
  return ImportCollectionUseCase(
    metadataRepository: ref.watch(metadataRepositoryProvider),
    mediaItemRepository: ref.watch(mediaItemRepositoryProvider),
    saveMediaItem: SaveMediaItemUseCase(
      repository: ref.watch(mediaItemRepositoryProvider),
    ),
  );
});

final importNotifierProvider =
    NotifierProvider<ImportNotifier, ImportState>(ImportNotifier.new);

class ImportNotifier extends Notifier<ImportState> {
  @override
  ImportState build() => const ImportState();

  /// Parse [content] using the [source]'s parser, then begin enrichment.
  Future<void> startImport({
    required ImportSource source,
    required String content,
  }) async {
    final usecase = ref.read(importUseCaseProvider);

    if (!ref.mounted) return;
    state = ImportState(phase: ImportPhase.parsing, source: source);

    final List<ImportRow> parsed;
    try {
      parsed = usecase.parse(source, content);
    } on FormatException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: ImportPhase.error,
        errorMessage: 'Could not parse file: ${e.message}',
      );
      return;
    }

    if (parsed.isEmpty) {
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: ImportPhase.error,
        errorMessage: 'No rows found in file.',
      );
      return;
    }

    if (!ref.mounted) return;
    state = state.copyWith(
      phase: ImportPhase.enriching,
      rows: parsed,
      enrichedCount: 0,
    );

    final updated = List<ImportRow>.from(parsed);
    var i = 0;
    await for (final enriched in usecase.enrich(parsed)) {
      // User may have navigated away mid-enrichment. Break out rather than
      // writing to a disposed notifier.
      if (!ref.mounted) return;
      updated[i] = enriched;
      i++;
      state = state.copyWith(
        rows: List.unmodifiable(updated),
        enrichedCount: i,
      );
    }

    if (!ref.mounted) return;
    state = state.copyWith(phase: ImportPhase.ready);
  }

  /// Toggle the accepted flag for the row at [index].
  void toggleAccepted(int index, bool accepted) {
    final rows = List<ImportRow>.from(state.rows);
    rows[index] = rows[index].copyWith(accepted: accepted);
    state = state.copyWith(rows: List.unmodifiable(rows));
  }

  /// Bulk accept/reject all rows that pass [predicate].
  void setAcceptedWhere(
      bool Function(ImportRow row) predicate, bool accepted) {
    final rows = state.rows
        .map((r) => predicate(r) ? r.copyWith(accepted: accepted) : r)
        .toList();
    state = state.copyWith(rows: List.unmodifiable(rows));
  }

  /// Save every accepted+enriched row through [SaveMediaItemUseCase].
  Future<void> saveAccepted() async {
    if (state.phase != ImportPhase.ready) return;
    final usecase = ref.read(importUseCaseProvider);
    if (!ref.mounted) return;
    state = state.copyWith(phase: ImportPhase.saving);
    try {
      final saved = await usecase.saveAccepted(state.rows);
      if (!ref.mounted) return;
      state = state.copyWith(phase: ImportPhase.done, savedCount: saved);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: ImportPhase.error,
        errorMessage: 'Save failed: $e',
      );
    }
  }

  void reset() {
    state = const ImportState();
  }
}
