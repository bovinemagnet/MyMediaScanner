import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/domain/usecases/lend_item_usecase.dart';
import 'package:mymediascanner/domain/usecases/manage_borrowers_usecase.dart';
import 'package:mymediascanner/presentation/providers/loan_provider.dart';
import 'package:mymediascanner/presentation/providers/repository_providers.dart';

class BorrowerPickerDialog extends ConsumerStatefulWidget {
  const BorrowerPickerDialog({super.key, required this.mediaItemId});

  final String mediaItemId;

  @override
  ConsumerState<BorrowerPickerDialog> createState() =>
      _BorrowerPickerDialogState();
}

class _BorrowerPickerDialogState extends ConsumerState<BorrowerPickerDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showNewBorrowerForm = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borrowersAsync = ref.watch(allBorrowersProvider);

    return AlertDialog(
      title: const Text('Select Borrower'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search borrowers\u2026',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 8),
            if (_showNewBorrowerForm) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  isDense: true,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  isDense: true,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  isDense: true,
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        setState(() => _showNewBorrowerForm = false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _createAndLend,
                    child: const Text('Create & Lend'),
                  ),
                ],
              ),
            ] else
              Flexible(
                child: borrowersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (borrowers) {
                    final filtered = _searchQuery.isEmpty
                        ? borrowers
                        : borrowers
                            .where((b) => b.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                            .toList();

                    return ListView(
                      shrinkWrap: true,
                      children: [
                        ...filtered.map((borrower) => ListTile(
                              leading: const CircleAvatar(
                                  child: Icon(Icons.person)),
                              title: Text(borrower.name),
                              subtitle: borrower.email != null
                                  ? Text(borrower.email!)
                                  : null,
                              dense: true,
                              onTap: () => _lendTo(borrower.id),
                            )),
                        ListTile(
                          leading: const CircleAvatar(
                              child: Icon(Icons.add)),
                          title: const Text('Add new borrower'),
                          dense: true,
                          onTap: () =>
                              setState(() => _showNewBorrowerForm = true),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _lendTo(String borrowerId) async {
    final lendUseCase = LendItemUseCase(
      repository: ref.read(loanRepositoryProvider),
    );
    await lendUseCase.execute(
      mediaItemId: widget.mediaItemId,
      borrowerId: borrowerId,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _createAndLend() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final manageBorrowers = ManageBorrowersUseCase(
      repository: ref.read(borrowerRepositoryProvider),
    );
    final borrower = await manageBorrowers.createBorrower(
      name: name,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    await _lendTo(borrower.id);
  }
}
