// Insights export provider — shared export trigger for insights and
// collection screens.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/export_collection_usecase.dart';
import 'package:mymediascanner/domain/usecases/valuation_report_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:path_provider/path_provider.dart';

/// Provides a shared [ExportCollectionUseCase] instance.
final exportUseCaseProvider = Provider<ExportCollectionUseCase>((ref) {
  return ExportCollectionUseCase(
    repository: ref.watch(mediaItemRepositoryProvider),
  );
});

/// Provides a shared [ValuationReportUseCase] instance.
final valuationReportUseCaseProvider =
    Provider<ValuationReportUseCase>((ref) => const ValuationReportUseCase());

/// Output formats for the valuation report.
enum ValuationReportFormat { csv, html }

/// State for the export operation.
enum ExportStatus { idle, exporting, success, error }

class ExportState {
  const ExportState({
    this.status = ExportStatus.idle,
    this.filePath,
    this.error,
  });

  final ExportStatus status;
  final String? filePath;
  final String? error;
}

/// Notifier that manages collection export operations.
class ExportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() => const ExportState();

  /// Exports the collection in the given [format] and returns the file path.
  Future<String?> export(ExportFormat format) async {
    state = const ExportState(status: ExportStatus.exporting);
    try {
      final useCase = ref.read(exportUseCaseProvider);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = await useCase.execute(
        format: format,
        outputDirectory: directory.path,
      );
      state = ExportState(status: ExportStatus.success, filePath: filePath);
      return filePath;
    } catch (e) {
      state = ExportState(status: ExportStatus.error, error: e.toString());
      return null;
    }
  }
}

final insightsExportProvider =
    NotifierProvider<ExportNotifier, ExportState>(ExportNotifier.new);

/// Notifier that manages valuation-report exports.
class ValuationReportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() => const ExportState();

  /// Exports the valuation report in the given [format] and returns the
  /// file path on success.
  Future<String?> export(ValuationReportFormat format) async {
    state = const ExportState(status: ExportStatus.exporting);
    try {
      final repo = ref.read(mediaItemRepositoryProvider);
      final useCase = ref.read(valuationReportUseCaseProvider);
      final items = await repo.watchAll().first;
      final content = format == ValuationReportFormat.csv
          ? useCase.generateCsv(items)
          : useCase.generateHtml(items, generatedAt: DateTime.now().toUtc());
      final extension = format == ValuationReportFormat.csv ? 'csv' : 'html';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/valuation_report_$timestamp.$extension';
      await File(filePath).writeAsString(content);
      state = ExportState(status: ExportStatus.success, filePath: filePath);
      return filePath;
    } catch (e) {
      state = ExportState(status: ExportStatus.error, error: e.toString());
      return null;
    }
  }
}

final valuationReportProvider =
    NotifierProvider<ValuationReportNotifier, ExportState>(
        ValuationReportNotifier.new);

/// Progress state for the bulk current-value refresh action.
class BulkValueRefreshState {
  const BulkValueRefreshState({
    this.busy = false,
    this.processed = 0,
    this.total = 0,
    this.lastUpdated,
    this.error,
  });

  final bool busy;
  final int processed;
  final int total;
  final int? lastUpdated;
  final String? error;

  BulkValueRefreshState copyWith({
    bool? busy,
    int? processed,
    int? total,
    int? lastUpdated,
    String? error,
  }) {
    return BulkValueRefreshState(
      busy: busy ?? this.busy,
      processed: processed ?? this.processed,
      total: total ?? this.total,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: error,
    );
  }
}

/// Notifier that walks the priced music collection and triggers the
/// per-item current-value lookup. Items without a `discogs_release_id`
/// are skipped silently; the use case handles the no-id case internally.
class BulkValueRefreshNotifier extends Notifier<BulkValueRefreshState> {
  @override
  BulkValueRefreshState build() => const BulkValueRefreshState();

  Future<void> refreshAll() async {
    if (state.busy) return;
    final repo = ref.read(mediaItemRepositoryProvider);
    final useCase = ref.read(lookupCurrentValueUseCaseProvider);
    final items = await repo.watchAll().first;
    final eligible = items
        .where((i) =>
            !i.deleted &&
            i.extraMetadata.containsKey('discogs_release_id'))
        .toList();

    state = BulkValueRefreshState(busy: true, total: eligible.length);
    try {
      var processed = 0;
      for (final item in eligible) {
        await useCase.execute(item);
        processed++;
        state = state.copyWith(processed: processed);
      }
      state = state.copyWith(
        busy: false,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }
}

final bulkValueRefreshProvider =
    NotifierProvider<BulkValueRefreshNotifier, BulkValueRefreshState>(
        BulkValueRefreshNotifier.new);
