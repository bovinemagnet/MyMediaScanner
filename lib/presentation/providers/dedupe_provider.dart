import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/scan_duplicates_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

final scanDuplicatesUseCaseProvider = Provider<ScanDuplicatesUseCase>((ref) {
  return ScanDuplicatesUseCase(
    repository: ref.watch(mediaItemRepositoryProvider),
  );
});

final dedupeGroupsProvider = FutureProvider<List<DuplicateGroup>>((ref) {
  return ref.watch(scanDuplicatesUseCaseProvider).execute();
});
