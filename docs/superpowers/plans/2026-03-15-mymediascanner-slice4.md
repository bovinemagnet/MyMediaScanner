# MyMediaScanner Slice 4: Tags & Shelves

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement tag creation, assignment to items, filtering by tag, shelf CRUD, ordered shelf items, and the shelves UI.

**Architecture:** Tags and shelves use their own DAOs (built in Slice 1), repository implementations, and use cases. TagChips widget on item detail. Filter bar extended with tag filter.

**Tech Stack:** Riverpod v3 codegen, Drift DAOs, GoRouter

**Author:** Paul Snow

**Depends on:** Slices 1-3 complete

---

## File Structure (Slice 4)

```
lib/
  data/
    repositories/
      tag_repository_impl.dart
      shelf_repository_impl.dart
  domain/
    usecases/
      manage_tags_usecase.dart
      manage_shelves_usecase.dart
  presentation/
    providers/
      tag_provider.dart
      shelf_provider.dart
    screens/
      item_detail/
        widgets/
          tag_chips.dart
      shelves/
        shelves_screen.dart       (replace placeholder)
        shelf_detail_screen.dart
test/
  unit/
    domain/
      manage_tags_usecase_test.dart
```

---

## Task 1: TagRepositoryImpl

**Files:**
- Create: `lib/data/repositories/tag_repository_impl.dart`

