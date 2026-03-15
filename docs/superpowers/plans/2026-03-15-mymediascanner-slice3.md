# MyMediaScanner Slice 3: Collection CRUD

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the collection browsing screen with search, filter, sort, item detail screen with ratings and reviews, and edit metadata flow.

**Architecture:** CollectionProvider watches DAO streams with filter/sort state. ItemDetailScreen displays full metadata. Edit reuses EditableMetadataForm from Slice 2.

**Tech Stack:** Riverpod v3 codegen, GoRouter, cached_network_image

**Author:** Paul Snow

**Depends on:** Slices 1 and 2 complete

---

## File Structure (Slice 3)

```
lib/
  domain/
    usecases/
      get_collection_usecase.dart
      search_collection_usecase.dart
      delete_media_item_usecase.dart
      update_rating_usecase.dart
  presentation/
    providers/
      collection_provider.dart
    screens/
      collection/
        collection_screen.dart        (replace placeholder)
        collection_screen_controller.dart
        widgets/
          media_item_card.dart
          filter_bar.dart
          sort_selector.dart
      item_detail/
        item_detail_screen.dart
        item_detail_controller.dart
        widgets/
          cover_art_hero.dart
          star_rating_widget.dart
          metadata_section.dart
test/
  unit/
    domain/
      delete_media_item_usecase_test.dart
      update_rating_usecase_test.dart
  widget/
    presentation/
      star_rating_widget_test.dart
```

---

## Task 1: Use Cases with Tests

**Files:**
- Create: `lib/domain/usecases/get_collection_usecase.dart`
- Create: `lib/domain/usecases/search_collection_usecase.dart`
- Create: `lib/domain/usecases/delete_media_item_usecase.dart`
- Create: `lib/domain/usecases/update_rating_usecase.dart`
- Create: `test/unit/domain/delete_media_item_usecase_test.dart`
- Create: `test/unit/domain/update_rating_usecase_test.dart`

- [ ] **Step 1: Write delete_media_item_usecase_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/delete_media_item_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late DeleteMediaItemUseCase useCase;
  late MockMediaItemRepository mockRepo;

  setUp(() {
    mockRepo = MockMediaItemRepository();
    useCase = DeleteMediaItemUseCase(repository: mockRepo);
  });

  test('soft deletes item by id', () async {
    when(() => mockRepo.softDelete('item-1')).thenAnswer((_) async {});

    await useCase.execute('item-1');

    verify(() => mockRepo.softDelete('item-1')).called(1);
  });
}
```

- [ ] **Step 2: Create delete_media_item_usecase.dart**

```dart
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class DeleteMediaItemUseCase {
  const DeleteMediaItemUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  Future<void> execute(String id) => _repo.softDelete(id);
}
```

- [ ] **Step 3: Write update_rating_usecase_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';
import 'package:mymediascanner/domain/usecases/update_rating_usecase.dart';

class MockMediaItemRepository extends Mock implements IMediaItemRepository {}

void main() {
  late UpdateRatingUseCase useCase;
  late MockMediaItemRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(MediaItem(
      id: '', barcode: '', barcodeType: '', mediaType: MediaType.unknown,
      title: '', dateAdded: 0, dateScanned: 0, updatedAt: 0,
    ));
  });

  setUp(() {
    mockRepo = MockMediaItemRepository();
    useCase = UpdateRatingUseCase(repository: mockRepo);
  });

  test('updates item rating and review', () async {
    final item = MediaItem(
      id: 'item-1', barcode: '123', barcodeType: 'ean13',
      mediaType: MediaType.film, title: 'Test',
      dateAdded: 1000, dateScanned: 1000, updatedAt: 1000,
    );

    when(() => mockRepo.getById('item-1')).thenAnswer((_) async => item);
    when(() => mockRepo.update(any())).thenAnswer((_) async {});

    await useCase.execute('item-1', rating: 4.5, review: 'Great film');

    final captured = verify(() => mockRepo.update(captureAny())).captured;
    final updated = captured.first as MediaItem;
    expect(updated.userRating, 4.5);
    expect(updated.userReview, 'Great film');
  });
}
```

- [ ] **Step 4: Create update_rating_usecase.dart**

