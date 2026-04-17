import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/data/services/static_export_writer.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/services/static_export_service.dart';
import 'package:path/path.dart' as p;

class MockDio extends Mock implements Dio {}

MediaItem _item({
  required String id,
  String title = 'Title',
  String? coverUrl,
  MediaType mediaType = MediaType.film,
}) =>
    MediaItem(
      id: id,
      barcode: id,
      barcodeType: 'EAN13',
      mediaType: mediaType,
      title: title,
      coverUrl: coverUrl,
      extraMetadata: const {},
      dateAdded: 0,
      dateScanned: 0,
      updatedAt: 0,
    );

Response<List<int>> _bytesResponse(List<int> bytes, String url) => Response(
      requestOptions: RequestOptions(path: url),
      data: bytes,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mms_export_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('writes index.html and per-item pages to disk', () async {
    final writer = StaticExportWriter(dio: MockDio());
    final indexPath = await writer.write(
      targetDir: tempDir,
      items: [_item(id: 'a'), _item(id: 'b')],
    );

    expect(indexPath, p.join(tempDir.path, 'index.html'));
    expect(await File(indexPath).exists(), isTrue);
    expect(await File(p.join(tempDir.path, 'items', 'a.html')).exists(),
        isTrue);
    expect(await File(p.join(tempDir.path, 'items', 'b.html')).exists(),
        isTrue);
  });

  test('creates the target directory if it does not exist', () async {
    final nested = Directory(p.join(tempDir.path, 'new', 'export'));
    final writer = StaticExportWriter(dio: MockDio());

    await writer.write(targetDir: nested, items: [_item(id: 'x')]);

    expect(await nested.exists(), isTrue);
    expect(await File(p.join(nested.path, 'index.html')).exists(), isTrue);
  });

  test('does not invoke Dio when bundleCovers is false', () async {
    final dio = MockDio();
    final writer = StaticExportWriter(dio: dio);

    await writer.write(
      targetDir: tempDir,
      items: [_item(id: 'a', coverUrl: 'https://example.com/a.jpg')],
    );

    verifyNever(() => dio.get<List<int>>(any(),
        options: any(named: 'options')));
  });

  test('fetches covers and writes them under covers/ when bundling',
      () async {
    final dio = MockDio();
    final bytes = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
    when(() => dio.get<List<int>>(
          'https://example.com/a.png',
          options: any(named: 'options'),
        )).thenAnswer((_) async =>
        _bytesResponse(bytes, 'https://example.com/a.png'));

    final writer = StaticExportWriter(dio: dio);
    await writer.write(
      targetDir: tempDir,
      items: [_item(id: 'a', coverUrl: 'https://example.com/a.png')],
      options: const StaticExportOptions(bundleCovers: true),
    );

    final coverFile = File(p.join(tempDir.path, 'covers', 'a.png'));
    expect(await coverFile.exists(), isTrue);
    expect(await coverFile.readAsBytes(), Uint8List.fromList(bytes));
  });

  test('skips covers when the download fails', () async {
    final dio = MockDio();
    when(() => dio.get<List<int>>(
          any(),
          options: any(named: 'options'),
        )).thenThrow(DioException(
      requestOptions: RequestOptions(path: ''),
      type: DioExceptionType.connectionError,
    ));

    final writer = StaticExportWriter(dio: dio);
    await writer.write(
      targetDir: tempDir,
      items: [_item(id: 'a', coverUrl: 'https://example.com/a.jpg')],
      options: const StaticExportOptions(bundleCovers: true),
    );

    final coverDir = Directory(p.join(tempDir.path, 'covers'));
    if (await coverDir.exists()) {
      expect(await coverDir.list().toList(), isEmpty);
    }
    // Export itself still succeeds.
    expect(await File(p.join(tempDir.path, 'index.html')).exists(), isTrue);
  });

  test('reports progress for write phase', () async {
    final writer = StaticExportWriter(dio: MockDio());
    final progress = <(int, int)>[];

    await writer.write(
      targetDir: tempDir,
      items: [_item(id: 'a'), _item(id: 'b')],
      onProgress: (done, total) => progress.add((done, total)),
    );

    expect(progress, isNotEmpty);
    final last = progress.last;
    expect(last.$1, last.$2, reason: 'final done == total');
    expect(last.$1, greaterThanOrEqualTo(3),
        reason: 'index + 2 item pages at minimum');
  });

  test('skips items without coverUrl when fetching covers', () async {
    final dio = MockDio();
    when(() => dio.get<List<int>>(
          'https://example.com/b.jpg',
          options: any(named: 'options'),
        )).thenAnswer((_) async =>
        _bytesResponse([1, 2, 3], 'https://example.com/b.jpg'));

    final writer = StaticExportWriter(dio: dio);
    await writer.write(
      targetDir: tempDir,
      items: [
        _item(id: 'a'),
        _item(id: 'b', coverUrl: 'https://example.com/b.jpg'),
      ],
      options: const StaticExportOptions(bundleCovers: true),
    );

    verify(() => dio.get<List<int>>(
          'https://example.com/b.jpg',
          options: any(named: 'options'),
        )).called(1);
    verifyNoMoreInteractions(dio);
  });
}