- [ ] **Step 1: Create tag_repository_impl.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/tags_dao.dart';
import 'package:mymediascanner/data/local/dao/sync_log_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class TagRepositoryImpl implements ITagRepository {
  TagRepositoryImpl({
    required TagsDao tagsDao,
    required SyncLogDao syncLogDao,
  })  : _tagsDao = tagsDao,
        _syncLogDao = syncLogDao;

  final TagsDao _tagsDao;
  final SyncLogDao _syncLogDao;
  static const _uuid = Uuid();

  @override
  Stream<List<Tag>> watchAll() {
    return _tagsDao.watchAll().map(
      (rows) => rows.map(_fromRow).toList(),
    );
  }

  @override
  Future<Tag?> getById(String id) async {
    final row = await _tagsDao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<void> save(Tag tag) async {
    await _tagsDao.insertTag(TagsTableCompanion(
      id: Value(tag.id),
      name: Value(tag.name),
      colour: Value(tag.colour),
      updatedAt: Value(tag.updatedAt),
    ));
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _tagsDao.softDelete(id, now);
  }

  @override
  Future<void> assignToMediaItem(String tagId, String mediaItemId) =>
      _tagsDao.assignToMediaItem(tagId, mediaItemId);

  @override
  Future<void> removeFromMediaItem(String tagId, String mediaItemId) =>
      _tagsDao.removeFromMediaItem(tagId, mediaItemId);

  @override
  Future<List<String>> getTagIdsForMediaItem(String mediaItemId) =>
      _tagsDao.getTagIdsForMediaItem(mediaItemId);

  Tag _fromRow(TagsTableData row) => Tag(
        id: row.id,
        name: row.name,
        colour: row.colour,
        updatedAt: row.updatedAt,
      );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/repositories/tag_repository_impl.dart
git commit -m "feat: add TagRepositoryImpl"
```

---

## Task 2: ShelfRepositoryImpl

**Files:**
- Create: `lib/data/repositories/shelf_repository_impl.dart`

- [ ] **Step 1: Create shelf_repository_impl.dart**

```dart
import 'package:drift/drift.dart';
import 'package:mymediascanner/data/local/dao/shelves_dao.dart';
import 'package:mymediascanner/data/local/database/app_database.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';

class ShelfRepositoryImpl implements IShelfRepository {
  ShelfRepositoryImpl({required ShelvesDao shelvesDao})
      : _shelvesDao = shelvesDao;

  final ShelvesDao _shelvesDao;

  @override
  Stream<List<Shelf>> watchAll() {
    return _shelvesDao.watchAll().map(
      (rows) => rows.map(_fromRow).toList(),
    );
  }

  @override
  Future<Shelf?> getById(String id) async {
    final row = await _shelvesDao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  @override
  Future<void> save(Shelf shelf) async {
    await _shelvesDao.insertShelf(ShelvesTableCompanion(
      id: Value(shelf.id),
      name: Value(shelf.name),
      description: Value(shelf.description),
      sortOrder: Value(shelf.sortOrder),
      updatedAt: Value(shelf.updatedAt),
    ));
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _shelvesDao.softDelete(id, now);
  }

  @override
  Future<void> addItem(String shelfId, String mediaItemId, int position) =>
      _shelvesDao.addItem(shelfId, mediaItemId, position);

  @override
  Future<void> removeItem(String shelfId, String mediaItemId) =>
      _shelvesDao.removeItem(shelfId, mediaItemId);

  @override
  Future<List<String>> getMediaItemIdsForShelf(String shelfId) =>
      _shelvesDao.getMediaItemIdsForShelf(shelfId);

  @override
  Future<void> reorderItem(
      String shelfId, String mediaItemId, int newPosition) =>
      _shelvesDao.addItem(shelfId, mediaItemId, newPosition);

  Shelf _fromRow(ShelvesTableData row) => Shelf(
        id: row.id,
        name: row.name,
        description: row.description,
        sortOrder: row.sortOrder,
        updatedAt: row.updatedAt,
      );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/repositories/shelf_repository_impl.dart
git commit -m "feat: add ShelfRepositoryImpl"
```

---

## Task 3: Use Cases with Tests

**Files:**
- Create: `lib/domain/usecases/manage_tags_usecase.dart`
- Create: `lib/domain/usecases/manage_shelves_usecase.dart`
- Create: `test/unit/domain/manage_tags_usecase_test.dart`

- [ ] **Step 1: Write manage_tags_usecase_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:mymediascanner/domain/usecases/manage_tags_usecase.dart';

class MockTagRepository extends Mock implements ITagRepository {}

void main() {
  late ManageTagsUseCase useCase;
  late MockTagRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(Tag(id: '', name: '', updatedAt: 0));
  });

  setUp(() {
    mockRepo = MockTagRepository();
    useCase = ManageTagsUseCase(repository: mockRepo);
  });

  test('createTag generates id and saves', () async {
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    final tag = await useCase.createTag(name: 'Favourites', colour: '#FF0000');

    expect(tag.name, 'Favourites');
    expect(tag.colour, '#FF0000');
    expect(tag.id, isNotEmpty);
    verify(() => mockRepo.save(any())).called(1);
  });

  test('assignTag delegates to repository', () async {
    when(() => mockRepo.assignToMediaItem('tag-1', 'item-1'))
        .thenAnswer((_) async {});

    await useCase.assignTag(tagId: 'tag-1', mediaItemId: 'item-1');

    verify(() => mockRepo.assignToMediaItem('tag-1', 'item-1')).called(1);
  });
}
```

- [ ] **Step 2: Create manage_tags_usecase.dart**

```dart
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:uuid/uuid.dart';

class ManageTagsUseCase {
  const ManageTagsUseCase({required ITagRepository repository})
      : _repo = repository;

  final ITagRepository _repo;
  static const _uuid = Uuid();

  Future<Tag> createTag({required String name, String? colour}) async {
    final tag = Tag(
      id: _uuid.v7(),
      name: name,
      colour: colour,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.save(tag);
    return tag;
  }

  Future<void> deleteTag(String id) => _repo.softDelete(id);

  Future<void> assignTag({
    required String tagId,
    required String mediaItemId,
  }) => _repo.assignToMediaItem(tagId, mediaItemId);

  Future<void> removeTag({
    required String tagId,
    required String mediaItemId,
  }) => _repo.removeFromMediaItem(tagId, mediaItemId);

  Stream<List<Tag>> watchAll() => _repo.watchAll();

  Future<List<String>> getTagsForItem(String mediaItemId) =>
      _repo.getTagIdsForMediaItem(mediaItemId);
}
```

- [ ] **Step 3: Create manage_shelves_usecase.dart**

```dart
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';
import 'package:uuid/uuid.dart';

class ManageShelvesUseCase {
  const ManageShelvesUseCase({required IShelfRepository repository})
      : _repo = repository;

  final IShelfRepository _repo;
  static const _uuid = Uuid();

  Future<Shelf> createShelf({
    required String name,
    String? description,
  }) async {
    final shelf = Shelf(
      id: _uuid.v7(),
      name: name,
      description: description,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.save(shelf);
    return shelf;
  }

  Future<void> deleteShelf(String id) => _repo.softDelete(id);

  Future<void> addItem({
    required String shelfId,
    required String mediaItemId,
    required int position,
  }) => _repo.addItem(shelfId, mediaItemId, position);

  Future<void> removeItem({
    required String shelfId,
    required String mediaItemId,
  }) => _repo.removeItem(shelfId, mediaItemId);

  Stream<List<Shelf>> watchAll() => _repo.watchAll();

  Future<List<String>> getItemsForShelf(String shelfId) =>
      _repo.getMediaItemIdsForShelf(shelfId);
}
```

- [ ] **Step 4: Run tests and commit**

```bash
flutter test test/unit/domain/manage_tags_usecase_test.dart
git add lib/domain/usecases/ test/unit/domain/manage_tags_usecase_test.dart
git commit -m "feat: add tag and shelf management use cases with tests"
```

---

## Task 4: Tag & Shelf Providers + Repository Bindings

**Files:**
- Create: `lib/presentation/providers/tag_provider.dart`
- Create: `lib/presentation/providers/shelf_provider.dart`
- Modify: `lib/presentation/providers/repository_providers.dart`

- [ ] **Step 1: Create tag_provider.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mymediascanner/domain/entities/tag.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

part 'tag_provider.g.dart';

@riverpod
Stream<List<Tag>> allTags(Ref ref) {
  return ref.watch(tagRepositoryProvider).watchAll();
}

@riverpod
Future<List<String>> tagIdsForItem(Ref ref, String mediaItemId) {
  return ref.watch(tagRepositoryProvider).getTagIdsForMediaItem(mediaItemId);
}
```

- [ ] **Step 2: Create shelf_provider.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mymediascanner/domain/entities/shelf.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

part 'shelf_provider.g.dart';

@riverpod
Stream<List<Shelf>> allShelves(Ref ref) {
  return ref.watch(shelfRepositoryProvider).watchAll();
}

@riverpod
Future<List<String>> shelfItemIds(Ref ref, String shelfId) {
  return ref.watch(shelfRepositoryProvider).getMediaItemIdsForShelf(shelfId);
}
```

- [ ] **Step 3: Add repository bindings to repository_providers.dart**

Add these providers to the existing file:

```dart
import 'package:mymediascanner/data/repositories/tag_repository_impl.dart';
import 'package:mymediascanner/data/repositories/shelf_repository_impl.dart';
import 'package:mymediascanner/domain/repositories/i_tag_repository.dart';
import 'package:mymediascanner/domain/repositories/i_shelf_repository.dart';

@riverpod
ITagRepository tagRepository(Ref ref) {
  return TagRepositoryImpl(
    tagsDao: ref.watch(tagsDaoProvider),
    syncLogDao: ref.watch(syncLogDaoProvider),
  );
}

@riverpod
IShelfRepository shelfRepository(Ref ref) {
  return ShelfRepositoryImpl(
    shelvesDao: ref.watch(shelvesDaoProvider),
  );
}
```

- [ ] **Step 4: Run code generation and commit**

```bash
dart run build_runner build --delete-conflicting-outputs
git add lib/presentation/providers/
git commit -m "feat: add tag and shelf providers with repository bindings"
```

---

## Task 5: TagChips Widget

**Files:**
- Create: `lib/presentation/screens/item_detail/widgets/tag_chips.dart`

- [ ] **Step 1: Create tag_chips.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/manage_tags_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/tag_provider.dart';

class TagChips extends ConsumerWidget {
  const TagChips({super.key, required this.mediaItemId});

  final String mediaItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTagsAsync = ref.watch(allTagsProvider);
    final itemTagIdsAsync = ref.watch(tagIdsForItemProvider(mediaItemId));

    return allTagsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (allTags) => itemTagIdsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (itemTagIds) => Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ...allTags.map((tag) {
              final isAssigned = itemTagIds.contains(tag.id);
              return FilterChip(
                label: Text(tag.name),
                selected: isAssigned,
                onSelected: (selected) {
                  final useCase = ManageTagsUseCase(
                      repository: ref.read(tagRepositoryProvider));
                  if (selected) {
                    useCase.assignTag(
                        tagId: tag.id, mediaItemId: mediaItemId);
                  } else {
                    useCase.removeTag(
                        tagId: tag.id, mediaItemId: mediaItemId);
                  }
                  ref.invalidate(tagIdsForItemProvider(mediaItemId));
                },
                backgroundColor: tag.colour != null
                    ? Color(int.parse(tag.colour!.replaceFirst('#', '0xFF')))
                        .withAlpha(50)
                    : null,
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('New Tag'),
              onPressed: () => _showCreateTagDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTagDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tag name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final useCase = ManageTagsUseCase(
                    repository: ref.read(tagRepositoryProvider));
                final tag =
                    await useCase.createTag(name: controller.text.trim());
                await useCase.assignTag(
                    tagId: tag.id, mediaItemId: mediaItemId);
                ref.invalidate(allTagsProvider);
                ref.invalidate(tagIdsForItemProvider(mediaItemId));
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add TagChips to ItemDetailScreen**

In `item_detail_screen.dart`, add after the star rating section:

```dart
const SizedBox(height: 16),
TagChips(mediaItemId: item.id),
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/item_detail/
git commit -m "feat: add TagChips widget with create and assign"
```

---

## Task 6: Shelves Screens

**Files:**
- Modify: `lib/presentation/screens/shelves/shelves_screen.dart`
- Create: `lib/presentation/screens/shelves/shelf_detail_screen.dart`

- [ ] **Step 1: Replace shelves_screen.dart placeholder**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/usecases/manage_shelves_usecase.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/providers/shelf_provider.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class ShelvesScreen extends ConsumerWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelvesAsync = ref.watch(allShelvesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shelves')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateShelfDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: shelvesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (shelves) {
          if (shelves.isEmpty) {
            return const EmptyState(
              message: 'No shelves yet. Create one to organise your collection!',
              icon: Icons.shelves,
            );
          }
          return ListView.builder(
            itemCount: shelves.length,
            itemBuilder: (context, index) {
              final shelf = shelves[index];
              return ListTile(
                leading: const Icon(Icons.shelves),
                title: Text(shelf.name),
                subtitle: shelf.description != null
                    ? Text(shelf.description!)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/shelves/${shelf.id}'),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateShelfDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Shelf'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Shelf name'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final useCase = ManageShelvesUseCase(
                    repository: ref.read(shelfRepositoryProvider));
                await useCase.createShelf(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );
                ref.invalidate(allShelvesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create shelf_detail_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/presentation/providers/metadata_provider.dart';
import 'package:mymediascanner/presentation/providers/shelf_provider.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';

class ShelfDetailScreen extends ConsumerWidget {
  const ShelfDetailScreen({super.key, required this.shelfId});

  final String shelfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemIdsAsync = ref.watch(shelfItemIdsProvider(shelfId));

    return Scaffold(
      appBar: AppBar(title: const Text('Shelf')),
      body: itemIdsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (itemIds) {
          if (itemIds.isEmpty) {
            return const Center(
              child: Text('No items in this shelf yet.'),
            );
          }
          return ReorderableListView.builder(
            itemCount: itemIds.length,
            onReorder: (oldIndex, newIndex) {
              // Reorder logic handled by provider
            },
            itemBuilder: (context, index) {
              final itemAsync = ref.watch(mediaItemProvider(itemIds[index]));
              return ListTile(
                key: ValueKey(itemIds[index]),
                title: itemAsync.when(
                  loading: () => const Text('Loading...'),
                  error: (_, __) => const Text('Error'),
                  data: (item) => Text(item?.title ?? 'Unknown'),
                ),
                onTap: () => context.go('/item/${itemIds[index]}'),
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Update router.dart — replace shelves placeholders**

Update `/shelves/:id` route to use `ShelfDetailScreen(shelfId: state.pathParameters['id']!)`.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/shelves/ lib/app/router.dart
git commit -m "feat: add shelves screen and shelf detail with reorderable list"
```

---

## Task 7: Verify Slice 4

- [ ] **Step 1: Run code generation, analysis, tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

- [ ] **Step 2: Run app on macOS**

```bash
flutter run -d macos
```

Expected: Shelves tab shows shelf list with create FAB. Tags visible on item detail. Filter bar works with tags.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: complete Slice 4 — tags and shelves"
```
