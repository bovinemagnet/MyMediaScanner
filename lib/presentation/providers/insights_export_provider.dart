// Insights export provider — shared export trigger for insights and
// collection screens.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/export_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:path_provider/path_provider.dart';

/// Provides a shared [ExportCollectionUseCase] instance.
final exportUseCaseProvider = Provider<ExportCollectionUseCase>((ref) {
  return ExportCollectionUseCase(
    repository: ref.watch(mediaItemRepositoryProvider),
  );
});

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
