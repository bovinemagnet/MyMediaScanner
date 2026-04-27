import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/usecases/manage_borrowers_usecase.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/widgets/overdue_badge.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';

class BorrowersScreen extends ConsumerStatefulWidget {
  const BorrowersScreen({super.key});

  @override
  ConsumerState<BorrowersScreen> createState() => _BorrowersScreenState();
}

class _BorrowersScreenState extends ConsumerState<BorrowersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borrowersAsync = ref.watch(allBorrowersProvider);
    final overdueLoansAsync = ref.watch(overdueLoansProvider);
    final activeLoansAsync = ref.watch(activeLoansProvider);
    final isDesktop = PlatformCapability.isDesktop;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Borrowers'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => _showAddBorrowerDialog(context),
                ),
              ],
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            ScreenHeader(
              title: 'Borrowers',
              subtitle: 'Manage your borrowers and track loans',
              actions: [
                FilledButton.icon(
                  onPressed: () => _showAddBorrowerDialog(context),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add Borrower'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search borrowers\u2026',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: colors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: borrowersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (borrowers) {
                final filtered = _searchQuery.isEmpty
                    ? borrowers
                    : borrowers
                        .where((b) => b.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64,
                            color: colors.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No borrowers yet'
                              : 'No borrowers match "$_searchQuery"',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  );
                }

                final activeLoans = activeLoansAsync.value ?? [];
                final overdueLoans = overdueLoansAsync.value ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final borrower = filtered[index];
                    final activeLoanCount = activeLoans
                        .where((l) => l.borrowerId == borrower.id)
                        .length;
                    final overdueCount = overdueLoans
                        .where((l) => l.borrowerId == borrower.id)
                        .length;
                    final maxDaysOverdue = overdueLoans
                        .where((l) => l.borrowerId == borrower.id)
                        .fold<int>(0, (max, l) =>
                            l.daysOverdue > max ? l.daysOverdue : max);

                    return _BorrowerTile(
                      borrower: borrower,
                      activeLoanCount: activeLoanCount,
                      overdueCount: overdueCount,
                      maxDaysOverdue: maxDaysOverdue,
                      onTap: () =>
                          context.push('/borrowers/${borrower.id}'),
                      onDelete: () => _deleteBorrower(borrower.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddBorrowerDialog(context),
              child: const Icon(Icons.person_add),
            ),
    );
  }

  Future<void> _showAddBorrowerDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Borrower'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: 'Name *', isDense: true),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: 'Email', isDense: true),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                  labelText: 'Phone', isDense: true),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final useCase = ManageBorrowersUseCase(
                repository: ref.read(borrowerRepositoryProvider),
              );
              await useCase.createBorrower(
                name: name,
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    // Disposal is deferred to the next frame so the dialog's exit
    // animation can read the controllers one last time without hitting a
    // disposed-controller assertion. Without this, three controllers
    // leak per invocation for the lifetime of the screen.
    _disposeAfterFrame(
        [nameController, emailController, phoneController]);
  }

  void _disposeAfterFrame(List<TextEditingController> controllers) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }

  Future<void> _deleteBorrower(String id) async {
    final useCase = ManageBorrowersUseCase(
      repository: ref.read(borrowerRepositoryProvider),
    );
    await useCase.deleteBorrower(id);
  }
}

class _BorrowerTile extends StatelessWidget {
  const _BorrowerTile({
    required this.borrower,
    required this.activeLoanCount,
    required this.overdueCount,
    required this.maxDaysOverdue,
    required this.onTap,
    required this.onDelete,
  });

  final Borrower borrower;
  final int activeLoanCount;
  final int overdueCount;
  final int maxDaysOverdue;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Text(
            borrower.name.isNotEmpty ? borrower.name[0].toUpperCase() : '?',
            style: TextStyle(color: colors.onPrimaryContainer),
          ),
        ),
        title: Text(borrower.name),
        subtitle: Row(
          children: [
            if (borrower.email != null)
              Flexible(
                child: Text(
                  borrower.email!,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (activeLoanCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$activeLoanCount active',
                  style: TextStyle(
                      color: colors.tertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
            if (overdueCount > 0) ...[
              const SizedBox(width: 4),
              OverdueBadge(daysOverdue: maxDaysOverdue),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
