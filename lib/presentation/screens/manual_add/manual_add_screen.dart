// Manual add screen — lets a user add an item without scanning a barcode.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';
import 'package:mymediascanner/presentation/providers/series_provider.dart';
import 'package:mymediascanner/presentation/screens/metadata_confirm/widgets/editable_metadata_form.dart';
import 'package:uuid/uuid.dart';

class ManualAddScreen extends ConsumerStatefulWidget {
  const ManualAddScreen({super.key});

  @override
  ConsumerState<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends ConsumerState<ManualAddScreen> {
  late final MetadataResult _initial;

  @override
  void initState() {
    super.initState();
    // Placeholder barcode keeps uniqueness, sync and dedup logic intact for
    // items the user entered by hand. Prefix signals provenance.
    final placeholder = 'MANUAL-${const Uuid().v7()}';
    _initial = MetadataResult(
      barcode: placeholder,
      barcodeType: 'MANUAL',
      mediaType: MediaType.unknown,
    );
  }

  Future<void> _handleSave(MetadataResult edited) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final useCase = ref.read(saveMediaItemUseCaseProvider);
    await useCase.execute(edited);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Item added to collection')),
    );
    router.go('/collection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item Manually'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: EditableMetadataForm(
            initial: _initial,
            onSave: _handleSave,
            primarySaveLabel: 'Save to Collection',
            primarySaveIcon: Icons.save,
          ),
        ),
      ),
    );
  }
}
