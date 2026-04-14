import 'package:flutter/widgets.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/detect_duplicate_usecase.dart';
import 'package:mymediascanner/presentation/widgets/duplicate_warning_dialog.dart';

/// Runs a duplicate check and, if a duplicate is detected, shows the
/// [DuplicateWarningDialog]. Returns `true` if the caller should proceed
/// with the save (no duplicate, or user confirmed "save anyway"), and
/// `false` if the save should be aborted.
Future<bool> confirmSaveOrSkipIfDuplicate({
  required BuildContext context,
  required IMediaItemRepository repository,
  required String barcode,
  required String title,
  int? year,
  String? excludeId,
}) async {
  final usecase = DetectDuplicateUsecase(repository);
  final match = await usecase(
    barcode: barcode,
    title: title,
    year: year,
    excludeId: excludeId,
  );
  if (match.kind == DuplicateKind.none) return true;
  if (!context.mounted) return false;
  final confirmed = await showDuplicateWarningDialog(context, match);
  return confirmed == true;
}
