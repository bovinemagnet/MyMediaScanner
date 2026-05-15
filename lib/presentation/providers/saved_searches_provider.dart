// Saved searches persisted to SharedPreferences.
//
// Author: Paul Snow
// Since: 0.0.0

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/providers/collection_rip_status_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'saved_searches_v1';

class SavedSearch {
  const SavedSearch({required this.name, required this.filter});

  final String name;
  final CollectionFilterState filter;

  Map<String, dynamic> toJson() => {
        'name': name,
        'filter': {
          'mediaType': filter.mediaType?.name,
          'search': filter.search,
          'sortBy': filter.sortBy,
          'ascending': filter.ascending,
          'lentOnly': filter.lentOnly,
          'rippedOnly': filter.rippedOnly,
          'ripStatusFilter': filter.ripStatusFilter.name,
          'minYear': filter.minYear,
          'maxYear': filter.maxYear,
          'minRating': filter.minRating,
          'selectedGenres': filter.selectedGenres.toList(),
        },
      };

  static SavedSearch fromJson(Map<String, dynamic> json) {
    final f = json['filter'] as Map<String, dynamic>;
    MediaType? mt;
    final rawType = f['mediaType'] as String?;
    if (rawType != null) {
      for (final t in MediaType.values) {
        if (t.name == rawType) {
          mt = t;
          break;
        }
      }
    }
    RipStatusFilter status = RipStatusFilter.all;
    final rawStatus = f['ripStatusFilter'] as String?;
    if (rawStatus != null) {
      for (final s in RipStatusFilter.values) {
        if (s.name == rawStatus) {
          status = s;
          break;
        }
      }
    }
    final genres = (f['selectedGenres'] as List?)?.cast<String>() ?? const [];

    return SavedSearch(
      name: json['name'] as String,
      filter: (
        mediaType: mt,
        search: f['search'] as String?,
        sortBy: f['sortBy'] as String?,
        ascending: f['ascending'] as bool? ?? false,
        lentOnly: f['lentOnly'] as bool? ?? false,
        rippedOnly: f['rippedOnly'] as bool? ?? false,
        ripStatusFilter: status,
        minYear: f['minYear'] as int?,
        maxYear: f['maxYear'] as int?,
        minRating: (f['minRating'] as num?)?.toDouble(),
        selectedGenres: genres.toSet(),
      ),
    );
  }
}

class SavedSearchesNotifier extends AsyncNotifier<List<SavedSearch>> {
  @override
  Future<List<SavedSearch>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    return raw
        .map((line) {
          try {
            return SavedSearch.fromJson(jsonDecode(line) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<SavedSearch>()
        .toList(growable: false);
  }

  Future<void> save(SavedSearch search) async {
    final current = state.value ?? const <SavedSearch>[];
    final without =
        current.where((s) => s.name != search.name).toList(growable: false);
    final next = [...without, search];
    await _writeAll(next);
    state = AsyncData(next);
  }

  Future<void> remove(String name) async {
    final current = state.value ?? const <SavedSearch>[];
    final next = current.where((s) => s.name != name).toList(growable: false);
    await _writeAll(next);
    state = AsyncData(next);
  }

  Future<void> _writeAll(List<SavedSearch> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      searches.map((s) => jsonEncode(s.toJson())).toList(growable: false),
    );
  }
}

final savedSearchesProvider =
    AsyncNotifierProvider<SavedSearchesNotifier, List<SavedSearch>>(
        SavedSearchesNotifier.new);
