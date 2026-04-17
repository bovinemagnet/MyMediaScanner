import 'dart:convert';
import 'dart:typed_data';

import 'package:mymediascanner/domain/entities/media_item.dart';

/// Options controlling a static HTML export.
class StaticExportOptions {
  const StaticExportOptions({
    this.privateTag = 'private',
    this.bundleCovers = false,
    this.title = 'My collection',
  });

  /// Items with this tag (in `extraMetadata['tags']`) are excluded.
  final String privateTag;

  /// When true, cover images are expected to be supplied via the
  /// [StaticExportService.build] `covers` map and referenced from local
  /// `covers/...` paths. When false, the output HTML references the
  /// original `coverUrl` hosts directly.
  final bool bundleCovers;

  /// Title shown in the exported `<h1>`.
  final String title;
}

/// Pure, IO-free service that renders a self-contained static website
/// from a collection. No Flutter, no dart:io. Caller is responsible for
/// writing the returned map to disk and, if [StaticExportOptions.bundleCovers]
/// is true, fetching cover images and supplying them via [build]'s
/// `covers` argument.
///
/// Output layout:
/// ```
/// index.html      — grid + filter controls (inline CSS/JS)
/// items/<id>.html — per-item detail
/// covers/<id>.<ext> — only when covers are supplied
/// ```
class StaticExportService {
  const StaticExportService();

  /// Build the export. Returns a map of relative paths to byte content.
  Map<String, Uint8List> build({
    required List<MediaItem> items,
    StaticExportOptions options = const StaticExportOptions(),
    Map<String, Uint8List> covers = const {},
  }) {
    final visible = items
        .where((i) => !i.deleted)
        .where((i) => !_hasTag(i, options.privateTag))
        .toList();

    final index = _renderIndex(visible, options);
    final output = <String, Uint8List>{
      'index.html': Uint8List.fromList(utf8.encode(index)),
    };

    for (final item in visible) {
      final page = _renderItem(item, options);
      output['items/${item.id}.html'] =
          Uint8List.fromList(utf8.encode(page));
    }

    for (final e in covers.entries) {
      output['covers/${e.key}'] = e.value;
    }

    return output;
  }

  // ── HTML rendering ────────────────────────────────────────────────

  String _renderIndex(List<MediaItem> items, StaticExportOptions opts) {
    final mediaTypes = <String>{for (final i in items) i.mediaType.label};
    final tags = <String>{
      for (final i in items)
        if (i.extraMetadata['tags'] is List)
          for (final t in i.extraMetadata['tags'] as List)
            if (t is String && t != opts.privateTag) t,
    };

    final cards = <String>[];
    for (final item in items) {
      final cover = _coverPath(item, opts);
      final tagList = _tagsOf(item)
          .where((t) => t != opts.privateTag)
          .join(',');
      cards.add('''
      <a class="card"
         href="items/${_esc(item.id)}.html"
         data-type="${_esc(item.mediaType.label)}"
         data-tags="${_esc(tagList)}">
        ${cover != null ? '<img loading="lazy" src="${_esc(cover)}" alt="">' : '<div class="placeholder"></div>'}
        <div class="card-title">${_esc(item.title)}</div>
        ${item.year != null ? '<div class="card-sub">${item.year}</div>' : ''}
      </a>''');
    }

    return '''
<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<title>${_esc(opts.title)}</title>
<style>
  :root { color-scheme: dark light; }
  body { font-family: system-ui, sans-serif; margin: 0; padding: 24px; background: #0e0e0e; color: #f5f6f7; }
  h1 { margin: 0 0 16px; font-weight: 800; letter-spacing: -0.5px; }
  .toolbar { display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 16px; align-items: center; }
  .toolbar select, .toolbar input { padding: 6px 10px; border-radius: 6px; border: 1px solid #333; background: #1a1a1a; color: inherit; font: inherit; }
  .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 16px; }
  .card { display: block; background: #1a1a1a; border-radius: 12px; overflow: hidden; color: inherit; text-decoration: none; transition: transform 0.15s; }
  .card:hover { transform: translateY(-2px); }
  .card img, .card .placeholder { width: 100%; aspect-ratio: 2 / 3; object-fit: cover; background: #222; display: block; }
  .card-title { padding: 8px 10px 0; font-size: 14px; font-weight: 600; line-height: 1.2; }
  .card-sub { padding: 2px 10px 10px; font-size: 12px; color: #999; }
  .card.hidden { display: none; }
  @media (prefers-color-scheme: light) {
    body { background: #f5f6f7; color: #111; }
    .toolbar select, .toolbar input { background: #fff; border-color: #ddd; }
    .card { background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
    .card-sub { color: #666; }
  }
</style>
</head>
<body>
<h1>${_esc(opts.title)}</h1>
<div class="toolbar">
  <label>Type:
    <select id="type-filter">
      <option value="">All</option>
      ${mediaTypes.map((t) => '<option>${_esc(t)}</option>').join('\n      ')}
    </select>
  </label>
  <label>Tag:
    <select id="tag-filter">
      <option value="">Any</option>
      ${tags.map((t) => '<option>${_esc(t)}</option>').join('\n      ')}
    </select>
  </label>
  <input id="text-filter" placeholder="Search title...">
  <span id="count">${items.length} items</span>
</div>
<div class="grid">
${cards.join('\n')}
</div>
<script>
(() => {
  const cards = document.querySelectorAll('.card');
  const type = document.getElementById('type-filter');
  const tag = document.getElementById('tag-filter');
  const text = document.getElementById('text-filter');
  const count = document.getElementById('count');
  const apply = () => {
    const t = type.value;
    const tg = tag.value;
    const q = text.value.trim().toLowerCase();
    let visible = 0;
    cards.forEach(c => {
      const matchType = !t || c.dataset.type === t;
      const matchTag = !tg || (c.dataset.tags || '').split(',').includes(tg);
      const matchText = !q || c.querySelector('.card-title').textContent.toLowerCase().includes(q);
      const ok = matchType && matchTag && matchText;
      c.classList.toggle('hidden', !ok);
      if (ok) visible++;
    });
    count.textContent = visible + ' items';
  };
  type.addEventListener('change', apply);
  tag.addEventListener('change', apply);
  text.addEventListener('input', apply);
})();
</script>
</body>
</html>
''';
  }

