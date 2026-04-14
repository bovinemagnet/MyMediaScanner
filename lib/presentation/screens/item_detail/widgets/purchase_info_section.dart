// Purchase info section for the item detail screen. Allows editing of
// condition, price paid, retailer, and acquisition date.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/item_condition.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';

/// Editor section for purchase / ownership metadata.
///
/// Discrete fields (condition dropdown, acquired-at date picker) emit a
/// mutated [MediaItem] immediately. Text fields (price paid, retailer)
/// commit on blur or when editing is completed, to avoid a per-keystroke
/// write-through to SQLite and the re-render / IME churn that entails.
class PurchaseInfoSection extends StatefulWidget {
  const PurchaseInfoSection({
    super.key,
    required this.item,
    required this.onChanged,
  });

  final MediaItem item;
  final ValueChanged<MediaItem> onChanged;

  @override
  State<PurchaseInfoSection> createState() => _PurchaseInfoSectionState();
}

class _PurchaseInfoSectionState extends State<PurchaseInfoSection> {
  late final TextEditingController _priceController;
  late final TextEditingController _retailerController;
  late final FocusNode _priceFocusNode;
  late final FocusNode _retailerFocusNode;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.pricePaid != null
          ? widget.item.pricePaid!.toStringAsFixed(2)
          : '',
    );
    _retailerController = TextEditingController(text: widget.item.retailer ?? '');
    _priceFocusNode = FocusNode()..addListener(_handlePriceFocusChange);
    _retailerFocusNode = FocusNode()..addListener(_handleRetailerFocusChange);
  }

  @override
  void didUpdateWidget(covariant PurchaseInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync external changes that didn't originate here, and only when
    // the field is not currently being edited (otherwise we clobber the user).
    if (!_priceFocusNode.hasFocus) {
      final newPrice = widget.item.pricePaid;
      final currentPriceText = _priceController.text;
      final parsedCurrent =
          currentPriceText.isEmpty ? null : double.tryParse(currentPriceText);
      if (newPrice != parsedCurrent) {
        _priceController.text =
            newPrice != null ? newPrice.toStringAsFixed(2) : '';
      }
    }
    if (!_retailerFocusNode.hasFocus &&
        (widget.item.retailer ?? '') != _retailerController.text) {
      _retailerController.text = widget.item.retailer ?? '';
    }
  }

  @override
  void dispose() {
    _priceFocusNode.removeListener(_handlePriceFocusChange);
    _retailerFocusNode.removeListener(_handleRetailerFocusChange);
    _priceController.dispose();
    _retailerController.dispose();
    _priceFocusNode.dispose();
    _retailerFocusNode.dispose();
    super.dispose();
  }

  void _emit(MediaItem updated) => widget.onChanged(updated);

  void _handlePriceFocusChange() {
    if (!_priceFocusNode.hasFocus) {
      _commitPrice();
    }
  }

  void _handleRetailerFocusChange() {
    if (!_retailerFocusNode.hasFocus) {
      _commitRetailer();
    }
  }

  void _commitPrice() {
    final text = _priceController.text.trim();
    final parsed = text.isEmpty ? null : double.tryParse(text);
    if (parsed != widget.item.pricePaid) {
      _emit(widget.item.copyWith(pricePaid: parsed));
    }
  }

  void _commitRetailer() {
    final trimmed = _retailerController.text.trim();
    final next = trimmed.isEmpty ? null : trimmed;
    if (next != widget.item.retailer) {
      _emit(widget.item.copyWith(retailer: next));
    }
  }

  Future<void> _pickAcquiredDate(BuildContext context) async {
    final initial = widget.item.acquiredAt != null
        ? DateTime.fromMillisecondsSinceEpoch(widget.item.acquiredAt!)
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Acquired on',
    );
    if (picked != null) {
      _emit(widget.item.copyWith(acquiredAt: picked.millisecondsSinceEpoch));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dateFormat = DateFormat.yMMMd();
    final acquiredLabel = widget.item.acquiredAt != null
        ? dateFormat.format(
            DateTime.fromMillisecondsSinceEpoch(widget.item.acquiredAt!))
        : 'Not set';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PURCHASE INFO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ItemCondition?>(
            key: const Key('condition-dropdown'),
            initialValue: widget.item.condition,
            decoration: const InputDecoration(
              labelText: 'Condition',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<ItemCondition?>(
                value: null,
                child: Text('Unspecified'),
              ),
              ...ItemCondition.values.map(
                (c) => DropdownMenuItem<ItemCondition?>(
                  value: c,
                  child: Text(c.label),
                ),
              ),
            ],
            onChanged: (value) {
              _emit(widget.item.copyWith(condition: value));
            },
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('price-paid-field'),
            controller: _priceController,
            focusNode: _priceFocusNode,
            decoration: const InputDecoration(
              labelText: 'Price paid',
              border: OutlineInputBorder(),
              isDense: true,
              prefixText: '\u00A4 ',
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            textInputAction: TextInputAction.done,
            onEditingComplete: () {
              _commitPrice();
              _priceFocusNode.unfocus();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('retailer-field'),
            controller: _retailerController,
            focusNode: _retailerFocusNode,
            decoration: const InputDecoration(
              labelText: 'Retailer',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            textInputAction: TextInputAction.done,
            onEditingComplete: () {
              _commitRetailer();
              _retailerFocusNode.unfocus();
            },
          ),
          const SizedBox(height: 12),
          InkWell(
            key: const Key('acquired-at-tile'),
            onTap: () => _pickAcquiredDate(context),
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Acquired',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(acquiredLabel)),
                  Icon(Icons.calendar_today,
                      size: 18, color: colors.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
