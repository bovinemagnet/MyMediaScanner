import 'package:intl/intl.dart';
import 'package:mymediascanner/domain/entities/media_item.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';
import 'package:mymediascanner/domain/entities/ownership_status.dart';

/// Totals computed from a collection for valuation reporting.
typedef ValuationTotals = ({
  double grandTotal,
  Map<MediaType, double> byMediaType,
});

/// Generates an insurance-style valuation report from the collection.
///
/// Only owned, non-deleted items with a recorded `pricePaid` are included.
///
/// Author: Paul Snow
/// @since 0.0.0
class ValuationReportUseCase {
  const ValuationReportUseCase();

  ValuationTotals computeTotals(List<MediaItem> items) {
    final priced = _eligible(items);
    final byType = <MediaType, double>{};
    double total = 0;
    for (final item in priced) {
      byType[item.mediaType] = (byType[item.mediaType] ?? 0) + item.pricePaid!;
      total += item.pricePaid!;
    }
    return (grandTotal: total, byMediaType: byType);
  }

  String generateCsv(List<MediaItem> items) {
    const header =
        'title,mediaType,year,condition,retailer,acquiredAt,pricePaid';
    final rows = _eligible(items).map((item) {
      return [
        _escapeCsv(item.title),
        _escapeCsv(item.mediaType.name),
        item.year?.toString() ?? '',
        _escapeCsv(item.condition?.name ?? ''),
        _escapeCsv(item.retailer ?? ''),
        item.acquiredAt?.toString() ?? '',
        item.pricePaid!.toString(),
      ].join(',');
    });
    return [header, ...rows].join('\n');
  }

  String generateHtml(
    List<MediaItem> items, {
    required DateTime generatedAt,
  }) {
    final priced = _eligible(items);
    final totals = computeTotals(items);
    final formatter = NumberFormat.simpleCurrency();
    final timestamp = _formatTimestamp(generatedAt);
    const styles = '''
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
         padding: 2em; max-width: 960px; margin: 0 auto; color: #1c1c1e; }
  h1 { margin-bottom: 0.25em; }
  .generated { color: #6e6e73; margin-top: 0; }
  table { width: 100%; border-collapse: collapse; margin-bottom: 2em; }
  th, td { padding: 8px 12px; border-bottom: 1px solid #d2d2d7;
           text-align: left; }
  th { background: #f5f5f7; font-weight: 600; }
  td.num { text-align: right; font-variant-numeric: tabular-nums; }
  .grand-total { font-size: 1.5em; font-weight: 700; margin: 1em 0 1.5em; }
''';

    if (priced.isEmpty) {
      return '<!DOCTYPE html>\n'
          '<html lang="en">\n'
          '<head><meta charset="utf-8">'
          '<title>Valuation Report</title>'
          '<style>$styles</style></head>\n'
          '<body>\n'
          '<h1>Valuation Report</h1>\n'
          '<p class="generated">Generated $timestamp</p>\n'
          '<p><em>No priced items in collection.</em></p>\n'
          '</body></html>\n';
    }

    final itemRows = priced
        .map((i) => '<tr>'
            '<td>${_escapeHtml(i.title)}</td>'
            '<td>${_escapeHtml(i.mediaType.name)}</td>'
            '<td>${i.year ?? ''}</td>'
            '<td>${_escapeHtml(i.condition?.name ?? '')}</td>'
            '<td>${_escapeHtml(i.retailer ?? '')}</td>'
            '<td class="num">${formatter.format(i.pricePaid)}</td>'
            '</tr>')
        .join('\n');

    final typeEntries = totals.byMediaType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final typeRows = typeEntries
        .map((e) => '<tr>'
            '<td>${_escapeHtml(e.key.name)}</td>'
            '<td class="num">${formatter.format(e.value)}</td>'
            '</tr>')
        .join('\n');

    return '<!DOCTYPE html>\n'
        '<html lang="en">\n'
        '<head><meta charset="utf-8">'
        '<title>Valuation Report</title>'
        '<style>$styles</style></head>\n'
        '<body>\n'
        '<h1>Valuation Report</h1>\n'
        '<p class="generated">Generated $timestamp</p>\n'
        '<div class="grand-total">Grand total: '
        '${formatter.format(totals.grandTotal)}</div>\n'
        '<h2>Totals by media type</h2>\n'
        '<table><thead><tr><th>Type</th><th>Total</th></tr></thead>'
        '<tbody>\n$typeRows\n</tbody></table>\n'
        '<h2>Items (${priced.length})</h2>\n'
        '<table><thead><tr>'
        '<th>Title</th><th>Type</th><th>Year</th>'
        '<th>Condition</th><th>Retailer</th><th>Price paid</th>'
        '</tr></thead><tbody>\n$itemRows\n</tbody></table>\n'
        '</body></html>\n';
  }

  List<MediaItem> _eligible(List<MediaItem> items) => items
      .where((i) =>
          !i.deleted &&
          i.ownershipStatus == OwnershipStatus.owned &&
          i.pricePaid != null)
      .toList();

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _formatTimestamp(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute UTC';
  }
}
