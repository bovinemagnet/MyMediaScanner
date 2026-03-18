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
            ref.read(scannerProvider.notifier).reset();
            context.go('/scan');
          },
        ),
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          if (disambigState.error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                disambigState.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
                              ref
                                  .read(scannerProvider.notifier)
                                  .onCandidateSelected(detail);
                              context.go('/scan/confirm');
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
              child: OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        ref.read(scannerProvider.notifier).onNoneSelected(
                          disambigState.barcode,
                          disambigState.barcodeType,
                        );
                        context.go('/scan/confirm');
                      },
                icon: const Icon(Icons.not_interested),
                label: const Text('None of these \u2014 save with barcode only'),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
