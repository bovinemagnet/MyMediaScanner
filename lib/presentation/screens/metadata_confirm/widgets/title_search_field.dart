import 'package:flutter/material.dart';

/// Text field with search button for manual title lookup.
///
/// Displayed on the confirm screen when barcode lookup returns no results,
/// allowing the user to search by title instead.
class TitleSearchField extends StatefulWidget {
  const TitleSearchField({
    super.key,
    required this.onSearch,
    this.isLoading = false,
  });

  final void Function(String title) onSearch;
  final bool isLoading;

  @override
  State<TitleSearchField> createState() => _TitleSearchFieldState();
}

class _TitleSearchFieldState extends State<TitleSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    widget.onSearch(title);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter title to search',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            enabled: !widget.isLoading,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        widget.isLoading
            ? const SizedBox(
                width: 48,
                height: 48,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton.filled(
                onPressed: _submit,
                icon: const Icon(Icons.search),
                tooltip: 'Search',
              ),
      ],
    );
  }
}
