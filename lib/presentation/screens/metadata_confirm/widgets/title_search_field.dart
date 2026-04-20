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
    this.initialText,
  });

  final void Function(String title) onSearch;
  final bool isLoading;

  /// Optional initial text to pre-populate (e.g. from OCR).
  final String? initialText;

  @override
  State<TitleSearchField> createState() => _TitleSearchFieldState();
}

class _TitleSearchFieldState extends State<TitleSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant TitleSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-seed the controller when the parent passes a new [initialText]
    // (e.g. an OCR result arriving after the first build). Leave the user's
    // in-progress edit alone if they've already typed into the field.
    if (widget.initialText != oldWidget.initialText &&
        _controller.text == (oldWidget.initialText ?? '')) {
      _controller.text = widget.initialText ?? '';
    }
  }

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
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter title to search',
              prefixIcon: Icon(Icons.search),
            ),
            enabled: !widget.isLoading,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        widget.isLoading
            ? SizedBox(
                width: 48,
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
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
