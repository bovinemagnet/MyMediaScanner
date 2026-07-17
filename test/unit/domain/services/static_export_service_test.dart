import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/services/static_export_service.dart';

MediaItem _item({
  required String id,
  String title = 'Title',
  String? coverUrl,
  MediaType mediaType = MediaType.film,
  List<String> tags = const [],
  bool deleted = false,
  int? year,
}) =>
    MediaItem(
      id: id,
      barcode: id,
      barcodeType: 'EAN13',
      mediaType: mediaType,
      title: title,
      coverUrl: coverUrl,
      year: year,
      deleted: deleted,
      extraMetadata: tags.isEmpty ? const {} : {'tags': tags},
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

String _asString(Uint8List bytes) => utf8.decode(bytes);

void main() {
  const service = StaticExportService();

  test('produces index.html plus one detail page per item', () {
    final out = service.build(items: [
      _item(id: 'a'),
      _item(id: 'b'),
    ]);
    expect(out.keys, unorderedEquals(['index.html', 'items/a.html', 'items/b.html']));
  });

  test('excludes soft-deleted items', () {
    final out = service.build(items: [
      _item(id: 'live'),
      _item(id: 'gone', deleted: true),
    ]);
    expect(out.keys, unorderedEquals(['index.html', 'items/live.html']));
  });

  test('excludes items tagged with the private tag', () {
    final out = service.build(items: [
      _item(id: 'visible'),
      _item(id: 'secret', tags: ['private']),
    ]);
    expect(out.keys, isNot(contains('items/secret.html')));
    expect(_asString(out['index.html']!), isNot(contains('secret')));
  });

  test('uses custom private tag when overridden', () {
    final out = service.build(
      items: [_item(id: 'a', tags: ['nsfw'])],
      options: const StaticExportOptions(privateTag: 'nsfw'),
    );
    expect(out.keys, ['index.html']);
  });

  test('HTML escapes item titles', () {
    final out = service.build(
      items: [_item(id: 'x', title: '<script>alert(1)</script>')],
    );
    final index = _asString(out['index.html']!);
    expect(index, isNot(contains('<script>alert(1)</script>')));
    expect(index, contains('&lt;script&gt;'));
  });

  test('references original coverUrl when not bundling', () {
    final out = service.build(
      items: [_item(id: 'a', coverUrl: 'https://example.com/a.jpg')],
    );
    expect(_asString(out['index.html']!),
        contains('https://example.com/a.jpg'));
  });

  test('rewrites cover path when bundling covers and the cover exists', () {
    final bytes = Uint8List.fromList(const [1, 2, 3]);
    final out = service.build(
      items: [_item(id: 'a', coverUrl: 'https://example.com/a.jpg?foo')],
      options: const StaticExportOptions(bundleCovers: true),
      covers: {'a.jpg': bytes},
    );
    expect(_asString(out['index.html']!), contains('covers/a.jpg'));
  });

  // Regression test for #104: a bundled-cover download can fail, leaving
  // the covers map without an entry for the item. The HTML must not
  // reference a covers/<id>.<ext> path that was never written.
  test('falls back to placeholder when a bundled cover is missing '
      '(failed download)', () {
    final out = service.build(
      items: [_item(id: 'a', coverUrl: 'https://example.com/a.jpg')],
      options: const StaticExportOptions(bundleCovers: true),
      // covers map intentionally empty: simulates a failed/skipped fetch.
    );

    final index = _asString(out['index.html']!);
    expect(index, isNot(contains('covers/a.jpg')));
    expect(index, contains('class="placeholder"'));

    final item = _asString(out['items/a.html']!);
    expect(item, isNot(contains('covers/a.jpg')));
    expect(item, contains('<div class="cover"></div>'));
  });

  test('media-type filter dropdown includes every present type', () {
    final out = service.build(items: [
      _item(id: 'a', mediaType: MediaType.film),
      _item(id: 'b', mediaType: MediaType.book),
    ]);
    final index = _asString(out['index.html']!);
    expect(index, contains('<option>Film</option>'));
    expect(index, contains('<option>Book</option>'));
  });

  test('tag dropdown excludes the private tag', () {
    final out = service.build(items: [
      _item(id: 'a', tags: ['favourite']),
      _item(id: 'b', tags: ['private', 'favourite']),
    ]);
    final index = _asString(out['index.html']!);
    expect(index, contains('<option>favourite</option>'));
    expect(index, isNot(contains('<option>private</option>')));
  });

  test('custom title appears in h1 and page title', () {
    final out = service.build(
      items: [_item(id: 'a')],
      options: const StaticExportOptions(title: 'Paul\'s library'),
    );
    final index = _asString(out['index.html']!);
    expect(index, contains('Paul&#39;s library'));
  });

  test('bundled cover for a visible item is written verbatim', () {
    final bytes = Uint8List.fromList(const [0x89, 0x50, 0x4e, 0x47]);
    final out = service.build(
      items: [_item(id: 'a', coverUrl: 'https://example.com/a.jpg')],
      options: const StaticExportOptions(bundleCovers: true),
      covers: {'a.jpg': bytes},
    );
    expect(out['covers/a.jpg'], bytes);
  });

  // Regression tests for #101: cover assets must respect the same
  // private/deleted exclusion that already applies to the HTML pages.
  group('excludes covers for hidden items (#101)', () {
    test('excludes covers for private-tagged items', () {
      final bytes = Uint8List.fromList(const [1, 2, 3]);
      final out = service.build(
        items: [
          _item(id: 'visible', coverUrl: 'https://example.com/visible.jpg'),
          _item(
            id: 'secret',
            coverUrl: 'https://example.com/secret.jpg',
            tags: ['private'],
          ),
        ],
        options: const StaticExportOptions(bundleCovers: true),
        covers: {
          'visible.jpg': bytes,
          'secret.jpg': bytes,
        },
      );
      expect(out.keys, contains('covers/visible.jpg'));
      expect(out.keys, isNot(contains('covers/secret.jpg')));
    });

    test('excludes covers for soft-deleted items', () {
      final bytes = Uint8List.fromList(const [1, 2, 3]);
      final out = service.build(
        items: [
          _item(id: 'live', coverUrl: 'https://example.com/live.jpg'),
          _item(
            id: 'gone',
            coverUrl: 'https://example.com/gone.jpg',
            deleted: true,
          ),
        ],
        options: const StaticExportOptions(bundleCovers: true),
        covers: {
          'live.jpg': bytes,
          'gone.jpg': bytes,
        },
      );
      expect(out.keys, contains('covers/live.jpg'));
      expect(out.keys, isNot(contains('covers/gone.jpg')));
    });

    test('respects a custom privateTag value', () {
      final bytes = Uint8List.fromList(const [1, 2, 3]);
      final out = service.build(
        items: [
          _item(
            id: 'a',
            coverUrl: 'https://example.com/a.jpg',
            tags: ['nsfw'],
          ),
        ],
        options:
            const StaticExportOptions(privateTag: 'nsfw', bundleCovers: true),
        covers: {'a.jpg': bytes},
      );
      expect(out.keys, isNot(contains('covers/a.jpg')));
    });
  });
}
