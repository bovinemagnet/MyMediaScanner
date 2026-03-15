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
      error: (_, _) => const SizedBox.shrink(),
      data: (allTags) => itemTagIdsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
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
