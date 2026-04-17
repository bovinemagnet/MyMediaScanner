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

  test('rewrites cover path when bundling covers', () {
    final out = service.build(
      items: [_item(id: 'a', coverUrl: 'https://example.com/a.jpg?foo')],
      options: const StaticExportOptions(bundleCovers: true),
    );
    expect(_asString(out['index.html']!), contains('covers/a.jpg'));
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

  test('bundled covers map writes to covers/<key> verbatim', () {
    final bytes = Uint8List.fromList(const [0x89, 0x50, 0x4e, 0x47]);
    final out = service.build(
      items: const [],
      options: const StaticExportOptions(bundleCovers: true),
      covers: {'a.jpg': bytes},
    );
    expect(out['covers/a.jpg'], bytes);
  });
}
