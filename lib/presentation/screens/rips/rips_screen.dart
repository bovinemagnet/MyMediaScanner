import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_coverage_view.dart';
import 'package:mymediascanner/presentation/screens/rips/widgets/rip_library_view.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

/// Top-level screen for the Rips tab (desktop only).
///
/// Provides a segmented toggle between the Library and Coverage views.
class RipsScreen extends ConsumerStatefulWidget {
  const RipsScreen({super.key});

  @override
  ConsumerState<RipsScreen> createState() => _RipsScreenState();
}

enum _RipsSegment { library, coverage }

class _RipsScreenState extends ConsumerState<RipsScreen> {
  _RipsSegment _selected = _RipsSegment.library;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(
            title: 'Rip Library',
            subtitle:
                'Manage your FLAC rip collection and compare coverage '
                'against physical media.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<_RipsSegment>(
              segments: const [
                ButtonSegment(
                  value: _RipsSegment.library,
                  label: Text('Library'),
                  icon: Icon(Icons.album),
                ),
                ButtonSegment(
                  value: _RipsSegment.coverage,
                  label: Text('Coverage'),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {_selected},
              onSelectionChanged: (selection) {
                setState(() {
                  _selected = selection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selected == _RipsSegment.library
                ? const RipLibraryView()
                : const RipCoverageView(),
          ),
        ],
      ),
    );
  }
}
