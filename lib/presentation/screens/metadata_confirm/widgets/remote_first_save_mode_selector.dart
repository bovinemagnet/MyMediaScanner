import 'package:flutter/material.dart';

/// Three-option save mode for remote-first-enabled film/TV saves.
enum SaveMode {
  saveLocally,
  saveLocallyAndSync,
  tmdbOnly,
}

/// Radio group letting the user choose between local save, local-and-push,
/// or TMDB-only save when remote-first save mode is enabled.
///
/// Callers must gate this widget on:
///   - account sync is enabled
///   - remote-first toggle is on
///   - the item has a tmdb_id and movie/tv media type
class RemoteFirstSaveModeSelector extends StatelessWidget {
  const RemoteFirstSaveModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SaveMode value;
  final ValueChanged<SaveMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<SaveMode>(
      groupValue: value,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where to save:',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          const RadioListTile<SaveMode>(
            value: SaveMode.saveLocally,
            title: Text('Save locally'),
            subtitle: Text('Adds to your collection. No TMDB push.'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          const RadioListTile<SaveMode>(
            value: SaveMode.saveLocallyAndSync,
            title: Text('Save locally and sync to TMDB'),
            subtitle:
                Text('Adds to your collection and pushes to TMDB.'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          const RadioListTile<SaveMode>(
            value: SaveMode.tmdbOnly,
            title: Text('TMDB only'),
            subtitle: Text('Stored on TMDB only — no local collection entry.'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
        ],
      ),
    );
  }
}