```dart
import 'package:mymediascanner/core/errors/app_exception.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class UpdateRatingUseCase {
  const UpdateRatingUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  Future<void> execute(
    String itemId, {
    double? rating,
    String? review,
  }) async {
    final item = await _repo.getById(itemId);
    if (item == null) throw const DatabaseException('Item not found');

    final now = DateTime.now().millisecondsSinceEpoch;
    await _repo.update(item.copyWith(
      userRating: rating ?? item.userRating,
      userReview: review ?? item.userReview,
      updatedAt: now,
    ));
  }
}
```

- [ ] **Step 5: Create get_collection_usecase.dart**

```dart
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class GetCollectionUseCase {
  const GetCollectionUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  Stream<List<MediaItem>> execute({
    MediaType? mediaType,
    String? searchQuery,
    List<String>? tagIds,
    String? sortBy,
    bool ascending = true,
  }) {
    return _repo.watchAll(
      mediaType: mediaType,
      searchQuery: searchQuery,
      tagIds: tagIds,
      sortBy: sortBy,
      ascending: ascending,
    );
  }
}
```

- [ ] **Step 6: Create search_collection_usecase.dart**

```dart
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/repositories/i_media_item_repository.dart';

class SearchCollectionUseCase {
  const SearchCollectionUseCase({required IMediaItemRepository repository})
      : _repo = repository;

  final IMediaItemRepository _repo;

  Stream<List<MediaItem>> execute(String query) {
    return _repo.watchAll(searchQuery: query);
  }
}
```

- [ ] **Step 7: Run tests and commit**

```bash
flutter test test/unit/domain/
git add lib/domain/usecases/ test/unit/domain/
git commit -m "feat: add collection use cases with tests"
```

---

## Task 2: Collection Provider

**Files:**
- Create: `lib/presentation/providers/collection_provider.dart`

- [ ] **Step 1: Create collection_provider.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/usecases/get_collection_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

part 'collection_provider.g.dart';

@riverpod
class CollectionFilter extends _$CollectionFilter {
  @override
  ({MediaType? mediaType, String? search, String? sortBy, bool ascending}) build() {
    return (mediaType: null, search: null, sortBy: 'dateAdded', ascending: false);
  }

  void setMediaType(MediaType? type) {
    state = (
      mediaType: type,
      search: state.search,
      sortBy: state.sortBy,
      ascending: state.ascending,
    );
  }

  void setSearch(String? query) {
    state = (
      mediaType: state.mediaType,
      search: query?.isEmpty == true ? null : query,
      sortBy: state.sortBy,
      ascending: state.ascending,
    );
  }

  void setSort(String sortBy, {bool? ascending}) {
    state = (
      mediaType: state.mediaType,
      search: state.search,
      sortBy: sortBy,
      ascending: ascending ?? state.ascending,
    );
  }
}

@riverpod
Stream<List<MediaItem>> collection(Ref ref) {
  final filter = ref.watch(collectionFilterProvider);
  final useCase = GetCollectionUseCase(
    repository: ref.watch(mediaItemRepositoryProvider),
  );
  return useCase.execute(
    mediaType: filter.mediaType,
    searchQuery: filter.search,
    sortBy: filter.sortBy,
    ascending: filter.ascending,
  );
}
```

- [ ] **Step 2: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/presentation/providers/collection_provider.dart
git commit -m "feat: add collection filter and stream provider"
```

---

## Task 3: Collection Widgets

**Files:**
- Create: `lib/presentation/screens/collection/widgets/media_item_card.dart`
- Create: `lib/presentation/screens/collection/widgets/filter_bar.dart`
- Create: `lib/presentation/screens/collection/widgets/sort_selector.dart`

- [ ] **Step 1: Create media_item_card.dart**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_colors.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

class MediaItemCard extends StatelessWidget {
  const MediaItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MediaItem item;
  final VoidCallback onTap;

  Color _typeColour(MediaType type) => switch (type) {
        MediaType.film => AppColors.filmColor,
        MediaType.tv => AppColors.tvColor,
        MediaType.music => AppColors.musicColor,
        MediaType.book => AppColors.bookColor,
        MediaType.game => AppColors.gameColor,
        MediaType.unknown => AppColors.unknownColor,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: item.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 48),
                    )
                  : Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _typeColour(item.mediaType),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.mediaType.label,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                      if (item.userRating != null) ...[
                        const Spacer(),
                        Icon(Icons.star, size: 14,
                            color: Colors.amber.shade700),
                        const SizedBox(width: 2),
                        Text(item.userRating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (item.year != null)
                    Text(
                      '${item.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create filter_bar.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(collectionFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.mediaType == null,
            onSelected: (_) =>
                ref.read(collectionFilterProvider.notifier).setMediaType(null),
          ),
          const SizedBox(width: 8),
          ...MediaType.values
              .where((t) => t != MediaType.unknown)
              .map((type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.label),
                      selected: filter.mediaType == type,
                      onSelected: (_) => ref
                          .read(collectionFilterProvider.notifier)
                          .setMediaType(
                              filter.mediaType == type ? null : type),
                    ),
                  )),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create sort_selector.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';

