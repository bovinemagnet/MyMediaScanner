import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog for manually entering a barcode / ISBN / IMDb ID.
///
/// Owns its [TextEditingController] and disposes it in [State.dispose] so the
/// controller is never touched after disposal while the route plays its exit
/// animation. [onSubmit] is invoked (after the dialog pops) only when the
/// trimmed entry is non-empty.
class ManualBarcodeEntryDialog extends StatefulWidget {
  const ManualBarcodeEntryDialog({super.key, required this.onSubmit});

  /// Called with the trimmed, non-empty barcode once the user confirms.
  final ValueChanged<String> onSubmit;

  @override
  State<ManualBarcodeEntryDialog> createState() =>
      _ManualBarcodeEntryDialogState();
}

class _ManualBarcodeEntryDialogState extends State<ManualBarcodeEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    Navigator.of(context).pop();
    if (value.isNotEmpty) {
      widget.onSubmit(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Barcode'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Barcode / ISBN / IMDb ID',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.qr_code),
        ),
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\dXxTt]')),
        ],
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Look up'),
        ),
      ],
    );
  }
}
