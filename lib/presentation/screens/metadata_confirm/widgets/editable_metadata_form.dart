import 'package:flutter/material.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/metadata_result.dart';

class EditableMetadataForm extends StatefulWidget {
  const EditableMetadataForm({
    super.key,
    required this.initial,
    required this.onSave,
  });

  final MetadataResult initial;
  final void Function(MetadataResult edited) onSave;

  @override
  State<EditableMetadataForm> createState() => _EditableMetadataFormState();
}

class _EditableMetadataFormState extends State<EditableMetadataForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _yearController;
  late final TextEditingController _publisherController;
  late final TextEditingController _formatController;
  late MediaType _mediaType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial.title ?? '');
    _subtitleController =
        TextEditingController(text: widget.initial.subtitle ?? '');
    _descriptionController =
        TextEditingController(text: widget.initial.description ?? '');
    _yearController =
        TextEditingController(text: widget.initial.year?.toString() ?? '');
    _publisherController =
        TextEditingController(text: widget.initial.publisher ?? '');
    _formatController =
        TextEditingController(text: widget.initial.format ?? '');
    _mediaType = widget.initial.mediaType ?? MediaType.unknown;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _publisherController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(widget.initial.copyWith(
      title: _titleController.text.isEmpty ? null : _titleController.text,
      subtitle:
          _subtitleController.text.isEmpty ? null : _subtitleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      year: int.tryParse(_yearController.text),
      publisher:
          _publisherController.text.isEmpty ? null : _publisherController.text,
      format: _formatController.text.isEmpty ? null : _formatController.text,
      mediaType: _mediaType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.initial.coverUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.initial.coverUrl!,
                  height: 200,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image,
                    size: 100,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MediaType>(
            initialValue: _mediaType,
            decoration: const InputDecoration(labelText: 'Media Type'),
            items: MediaType.values
                .map((t) =>
                    DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) => setState(() => _mediaType = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(labelText: 'Subtitle'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _yearController,
            decoration: const InputDecoration(labelText: 'Year'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _publisherController,
            decoration:
                const InputDecoration(labelText: 'Publisher / Studio / Label'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _formatController,
            decoration: const InputDecoration(
                labelText: 'Format (e.g. Blu-ray, CD, Hardcover)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save to Collection'),
          ),
        ],
      ),
    );
  }
}