class SortSelector extends ConsumerWidget {
  const SortSelector({super.key});

  static const _options = {
    'dateAdded': 'Date Added',
    'title': 'Title',
    'year': 'Year',
    'userRating': 'Rating',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(collectionFilterProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: filter.sortBy,
          underline: const SizedBox.shrink(),
          items: _options.entries
              .map((e) =>
                  DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(collectionFilterProvider.notifier).setSort(value);
            }
          },
        ),
        IconButton(
          icon: Icon(filter.ascending
              ? Icons.arrow_upward
              : Icons.arrow_downward),
          onPressed: () => ref
              .read(collectionFilterProvider.notifier)
              .setSort(filter.sortBy ?? 'dateAdded',
                  ascending: !filter.ascending),
          tooltip: filter.ascending ? 'Ascending' : 'Descending',
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/collection/widgets/
git commit -m "feat: add collection widgets — card, filter bar, sort selector"
```

---

## Task 4: Collection Screen

**Files:**
- Modify: `lib/presentation/screens/collection/collection_screen.dart`

- [ ] **Step 1: Replace collection_screen.dart placeholder**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/collection_provider.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/filter_bar.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/media_item_card.dart';
import 'package:mymediascanner/presentation/screens/collection/widgets/sort_selector.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: const [SortSelector()],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: FilterBar(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              hintText: 'Search collection...',
              leading: const Icon(Icons.search),
              onChanged: (query) =>
                  ref.read(collectionFilterProvider.notifier).setSearch(query),
            ),
          ),
          Expanded(
            child: collectionAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(collectionProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    message: 'No items yet. Scan a barcode to get started!',
                    icon: Icons.library_music_outlined,
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => MediaItemCard(
                    item: items[index],
                    onTap: () => context.go('/item/${items[index].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/collection/collection_screen.dart
git commit -m "feat: implement collection screen with search, filter, sort"
```

---

## Task 5: Item Detail Widgets

**Files:**
- Create: `lib/presentation/screens/item_detail/widgets/cover_art_hero.dart`
- Create: `lib/presentation/screens/item_detail/widgets/star_rating_widget.dart`
- Create: `lib/presentation/screens/item_detail/widgets/metadata_section.dart`
- Create: `test/widget/presentation/star_rating_widget_test.dart`

- [ ] **Step 1: Create cover_art_hero.dart**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CoverArtHero extends StatelessWidget {
  const CoverArtHero({super.key, required this.imageUrl, required this.tag});

  final String? imageUrl;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              height: 300,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 100),
            )
          : Container(
              height: 300,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported, size: 100),
            ),
    );
  }
}
```

- [ ] **Step 2: Write star_rating_widget_test.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/star_rating_widget.dart';

void main() {
  group('StarRatingWidget', () {
    testWidgets('displays 5 stars', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRatingWidget(rating: 3.0, onChanged: (_) {}),
        ),
      ));
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('tapping star calls onChanged', (tester) async {
      double? tappedRating;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRatingWidget(
              rating: 0, onChanged: (r) => tappedRating = r),
        ),
      ));
      await tester.tap(find.byIcon(Icons.star_border).first);
      expect(tappedRating, 1.0);
    });
  });
}
```

- [ ] **Step 3: Create star_rating_widget.dart**

```dart
import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 32,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () => onChanged(starValue),
          child: Icon(
            starValue <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber.shade700,
            size: size,
            semanticLabel: 'Rate $starValue stars',
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 4: Run widget test**

```bash
flutter test test/widget/presentation/star_rating_widget_test.dart
```

Expected: All PASS.

- [ ] **Step 5: Create metadata_section.dart**

```dart
import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

