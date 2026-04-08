import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/data/mappers/batch_item_mapper.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_candidate.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/domain/entities/scan_result.dart';
import 'package:mymediascanner/presentation/providers/batch_editor_provider.dart';

void main() {
  group('BatchItemMapper', () {
    test('round-trips a confirmed BatchItem with metadata', () {
      final item = BatchItem(
        id: 'test-id-1',
        barcode: '1234567890',
        barcodeType: 'EAN-13',
        scannedAt: DateTime(2026, 4, 7, 12, 0),
        status: BatchItemStatus.confirmed,
        metadata: const MetadataResult(
          barcode: '1234567890',
          barcodeType: 'EAN-13',
          title: 'Test Album',
          subtitle: 'Test Artist',
          mediaType: MediaType.music,
          genres: ['Rock', 'Alternative'],
          sourceApis: ['discogs'],
          year: 2024,
          publisher: 'Test Label',
        ),
        scanResult: const ScanResult.single(
          metadata: MetadataResult(
            barcode: '1234567890',
            barcodeType: 'EAN-13',
            title: 'Test Album',
            mediaType: MediaType.music,
          ),
          isDuplicate: false,
        ),
      );

      // Convert to companion.
      final companion = batchItemToCompanion(item, 'session-1', 0);

      // Verify the companion has the right values.
      expect(companion.id.value, 'test-id-1');
      expect(companion.sessionId.value, 'session-1');
      expect(companion.barcode.value, '1234567890');
      expect(companion.status.value, 'confirmed');
      expect(companion.metadataJson.value, isNotNull);
      expect(companion.scanResultJson.value, isNotNull);
    });

    test('round-trips a conflict BatchItem with MultiMatchScanResult', () {
      final item = BatchItem(
        id: 'test-id-2',
        barcode: '9876543210',
        barcodeType: 'UPC-A',
        scannedAt: DateTime(2026, 4, 7, 12, 30),
        status: BatchItemStatus.conflict,
        scanResult: const ScanResult.multiMatch(
          barcode: '9876543210',
          barcodeType: 'UPC-A',
          candidates: [
            MetadataCandidate(
              sourceApi: 'discogs',
              sourceId: '123',
              title: 'Option A',
              year: 2020,
              mediaType: MediaType.music,
            ),
            MetadataCandidate(
              sourceApi: 'discogs',
              sourceId: '456',
              title: 'Option B',
              subtitle: 'Deluxe Edition',
              coverUrl: 'https://example.com/cover.jpg',
            ),
          ],
        ),
      );

      final companion = batchItemToCompanion(item, 'session-1', 1);
      expect(companion.metadataJson.value, isNull);
      expect(companion.scanResultJson.value, isNotNull);
    });

    test('round-trips a notFound BatchItem', () {
      final item = BatchItem(
        id: 'test-id-3',
        barcode: '0000000000',
        barcodeType: 'EAN-13',
        scannedAt: DateTime(2026, 4, 7, 13, 0),
        status: BatchItemStatus.notFound,
        scanResult: const ScanResult.notFound(
          barcode: '0000000000',
          barcodeType: 'EAN-13',
        ),
      );

      final companion = batchItemToCompanion(item, 'session-1', 2);
      expect(companion.metadataJson.value, isNull);
      expect(companion.scanResultJson.value, isNotNull);
    });
  });
}
