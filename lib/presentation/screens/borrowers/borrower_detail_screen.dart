import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/borrower.dart';
import 'package:mymediascanner/domain/entities/loan.dart';
import 'package:mymediascanner/domain/usecases/manage_borrowers_usecase.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';
import 'package:mymediascanner/presentation/widgets/overdue_badge.dart';
import 'package:mymediascanner/presentation/widgets/screen_header.dart';
import 'package:mymediascanner/core/utils/platform_utils.dart';

class BorrowerDetailScreen extends ConsumerWidget {
  const BorrowerDetailScreen({super.key, required this.borrowerId});

  final String borrowerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowersAsync = ref.watch(allBorrowersProvider);
    final loansAsync = ref.watch(loansForBorrowerProvider(borrowerId));
    final dateFormat = DateFormat.yMMMd();
    final isDesktop = PlatformUtils.isDesktop;
    final colors = Theme.of(context).colorScheme;

    final borrower = borrowersAsync.valueOrNull
        ?.where((b) => b.id == borrowerId)
        .firstOrNull;

    if (borrower == null) {
      return Scaffold(
        appBar: isDesktop ? null : AppBar(title: const Text('Borrower')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(borrower.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      _showEditDialog(context, ref, borrower),
                ),
              ],
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isDesktop)
            ScreenHeader(
              title: borrower.name,
              subtitle: 'Borrower details and loan history',
              actions: [
                OutlinedButton.icon(
                  onPressed: () =>
                      _showEditDialog(context, ref, borrower),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),

          // Contact info card
          Card(
            color: colors.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTACT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            color: colors.onSurfaceVariant,
                          )),
                  const SizedBox(height: 8),
                  if (borrower.email != null)
                    _InfoRow(
                        icon: Icons.email_outlined, text: borrower.email!),
                  if (borrower.phone != null)
                    _InfoRow(
                        icon: Icons.phone_outlined, text: borrower.phone!),
                  if (borrower.notes != null && borrower.notes!.isNotEmpty)
                    _InfoRow(
                        icon: Icons.notes_outlined, text: borrower.notes!),
                  if (borrower.email == null &&
                      borrower.phone == null &&
                      (borrower.notes == null || borrower.notes!.isEmpty))
                    Text('No contact information',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.5),
                            )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Loan statistics
          loansAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (loans) {
              final active = loans.where((l) => l.isActive).toList();
              final past = loans.where((l) => !l.isActive).toList();
              final overdue = active.where((l) => l.isOverdue).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatChip(
                          label: 'Total', value: '${loans.length}'),
                      const SizedBox(width: 8),
                      _StatChip(
                          label: 'Active', value: '${active.length}'),
                      if (overdue.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Overdue',
                          value: '${overdue.length}',
                          isError: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Active loans
                  if (active.isNotEmpty) ...[
                    Text('ACTIVE LOANS',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              letterSpacing: 1.2,
                              color: colors.onSurfaceVariant,
                            )),
                    const SizedBox(height: 8),
                    ...active.map((loan) => _LoanCard(
                          loan: loan,
                          dateFormat: dateFormat,
                          isActive: true,
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Past loans
                  if (past.isNotEmpty) ...[
                    Text('LOAN HISTORY',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              letterSpacing: 1.2,
                              color: colors.onSurfaceVariant,
                            )),
                    const SizedBox(height: 8),
                    ...past.map((loan) => _LoanCard(
                          loan: loan,
                          dateFormat: dateFormat,
                          isActive: false,
                        )),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, WidgetRef ref, Borrower borrower) async {
    final nameController = TextEditingController(text: borrower.name);
    final emailController = TextEditingController(text: borrower.email ?? '');
    final phoneController = TextEditingController(text: borrower.phone ?? '');
    final notesController = TextEditingController(text: borrower.notes ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Borrower'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: 'Name *', isDense: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(labelText: 'Email', isDense: true),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: 'Phone', isDense: true),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration:
                  const InputDecoration(labelText: 'Notes', isDense: true),
              maxLines: 2,
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
              final updated = borrower.copyWith(
                name: name,
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              );
              await ManageBorrowersUseCase(
                repository: ref.read(borrowerRepositoryProvider),
              ).updateBorrower(updated);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.isError = false,
  });

  final String label;
  final String value;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor =
        isError ? colors.error.withValues(alpha: 0.15) : colors.surfaceContainerHigh;
    final textColor = isError ? colors.error : colors.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
          Text(label,
              style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({
    required this.loan,
    required this.dateFormat,
    required this.isActive,
  });

  final Loan loan;
  final DateFormat dateFormat;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lentDate =
        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(loan.lentAt));

    return Card(
      color: isActive
          ? colors.tertiaryContainer.withValues(alpha: 0.15)
          : colors.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.book_outlined : Icons.check_circle_outline,
              color: isActive ? colors.tertiary : colors.outline,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item: ${loan.mediaItemId.substring(0, 8)}\u2026',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('Lent: $lentDate',
                      style: Theme.of(context).textTheme.bodySmall),
                  if (loan.dueAt != null)
                    Text(
                      'Due: ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(loan.dueAt!))}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (!isActive && loan.returnedAt != null)
                    Text(
                      'Returned: ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(loan.returnedAt!))}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (loan.isOverdue) OverdueBadge(daysOverdue: loan.daysOverdue),
          ],
        ),
      ),
    );
  }
}