class MetadataSection extends StatelessWidget {
  const MetadataSection({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extra = item.extraMetadata;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.description != null) ...[
          Text('Description', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(item.description!),
          const SizedBox(height: 16),
        ],
        _row('Format', item.format),
        _row('Publisher', item.publisher),
        _row('Year', item.year?.toString()),
        _row('Barcode', '${item.barcode} (${item.barcodeType})'),
        if (item.genres.isNotEmpty)
          _row('Genres', item.genres.join(', ')),

        // Type-specific fields
        if (item.mediaType == MediaType.film ||
            item.mediaType == MediaType.tv) ...[
          _row('Director', extra['director'] as String?),
          _row('Runtime', extra['runtime_minutes'] != null
              ? '${extra['runtime_minutes']} min'
              : null),
        ],
        if (item.mediaType == MediaType.music) ...[
          _row('Artist', (extra['artists'] as List?)?.join(', ')),
          _row('Label', extra['label'] as String?),
        ],
        if (item.mediaType == MediaType.book) ...[
          _row('Author', (extra['authors'] as List?)?.join(', ')),
          _row('Pages', extra['page_count']?.toString()),
          _row('ISBN', extra['isbn13'] as String? ?? extra['isbn10'] as String?),
        ],
      ],
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/item_detail/widgets/ test/widget/
git commit -m "feat: add item detail widgets with star rating test"
```

---

## Task 6: Item Detail Screen

**Files:**
- Create: `lib/presentation/screens/item_detail/item_detail_screen.dart`
- Create: `lib/presentation/providers/metadata_provider.dart`

- [ ] **Step 1: Create metadata_provider.dart (item detail provider)**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

part 'metadata_provider.g.dart';

@riverpod
Future<MediaItem?> mediaItem(Ref ref, String id) async {
  return ref.watch(mediaItemRepositoryProvider).getById(id);
}
```

- [ ] **Step 2: Create item_detail_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/usecases/delete_media_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/update_rating_usecase.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/cover_art_hero.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/metadata_section.dart';
import 'package:mymediascanner/presentation/screens/item_detail/widgets/star_rating_widget.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(mediaItemProvider(itemId));

    return itemAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (e, _) => Scaffold(body: ErrorState(message: e.toString())),
      data: (item) {
        if (item == null) {
          return const Scaffold(body: ErrorState(message: 'Item not found'));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(item.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.go('/item/${item.id}/edit'),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref),
                tooltip: 'Delete',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CoverArtHero(
                      imageUrl: item.coverUrl, tag: 'cover-${item.id}'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(item.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                if (item.subtitle != null)
                  Center(
                    child: Text(item.subtitle!,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: StarRatingWidget(
                    rating: item.userRating ?? 0,
                    onChanged: (rating) {
                      UpdateRatingUseCase(
                              repository:
                                  ref.read(mediaItemRepositoryProvider))
                          .execute(item.id, rating: rating);
                      ref.invalidate(mediaItemProvider(itemId));
                    },
                  ),
                ),
                if (item.userReview != null && item.userReview!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(item.userReview!),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                MetadataSection(item: item),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This item will be removed from your collection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await DeleteMediaItemUseCase(
                      repository: ref.read(mediaItemRepositoryProvider))
                  .execute(itemId);
              if (context.mounted) {
                Navigator.pop(ctx);
                context.go('/');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Update router.dart — replace item detail placeholder**

Update the `/item/:id` route builder to:

```dart
builder: (context, state) => ItemDetailScreen(
  itemId: state.pathParameters['id']!,
),
```

And the `/item/:id/edit` route to use EditableMetadataForm (reusing from Slice 2, pre-populated with existing data — full edit screen implementation in a later task).

- [ ] **Step 4: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/presentation/screens/item_detail/ lib/presentation/providers/metadata_provider.dart lib/app/router.dart
git commit -m "feat: add item detail screen with rating, metadata, delete"
```

---

## Task 7: Verify Slice 3

- [ ] **Step 1: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 2: Run analysis**

```bash
flutter analyze
```

- [ ] **Step 3: Run all tests**

```bash
flutter test
```

- [ ] **Step 4: Run app on macOS**

```bash
flutter run -d macos
```

Expected: Collection tab shows grid with filter/sort. Scanning a barcode → confirming → saving shows the item in the collection. Tapping an item opens detail with cover, metadata, star rating.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: complete Slice 3 — collection CRUD with detail screen"
```
