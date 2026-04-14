// Integration-style widget test: purchase info edits persist via the
// media item repository, mirroring the wiring in ItemDetailScreen.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/domain/entities/item_condition.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/purchase_info_section.dart';

class _FakeMediaItemRepository implements IMediaItemRepository {
  MediaItem? lastUpdated;

  @override
  Future<void> update(MediaItem item) async {
    lastUpdated = item;
  }

  // Unused by this test — throw to catch any accidental calls.
  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _HarnessWidget extends ConsumerStatefulWidget {
  const _HarnessWidget({required this.initial});

  final MediaItem initial;

  @override
  ConsumerState<_HarnessWidget> createState() => _HarnessWidgetState();
}

class _HarnessWidgetState extends ConsumerState<_HarnessWidget> {
  late MediaItem _item = widget.initial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PurchaseInfoSection(
          item: _item,
          onChanged: (updated) async {
            setState(() => _item = updated);
            await ref
                .read(mediaItemRepositoryProvider)
                .update(updated.copyWith(
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                ));
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'editing condition persists through media item repository',
    (tester) async {
      final fake = _FakeMediaItemRepository();
      final item = MediaItem(
        id: 'i1',
        barcode: '123',
        barcodeType: 'ean13',
        mediaType: MediaType.film,
        title: 'Test',
        dateAdded: 0,
        dateScanned: 0,
        updatedAt: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaItemRepositoryProvider.overrideWithValue(fake),
          ],
          child: _HarnessWidget(initial: item),
        ),
      );

      await tester.tap(find.byKey(const Key('condition-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Good').last);
      await tester.pumpAndSettle();

      expect(fake.lastUpdated?.condition, ItemCondition.good);
    },
  );
}
