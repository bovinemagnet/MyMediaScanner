import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/presentation/providers/wishlist_provider.dart';
import 'package:mymediascanner/presentation/widgets/empty_state.dart';
import 'package:mymediascanner/presentation/widgets/error_state.dart';
import 'package:mymediascanner/presentation/widgets/loading_indicator.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wishlistProvider);
    final width = MediaQuery.sizeOf(context).width;
    final useDesktopHeader = width >= AppConstants.compactBreakpoint;

    final body = async.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (err, _) => ErrorState(message: err.toString()),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border,
            message:
                'Your wishlist is empty. Scan items and save them to the wishlist to build one.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _WishlistTile(item: items[index]),
        );
      },
    );

    if (useDesktopHeader) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(
                title: 'Wishlist',
                subtitle: 'Items you plan to acquire.',
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: body,
    );
  }
}

class _WishlistTile extends ConsumerWidget {
  const _WishlistTile({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colors.surfaceContainerHigh,
      elevation: 0,
      child: ListTile(
        leading: item.coverUrl != null
            ? AspectRatio(
                aspectRatio: 2 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    item.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => const Icon(Icons.image),
                  ),
                ),
              )
            : const Icon(Icons.favorite_border),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            if (item.subtitle != null) item.subtitle!,
            if (item.year != null) '${item.year}',
          ].where((s) => s.isNotEmpty).join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Mark owned',
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () {
            // Wired up in task 1.5 via convertWishlistToOwnedProvider.
          },
        ),
      ),
    );
  }
}
