import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/disambiguation_provider.dart';
import 'package:mymediascanner/presentation/providers/scanner_provider.dart';
import 'package:mymediascanner/presentation/screens/disambiguation/widgets/candidate_card.dart';

class DisambiguationScreen extends ConsumerWidget {
  const DisambiguationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disambigState = ref.watch(disambiguationProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLoading =
        disambigState.state == DisambiguationState.loading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/scan');
          ref.read(scannerProvider.notifier).reset();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select the correct match'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/scan');
              ref.read(scannerProvider.notifier).reset();
            },
          ),
        ),
        body: Column(
          children: [
            if (isLoading)
              LinearProgressIndicator(color: colors.primary),
            if (disambigState.error != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: colors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        disambigState.error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Header hint
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Multiple matches found. Tap the correct one:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: disambigState.candidates.length,
                itemBuilder: (context, index) {
                  final candidate = disambigState.candidates[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CandidateCard(
                      candidate: candidate,
                      onTap: isLoading
                          ? () {}
                          : () async {
                              final notifier = ref.read(
                                  disambiguationProvider.notifier);
                              final detail =
                                  await notifier.selectCandidate(candidate);
                              if (detail != null && context.mounted) {
                                context.go('/scan/confirm');
                                ref
                                    .read(scannerProvider.notifier)
                                    .onCandidateSelected(detail);
                              }
                            },
                    ),
                  );
                },
              ),
            ),
            // "None of these" action
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.go('/scan/confirm');
                            ref
                                .read(scannerProvider.notifier)
                                .onNoneSelected(
                                  disambigState.barcode,
                                  disambigState.barcodeType,
                                );
                          },
                    icon: const Icon(Icons.not_interested),
                    label: const Text(
                        'None of these \u2014 save with barcode only'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