  String _renderItem(MediaItem item, StaticExportOptions opts) {
    final cover = _coverPath(item, opts);
    final details = <(String, String)>[
      if (item.year != null) ('Year', item.year.toString()),
      if (item.publisher != null) ('Publisher', item.publisher!),
      if (item.format != null) ('Format', item.format!),
      ('Type', item.mediaType.label),
      if (item.barcode.isNotEmpty) ('Barcode', item.barcode),
      if (item.genres.isNotEmpty) ('Genres', item.genres.join(', ')),
      if (item.userRating != null)
        ('Rating', '${item.userRating!.toStringAsFixed(1)} / 5'),
    ];

    final rows = details
        .map((e) => '<tr><th>${_esc(e.$1)}</th><td>${_esc(e.$2)}</td></tr>')
        .join('\n      ');

    return '''
<!DOCTYPE html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<title>${_esc(item.title)} — ${_esc(opts.title)}</title>
<style>
  :root { color-scheme: dark light; }
  body { font-family: system-ui, sans-serif; margin: 0; padding: 24px; background: #0e0e0e; color: #f5f6f7; max-width: 880px; margin-inline: auto; }
  a.back { display: inline-block; margin-bottom: 16px; color: #6dddff; text-decoration: none; }
  .layout { display: grid; grid-template-columns: 240px 1fr; gap: 24px; align-items: start; }
  .cover { width: 100%; aspect-ratio: 2 / 3; object-fit: cover; border-radius: 12px; background: #222; }
  h1 { margin: 0 0 4px; font-size: 28px; }
  .sub { color: #999; margin-bottom: 16px; }
  table { width: 100%; border-collapse: collapse; }
  th, td { text-align: left; padding: 6px 0; border-bottom: 1px solid #222; font-size: 14px; }
  th { color: #999; width: 110px; font-weight: 500; }
  .desc { margin-top: 16px; line-height: 1.5; }
  @media (prefers-color-scheme: light) {
    body { background: #f5f6f7; color: #111; }
    a.back { color: #00647a; }
    .sub { color: #666; }
    th { color: #666; }
    th, td { border-color: #eee; }
  }
  @media (max-width: 600px) { .layout { grid-template-columns: 1fr; } }
</style>
</head>
<body>
<a class="back" href="../index.html">← Back to collection</a>
<div class="layout">
  ${cover != null ? '<img class="cover" src="../${_esc(cover)}" alt="">' : '<div class="cover"></div>'}
  <div>
    <h1>${_esc(item.title)}</h1>
    ${item.subtitle != null ? '<div class="sub">${_esc(item.subtitle!)}</div>' : ''}
    <table>
      $rows
    </table>
    ${item.description != null ? '<div class="desc">${_esc(item.description!)}</div>' : ''}
    ${item.userReview != null ? '<div class="desc"><em>${_esc(item.userReview!)}</em></div>' : ''}
  </div>
</div>
</body>
</html>
''';
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /// Returns the `covers/<id>.<ext>` path when covers are bundled and we
  /// have a URL (used by the writer to pick the extension). Returns the
  /// original URL when not bundling.
  String? _coverPath(MediaItem item, StaticExportOptions opts) {
    final url = item.coverUrl;
    if (url == null || url.isEmpty) return null;
    if (!opts.bundleCovers) return url;
    final ext = _extFromUrl(url);
    return 'covers/${item.id}$ext';
  }

  static String _extFromUrl(String url) {
    final q = url.indexOf('?');
    final clean = q >= 0 ? url.substring(0, q) : url;
    final slash = clean.lastIndexOf('/');
    final name = slash >= 0 ? clean.substring(slash + 1) : clean;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '.jpg';
    final ext = name.substring(dot).toLowerCase();
    const allowed = {'.jpg', '.jpeg', '.png', '.webp', '.gif'};
    return allowed.contains(ext) ? ext : '.jpg';
  }

  static List<String> _tagsOf(MediaItem item) {
    final tags = item.extraMetadata['tags'];
    if (tags is List) {
      return [for (final t in tags) if (t is String) t];
    }
    return const [];
  }

  static bool _hasTag(MediaItem item, String tag) =>
      _tagsOf(item).contains(tag);

  static String _esc(String input) => input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
