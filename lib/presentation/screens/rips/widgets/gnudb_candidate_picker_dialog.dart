/// Modal dialog for disambiguating multiple GnuDB matches.
///
/// Author: Paul Snow
/// Since: 0.0.0
library;

import 'package:flutter/material.dart';
import 'package:mymediascanner/data/mappers/gnudb_mapper.dart';
import 'package:mymediascanner/domain/usecases/lookup_gnudb_for_rip_usecase.dart';
import 'package:mymediascanner/presentation/screens/disambiguation/widgets/candidate_card.dart';

/// Shows a dialog listing GnuDB [candidates] and returns the user's
/// selection, or `null` if cancelled.
Future<GnudbCandidate?> showGnudbCandidatePicker({
  required BuildContext context,
  required List<GnudbCandidate> candidates,
}) {
  return showDialog<GnudbCandidate>(
    context: context,
    builder: (ctx) => GnudbCandidatePickerDialog(candidates: candidates),
  );
}

class GnudbCandidatePickerDialog extends StatelessWidget {
  const GnudbCandidatePickerDialog({
    super.key,
    required this.candidates,
  });

  final List<GnudbCandidate> candidates;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a GnuDB match'),
      content: SizedBox(
        width: 460,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: candidates.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final c = candidates[i];
            final candidate = GnudbMapper.toCandidate(
              c.dto,
              category: c.category,
            );
            return CandidateCard(
              candidate: candidate,
              onTap: () => Navigator.of(context).pop(c),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
