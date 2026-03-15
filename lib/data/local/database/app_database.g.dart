// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MediaItemsTableTable extends MediaItemsTable
    with TableInfo<$MediaItemsTableTable, MediaItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeTypeMeta = const VerificationMeta(
    'barcodeType',
  );
  @override
  late final GeneratedColumn<String> barcodeType = GeneratedColumn<String>(
    'barcode_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _extraMetadataMeta = const VerificationMeta(
    'extraMetadata',
  );
  @override
  late final GeneratedColumn<String> extraMetadata = GeneratedColumn<String>(
    'extra_metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _sourceApisMeta = const VerificationMeta(
    'sourceApis',
  );
  @override
  late final GeneratedColumn<String> sourceApis = GeneratedColumn<String>(
    'source_apis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _userRatingMeta = const VerificationMeta(
    'userRating',
  );
  @override
  late final GeneratedColumn<double> userRating = GeneratedColumn<double>(
    'user_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userReviewMeta = const VerificationMeta(
    'userReview',
  );
  @override
  late final GeneratedColumn<String> userReview = GeneratedColumn<String>(
    'user_review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criticScoreMeta = const VerificationMeta(
    'criticScore',
  );
  @override
  late final GeneratedColumn<double> criticScore = GeneratedColumn<double>(
    'critic_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criticSourceMeta = const VerificationMeta(
    'criticSource',
  );
  @override
  late final GeneratedColumn<String> criticSource = GeneratedColumn<String>(
    'critic_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<int> dateAdded = GeneratedColumn<int>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateScannedMeta = const VerificationMeta(
    'dateScanned',
  );
  @override
  late final GeneratedColumn<int> dateScanned = GeneratedColumn<int>(
    'date_scanned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    barcode,
    barcodeType,
    mediaType,
    title,
    subtitle,
    description,
    coverUrl,
    year,
    publisher,
    format,
    genres,
    extraMetadata,
    sourceApis,
    userRating,
    userReview,
    criticScore,
    criticSource,
    dateAdded,
    dateScanned,
    updatedAt,
    syncedAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('barcode_type')) {
      context.handle(
        _barcodeTypeMeta,
        barcodeType.isAcceptableOrUnknown(
          data['barcode_type']!,
          _barcodeTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barcodeTypeMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('extra_metadata')) {
      context.handle(
        _extraMetadataMeta,
        extraMetadata.isAcceptableOrUnknown(
          data['extra_metadata']!,
          _extraMetadataMeta,
        ),
      );
    }
    if (data.containsKey('source_apis')) {
      context.handle(
        _sourceApisMeta,
        sourceApis.isAcceptableOrUnknown(data['source_apis']!, _sourceApisMeta),
      );
    }
    if (data.containsKey('user_rating')) {
      context.handle(
        _userRatingMeta,
        userRating.isAcceptableOrUnknown(data['user_rating']!, _userRatingMeta),
      );
    }
    if (data.containsKey('user_review')) {
      context.handle(
        _userReviewMeta,
        userReview.isAcceptableOrUnknown(data['user_review']!, _userReviewMeta),
      );
    }
    if (data.containsKey('critic_score')) {
      context.handle(
        _criticScoreMeta,
        criticScore.isAcceptableOrUnknown(
          data['critic_score']!,
          _criticScoreMeta,
        ),
      );
    }
    if (data.containsKey('critic_source')) {
      context.handle(
        _criticSourceMeta,
        criticSource.isAcceptableOrUnknown(
          data['critic_source']!,
          _criticSourceMeta,
        ),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('date_scanned')) {
      context.handle(
        _dateScannedMeta,
        dateScanned.isAcceptableOrUnknown(
          data['date_scanned']!,
          _dateScannedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateScannedMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      barcodeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_type'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      )!,
      extraMetadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_metadata'],
      )!,
      sourceApis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_apis'],
      )!,
      userRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}user_rating'],
      ),
      userReview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_review'],
      ),
      criticScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}critic_score'],
      ),
      criticSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}critic_source'],
      ),
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_added'],
      )!,
      dateScanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_scanned'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $MediaItemsTableTable createAlias(String alias) {
    return $MediaItemsTableTable(attachedDatabase, alias);
  }
}

class MediaItemsTableData extends DataClass
    implements Insertable<MediaItemsTableData> {
  final String id;
  final String barcode;
  final String barcodeType;
  final String mediaType;
  final String title;
  final String? subtitle;
  final String? description;
  final String? coverUrl;
  final int? year;
  final String? publisher;
  final String? format;
  final String genres;
  final String extraMetadata;
  final String sourceApis;
  final double? userRating;
  final String? userReview;
  final double? criticScore;
  final String? criticSource;
  final int dateAdded;
  final int dateScanned;
  final int updatedAt;
  final int? syncedAt;
  final int deleted;
  const MediaItemsTableData({
    required this.id,
    required this.barcode,
    required this.barcodeType,
    required this.mediaType,
    required this.title,
    this.subtitle,
    this.description,
    this.coverUrl,
    this.year,
    this.publisher,
    this.format,
    required this.genres,
    required this.extraMetadata,
    required this.sourceApis,
    this.userRating,
    this.userReview,
    this.criticScore,
    this.criticSource,
    required this.dateAdded,
    required this.dateScanned,
    required this.updatedAt,
    this.syncedAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['barcode'] = Variable<String>(barcode);
    map['barcode_type'] = Variable<String>(barcodeType);
    map['media_type'] = Variable<String>(mediaType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || format != null) {
      map['format'] = Variable<String>(format);
    }
    map['genres'] = Variable<String>(genres);
    map['extra_metadata'] = Variable<String>(extraMetadata);
    map['source_apis'] = Variable<String>(sourceApis);
    if (!nullToAbsent || userRating != null) {
      map['user_rating'] = Variable<double>(userRating);
    }
    if (!nullToAbsent || userReview != null) {
      map['user_review'] = Variable<String>(userReview);
    }
    if (!nullToAbsent || criticScore != null) {
      map['critic_score'] = Variable<double>(criticScore);
    }
    if (!nullToAbsent || criticSource != null) {
      map['critic_source'] = Variable<String>(criticSource);
    }
    map['date_added'] = Variable<int>(dateAdded);
    map['date_scanned'] = Variable<int>(dateScanned);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  MediaItemsTableCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsTableCompanion(
      id: Value(id),
      barcode: Value(barcode),
      barcodeType: Value(barcodeType),
      mediaType: Value(mediaType),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      format: format == null && nullToAbsent
          ? const Value.absent()
          : Value(format),
      genres: Value(genres),
      extraMetadata: Value(extraMetadata),
      sourceApis: Value(sourceApis),
      userRating: userRating == null && nullToAbsent
          ? const Value.absent()
          : Value(userRating),
      userReview: userReview == null && nullToAbsent
          ? const Value.absent()
          : Value(userReview),
      criticScore: criticScore == null && nullToAbsent
          ? const Value.absent()
          : Value(criticScore),
      criticSource: criticSource == null && nullToAbsent
          ? const Value.absent()
          : Value(criticSource),
      dateAdded: Value(dateAdded),
      dateScanned: Value(dateScanned),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      deleted: Value(deleted),
    );
  }

  factory MediaItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      barcode: serializer.fromJson<String>(json['barcode']),
      barcodeType: serializer.fromJson<String>(json['barcodeType']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      description: serializer.fromJson<String?>(json['description']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      year: serializer.fromJson<int?>(json['year']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      format: serializer.fromJson<String?>(json['format']),
      genres: serializer.fromJson<String>(json['genres']),
      extraMetadata: serializer.fromJson<String>(json['extraMetadata']),
      sourceApis: serializer.fromJson<String>(json['sourceApis']),
      userRating: serializer.fromJson<double?>(json['userRating']),
      userReview: serializer.fromJson<String?>(json['userReview']),
      criticScore: serializer.fromJson<double?>(json['criticScore']),
      criticSource: serializer.fromJson<String?>(json['criticSource']),
      dateAdded: serializer.fromJson<int>(json['dateAdded']),
      dateScanned: serializer.fromJson<int>(json['dateScanned']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'barcode': serializer.toJson<String>(barcode),
      'barcodeType': serializer.toJson<String>(barcodeType),
      'mediaType': serializer.toJson<String>(mediaType),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'description': serializer.toJson<String?>(description),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'year': serializer.toJson<int?>(year),
      'publisher': serializer.toJson<String?>(publisher),
      'format': serializer.toJson<String?>(format),
      'genres': serializer.toJson<String>(genres),
      'extraMetadata': serializer.toJson<String>(extraMetadata),
      'sourceApis': serializer.toJson<String>(sourceApis),
      'userRating': serializer.toJson<double?>(userRating),
      'userReview': serializer.toJson<String?>(userReview),
      'criticScore': serializer.toJson<double?>(criticScore),
      'criticSource': serializer.toJson<String?>(criticSource),
      'dateAdded': serializer.toJson<int>(dateAdded),
      'dateScanned': serializer.toJson<int>(dateScanned),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  MediaItemsTableData copyWith({
    String? id,
    String? barcode,
    String? barcodeType,
    String? mediaType,
    String? title,
    Value<String?> subtitle = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<String?> format = const Value.absent(),
    String? genres,
    String? extraMetadata,
    String? sourceApis,
    Value<double?> userRating = const Value.absent(),
    Value<String?> userReview = const Value.absent(),
    Value<double?> criticScore = const Value.absent(),
    Value<String?> criticSource = const Value.absent(),
    int? dateAdded,
    int? dateScanned,
    int? updatedAt,
    Value<int?> syncedAt = const Value.absent(),
    int? deleted,
  }) => MediaItemsTableData(
    id: id ?? this.id,
    barcode: barcode ?? this.barcode,
    barcodeType: barcodeType ?? this.barcodeType,
    mediaType: mediaType ?? this.mediaType,
    title: title ?? this.title,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    description: description.present ? description.value : this.description,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    year: year.present ? year.value : this.year,
    publisher: publisher.present ? publisher.value : this.publisher,
    format: format.present ? format.value : this.format,
    genres: genres ?? this.genres,
    extraMetadata: extraMetadata ?? this.extraMetadata,
    sourceApis: sourceApis ?? this.sourceApis,
    userRating: userRating.present ? userRating.value : this.userRating,
    userReview: userReview.present ? userReview.value : this.userReview,
    criticScore: criticScore.present ? criticScore.value : this.criticScore,
    criticSource: criticSource.present ? criticSource.value : this.criticSource,
    dateAdded: dateAdded ?? this.dateAdded,
    dateScanned: dateScanned ?? this.dateScanned,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    deleted: deleted ?? this.deleted,
  );
  MediaItemsTableData copyWithCompanion(MediaItemsTableCompanion data) {
    return MediaItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      barcodeType: data.barcodeType.present
          ? data.barcodeType.value
          : this.barcodeType,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      year: data.year.present ? data.year.value : this.year,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      format: data.format.present ? data.format.value : this.format,
      genres: data.genres.present ? data.genres.value : this.genres,
      extraMetadata: data.extraMetadata.present
          ? data.extraMetadata.value
          : this.extraMetadata,
      sourceApis: data.sourceApis.present
          ? data.sourceApis.value
          : this.sourceApis,
      userRating: data.userRating.present
          ? data.userRating.value
          : this.userRating,
      userReview: data.userReview.present
          ? data.userReview.value
          : this.userReview,
      criticScore: data.criticScore.present
          ? data.criticScore.value
          : this.criticScore,
      criticSource: data.criticSource.present
          ? data.criticSource.value
          : this.criticSource,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      dateScanned: data.dateScanned.present
          ? data.dateScanned.value
          : this.dateScanned,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsTableData(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('barcodeType: $barcodeType, ')
          ..write('mediaType: $mediaType, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('year: $year, ')
          ..write('publisher: $publisher, ')
          ..write('format: $format, ')
          ..write('genres: $genres, ')
          ..write('extraMetadata: $extraMetadata, ')
          ..write('sourceApis: $sourceApis, ')
          ..write('userRating: $userRating, ')
          ..write('userReview: $userReview, ')
          ..write('criticScore: $criticScore, ')
          ..write('criticSource: $criticSource, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateScanned: $dateScanned, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    barcode,
    barcodeType,
    mediaType,
    title,
    subtitle,
    description,
    coverUrl,
    year,
    publisher,
    format,
    genres,
    extraMetadata,
    sourceApis,
    userRating,
    userReview,
    criticScore,
    criticSource,
    dateAdded,
    dateScanned,
    updatedAt,
    syncedAt,
    deleted,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItemsTableData &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.barcodeType == this.barcodeType &&
          other.mediaType == this.mediaType &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.description == this.description &&
          other.coverUrl == this.coverUrl &&
          other.year == this.year &&
          other.publisher == this.publisher &&
          other.format == this.format &&
          other.genres == this.genres &&
          other.extraMetadata == this.extraMetadata &&
          other.sourceApis == this.sourceApis &&
          other.userRating == this.userRating &&
          other.userReview == this.userReview &&
          other.criticScore == this.criticScore &&
          other.criticSource == this.criticSource &&
          other.dateAdded == this.dateAdded &&
          other.dateScanned == this.dateScanned &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.deleted == this.deleted);
}

class MediaItemsTableCompanion extends UpdateCompanion<MediaItemsTableData> {
  final Value<String> id;
  final Value<String> barcode;
  final Value<String> barcodeType;
  final Value<String> mediaType;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<String?> description;
  final Value<String?> coverUrl;
  final Value<int?> year;
  final Value<String?> publisher;
  final Value<String?> format;
  final Value<String> genres;
  final Value<String> extraMetadata;
  final Value<String> sourceApis;
  final Value<double?> userRating;
  final Value<String?> userReview;
  final Value<double?> criticScore;
  final Value<String?> criticSource;
  final Value<int> dateAdded;
  final Value<int> dateScanned;
  final Value<int> updatedAt;
  final Value<int?> syncedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const MediaItemsTableCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.barcodeType = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.publisher = const Value.absent(),
    this.format = const Value.absent(),
    this.genres = const Value.absent(),
    this.extraMetadata = const Value.absent(),
    this.sourceApis = const Value.absent(),
    this.userRating = const Value.absent(),
    this.userReview = const Value.absent(),
    this.criticScore = const Value.absent(),
    this.criticSource = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.dateScanned = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaItemsTableCompanion.insert({
    required String id,
    required String barcode,
    required String barcodeType,
    required String mediaType,
    required String title,
    this.subtitle = const Value.absent(),
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.publisher = const Value.absent(),
    this.format = const Value.absent(),
    this.genres = const Value.absent(),
    this.extraMetadata = const Value.absent(),
    this.sourceApis = const Value.absent(),
    this.userRating = const Value.absent(),
    this.userReview = const Value.absent(),
    this.criticScore = const Value.absent(),
    this.criticSource = const Value.absent(),
    required int dateAdded,
    required int dateScanned,
    required int updatedAt,
    this.syncedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       barcode = Value(barcode),
       barcodeType = Value(barcodeType),
       mediaType = Value(mediaType),
       title = Value(title),
       dateAdded = Value(dateAdded),
       dateScanned = Value(dateScanned),
       updatedAt = Value(updatedAt);
  static Insertable<MediaItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? barcode,
    Expression<String>? barcodeType,
    Expression<String>? mediaType,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? description,
    Expression<String>? coverUrl,
    Expression<int>? year,
    Expression<String>? publisher,
    Expression<String>? format,
    Expression<String>? genres,
    Expression<String>? extraMetadata,
    Expression<String>? sourceApis,
    Expression<double>? userRating,
    Expression<String>? userReview,
    Expression<double>? criticScore,
    Expression<String>? criticSource,
    Expression<int>? dateAdded,
    Expression<int>? dateScanned,
    Expression<int>? updatedAt,
    Expression<int>? syncedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (barcodeType != null) 'barcode_type': barcodeType,
      if (mediaType != null) 'media_type': mediaType,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (year != null) 'year': year,
      if (publisher != null) 'publisher': publisher,
      if (format != null) 'format': format,
      if (genres != null) 'genres': genres,
      if (extraMetadata != null) 'extra_metadata': extraMetadata,
      if (sourceApis != null) 'source_apis': sourceApis,
      if (userRating != null) 'user_rating': userRating,
      if (userReview != null) 'user_review': userReview,
      if (criticScore != null) 'critic_score': criticScore,
      if (criticSource != null) 'critic_source': criticSource,
      if (dateAdded != null) 'date_added': dateAdded,
      if (dateScanned != null) 'date_scanned': dateScanned,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? barcode,
    Value<String>? barcodeType,
    Value<String>? mediaType,
    Value<String>? title,
    Value<String?>? subtitle,
    Value<String?>? description,
    Value<String?>? coverUrl,
    Value<int?>? year,
    Value<String?>? publisher,
    Value<String?>? format,
    Value<String>? genres,
    Value<String>? extraMetadata,
    Value<String>? sourceApis,
    Value<double?>? userRating,
    Value<String?>? userReview,
    Value<double?>? criticScore,
    Value<String?>? criticSource,
    Value<int>? dateAdded,
    Value<int>? dateScanned,
    Value<int>? updatedAt,
    Value<int?>? syncedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return MediaItemsTableCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      barcodeType: barcodeType ?? this.barcodeType,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      year: year ?? this.year,
      publisher: publisher ?? this.publisher,
      format: format ?? this.format,
      genres: genres ?? this.genres,
      extraMetadata: extraMetadata ?? this.extraMetadata,
      sourceApis: sourceApis ?? this.sourceApis,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
      criticScore: criticScore ?? this.criticScore,
      criticSource: criticSource ?? this.criticSource,
      dateAdded: dateAdded ?? this.dateAdded,
      dateScanned: dateScanned ?? this.dateScanned,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (barcodeType.present) {
      map['barcode_type'] = Variable<String>(barcodeType.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (extraMetadata.present) {
      map['extra_metadata'] = Variable<String>(extraMetadata.value);
    }
    if (sourceApis.present) {
      map['source_apis'] = Variable<String>(sourceApis.value);
    }
    if (userRating.present) {
      map['user_rating'] = Variable<double>(userRating.value);
    }
    if (userReview.present) {
      map['user_review'] = Variable<String>(userReview.value);
    }
    if (criticScore.present) {
      map['critic_score'] = Variable<double>(criticScore.value);
    }
    if (criticSource.present) {
      map['critic_source'] = Variable<String>(criticSource.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<int>(dateAdded.value);
    }
    if (dateScanned.present) {
      map['date_scanned'] = Variable<int>(dateScanned.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('barcodeType: $barcodeType, ')
          ..write('mediaType: $mediaType, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('year: $year, ')
          ..write('publisher: $publisher, ')
          ..write('format: $format, ')
          ..write('genres: $genres, ')
          ..write('extraMetadata: $extraMetadata, ')
          ..write('sourceApis: $sourceApis, ')
          ..write('userRating: $userRating, ')
          ..write('userReview: $userReview, ')
          ..write('criticScore: $criticScore, ')
          ..write('criticSource: $criticSource, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateScanned: $dateScanned, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTableTable extends TagsTable
    with TableInfo<$TagsTableTable, TagsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
    'colour',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, colour, updatedAt, deleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('colour')) {
      context.handle(
        _colourMeta,
        colour.isAcceptableOrUnknown(data['colour']!, _colourMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colour: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colour'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $TagsTableTable createAlias(String alias) {
    return $TagsTableTable(attachedDatabase, alias);
  }
}

class TagsTableData extends DataClass implements Insertable<TagsTableData> {
  final String id;
  final String name;
  final String? colour;
  final int updatedAt;
  final int deleted;
  const TagsTableData({
    required this.id,
    required this.name,
    this.colour,
    required this.updatedAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  TagsTableCompanion toCompanion(bool nullToAbsent) {
    return TagsTableCompanion(
      id: Value(id),
      name: Value(name),
      colour: colour == null && nullToAbsent
          ? const Value.absent()
          : Value(colour),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
    );
  }

  factory TagsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colour: serializer.fromJson<String?>(json['colour']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colour': serializer.toJson<String?>(colour),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  TagsTableData copyWith({
    String? id,
    String? name,
    Value<String?> colour = const Value.absent(),
    int? updatedAt,
    int? deleted,
  }) => TagsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    colour: colour.present ? colour.value : this.colour,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
  TagsTableData copyWithCompanion(TagsTableCompanion data) {
    return TagsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colour: data.colour.present ? data.colour.value : this.colour,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colour: $colour, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colour, updatedAt, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.colour == this.colour &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted);
}

class TagsTableCompanion extends UpdateCompanion<TagsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> colour;
  final Value<int> updatedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const TagsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colour = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsTableCompanion.insert({
    required String id,
    required String name,
    this.colour = const Value.absent(),
    required int updatedAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<TagsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colour,
    Expression<int>? updatedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colour != null) 'colour': colour,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? colour,
    Value<int>? updatedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return TagsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colour: colour ?? this.colour,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colour: $colour, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaItemTagsTableTable extends MediaItemTagsTable
    with TableInfo<$MediaItemTagsTableTable, MediaItemTagsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemTagsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [mediaItemId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_item_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItemTagsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaItemId, tagId};
  @override
  MediaItemTagsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItemTagsTableData(
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $MediaItemTagsTableTable createAlias(String alias) {
    return $MediaItemTagsTableTable(attachedDatabase, alias);
  }
}

class MediaItemTagsTableData extends DataClass
    implements Insertable<MediaItemTagsTableData> {
  final String mediaItemId;
  final String tagId;
  const MediaItemTagsTableData({
    required this.mediaItemId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  MediaItemTagsTableCompanion toCompanion(bool nullToAbsent) {
    return MediaItemTagsTableCompanion(
      mediaItemId: Value(mediaItemId),
      tagId: Value(tagId),
    );
  }

  factory MediaItemTagsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItemTagsTableData(
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  MediaItemTagsTableData copyWith({String? mediaItemId, String? tagId}) =>
      MediaItemTagsTableData(
        mediaItemId: mediaItemId ?? this.mediaItemId,
        tagId: tagId ?? this.tagId,
      );
  MediaItemTagsTableData copyWithCompanion(MediaItemTagsTableCompanion data) {
    return MediaItemTagsTableData(
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemTagsTableData(')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mediaItemId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItemTagsTableData &&
          other.mediaItemId == this.mediaItemId &&
          other.tagId == this.tagId);
}

class MediaItemTagsTableCompanion
    extends UpdateCompanion<MediaItemTagsTableData> {
  final Value<String> mediaItemId;
  final Value<String> tagId;
  final Value<int> rowid;
  const MediaItemTagsTableCompanion({
    this.mediaItemId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaItemTagsTableCompanion.insert({
    required String mediaItemId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : mediaItemId = Value(mediaItemId),
       tagId = Value(tagId);
  static Insertable<MediaItemTagsTableData> custom({
    Expression<String>? mediaItemId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaItemTagsTableCompanion copyWith({
    Value<String>? mediaItemId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return MediaItemTagsTableCompanion(
      mediaItemId: mediaItemId ?? this.mediaItemId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemTagsTableCompanion(')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShelvesTableTable extends ShelvesTable
    with TableInfo<$ShelvesTableTable, ShelvesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelvesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    sortOrder,
    updatedAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelves';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShelvesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShelvesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShelvesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $ShelvesTableTable createAlias(String alias) {
    return $ShelvesTableTable(attachedDatabase, alias);
  }
}

class ShelvesTableData extends DataClass
    implements Insertable<ShelvesTableData> {
  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final int updatedAt;
  final int deleted;
  const ShelvesTableData({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.updatedAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  ShelvesTableCompanion toCompanion(bool nullToAbsent) {
    return ShelvesTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
    );
  }

  factory ShelvesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShelvesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  ShelvesTableData copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? sortOrder,
    int? updatedAt,
    int? deleted,
  }) => ShelvesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
  ShelvesTableData copyWithCompanion(ShelvesTableCompanion data) {
    return ShelvesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, sortOrder, updatedAt, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShelvesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted);
}

class ShelvesTableCompanion extends UpdateCompanion<ShelvesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<int> updatedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const ShelvesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShelvesTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int updatedAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<ShelvesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<int>? updatedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShelvesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? sortOrder,
    Value<int>? updatedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return ShelvesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShelfItemsTableTable extends ShelfItemsTable
    with TableInfo<$ShelfItemsTableTable, ShelfItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelfItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<String> shelfId = GeneratedColumn<String>(
    'shelf_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id)',
    ),
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [shelfId, mediaItemId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelf_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShelfItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shelfIdMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {shelfId, mediaItemId};
  @override
  ShelfItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShelfItemsTableData(
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $ShelfItemsTableTable createAlias(String alias) {
    return $ShelfItemsTableTable(attachedDatabase, alias);
  }
}

class ShelfItemsTableData extends DataClass
    implements Insertable<ShelfItemsTableData> {
  final String shelfId;
  final String mediaItemId;
  final int position;
  const ShelfItemsTableData({
    required this.shelfId,
    required this.mediaItemId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['shelf_id'] = Variable<String>(shelfId);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['position'] = Variable<int>(position);
    return map;
  }

  ShelfItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ShelfItemsTableCompanion(
      shelfId: Value(shelfId),
      mediaItemId: Value(mediaItemId),
      position: Value(position),
    );
  }

  factory ShelfItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShelfItemsTableData(
      shelfId: serializer.fromJson<String>(json['shelfId']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shelfId': serializer.toJson<String>(shelfId),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'position': serializer.toJson<int>(position),
    };
  }

  ShelfItemsTableData copyWith({
    String? shelfId,
    String? mediaItemId,
    int? position,
  }) => ShelfItemsTableData(
    shelfId: shelfId ?? this.shelfId,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    position: position ?? this.position,
  );
  ShelfItemsTableData copyWithCompanion(ShelfItemsTableCompanion data) {
    return ShelfItemsTableData(
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShelfItemsTableData(')
          ..write('shelfId: $shelfId, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(shelfId, mediaItemId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShelfItemsTableData &&
          other.shelfId == this.shelfId &&
          other.mediaItemId == this.mediaItemId &&
          other.position == this.position);
}

class ShelfItemsTableCompanion extends UpdateCompanion<ShelfItemsTableData> {
  final Value<String> shelfId;
  final Value<String> mediaItemId;
  final Value<int> position;
  final Value<int> rowid;
  const ShelfItemsTableCompanion({
    this.shelfId = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShelfItemsTableCompanion.insert({
    required String shelfId,
    required String mediaItemId,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : shelfId = Value(shelfId),
       mediaItemId = Value(mediaItemId);
  static Insertable<ShelfItemsTableData> custom({
    Expression<String>? shelfId,
    Expression<String>? mediaItemId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (shelfId != null) 'shelf_id': shelfId,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShelfItemsTableCompanion copyWith({
    Value<String>? shelfId,
    Value<String>? mediaItemId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return ShelfItemsTableCompanion(
      shelfId: shelfId ?? this.shelfId,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shelfId.present) {
      map['shelf_id'] = Variable<String>(shelfId.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelfItemsTableCompanion(')
          ..write('shelfId: $shelfId, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BarcodeCacheTableTable extends BarcodeCacheTable
    with TableInfo<$BarcodeCacheTableTable, BarcodeCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarcodeCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeHintMeta = const VerificationMeta(
    'mediaTypeHint',
  );
  @override
  late final GeneratedColumn<String> mediaTypeHint = GeneratedColumn<String>(
    'media_type_hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseJsonMeta = const VerificationMeta(
    'responseJson',
  );
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
    'response_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceApiMeta = const VerificationMeta(
    'sourceApi',
  );
  @override
  late final GeneratedColumn<String> sourceApi = GeneratedColumn<String>(
    'source_api',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<int> cachedAt = GeneratedColumn<int>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    barcode,
    mediaTypeHint,
    responseJson,
    sourceApi,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barcode_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<BarcodeCacheTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('media_type_hint')) {
      context.handle(
        _mediaTypeHintMeta,
        mediaTypeHint.isAcceptableOrUnknown(
          data['media_type_hint']!,
          _mediaTypeHintMeta,
        ),
      );
    }
    if (data.containsKey('response_json')) {
      context.handle(
        _responseJsonMeta,
        responseJson.isAcceptableOrUnknown(
          data['response_json']!,
          _responseJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseJsonMeta);
    }
    if (data.containsKey('source_api')) {
      context.handle(
        _sourceApiMeta,
        sourceApi.isAcceptableOrUnknown(data['source_api']!, _sourceApiMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceApiMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {barcode};
  @override
  BarcodeCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarcodeCacheTableData(
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      mediaTypeHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type_hint'],
      ),
      responseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_json'],
      )!,
      sourceApi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_api'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $BarcodeCacheTableTable createAlias(String alias) {
    return $BarcodeCacheTableTable(attachedDatabase, alias);
  }
}

class BarcodeCacheTableData extends DataClass
    implements Insertable<BarcodeCacheTableData> {
  final String barcode;
  final String? mediaTypeHint;
  final String responseJson;
  final String sourceApi;
  final int cachedAt;
  const BarcodeCacheTableData({
    required this.barcode,
    this.mediaTypeHint,
    required this.responseJson,
    required this.sourceApi,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['barcode'] = Variable<String>(barcode);
    if (!nullToAbsent || mediaTypeHint != null) {
      map['media_type_hint'] = Variable<String>(mediaTypeHint);
    }
    map['response_json'] = Variable<String>(responseJson);
    map['source_api'] = Variable<String>(sourceApi);
    map['cached_at'] = Variable<int>(cachedAt);
    return map;
  }

  BarcodeCacheTableCompanion toCompanion(bool nullToAbsent) {
    return BarcodeCacheTableCompanion(
      barcode: Value(barcode),
      mediaTypeHint: mediaTypeHint == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaTypeHint),
      responseJson: Value(responseJson),
      sourceApi: Value(sourceApi),
      cachedAt: Value(cachedAt),
    );
  }

  factory BarcodeCacheTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarcodeCacheTableData(
      barcode: serializer.fromJson<String>(json['barcode']),
      mediaTypeHint: serializer.fromJson<String?>(json['mediaTypeHint']),
      responseJson: serializer.fromJson<String>(json['responseJson']),
      sourceApi: serializer.fromJson<String>(json['sourceApi']),
      cachedAt: serializer.fromJson<int>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'barcode': serializer.toJson<String>(barcode),
      'mediaTypeHint': serializer.toJson<String?>(mediaTypeHint),
      'responseJson': serializer.toJson<String>(responseJson),
      'sourceApi': serializer.toJson<String>(sourceApi),
      'cachedAt': serializer.toJson<int>(cachedAt),
    };
  }

  BarcodeCacheTableData copyWith({
    String? barcode,
    Value<String?> mediaTypeHint = const Value.absent(),
    String? responseJson,
    String? sourceApi,
    int? cachedAt,
  }) => BarcodeCacheTableData(
    barcode: barcode ?? this.barcode,
    mediaTypeHint: mediaTypeHint.present
        ? mediaTypeHint.value
        : this.mediaTypeHint,
    responseJson: responseJson ?? this.responseJson,
    sourceApi: sourceApi ?? this.sourceApi,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  BarcodeCacheTableData copyWithCompanion(BarcodeCacheTableCompanion data) {
    return BarcodeCacheTableData(
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      mediaTypeHint: data.mediaTypeHint.present
          ? data.mediaTypeHint.value
          : this.mediaTypeHint,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      sourceApi: data.sourceApi.present ? data.sourceApi.value : this.sourceApi,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarcodeCacheTableData(')
          ..write('barcode: $barcode, ')
          ..write('mediaTypeHint: $mediaTypeHint, ')
          ..write('responseJson: $responseJson, ')
          ..write('sourceApi: $sourceApi, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(barcode, mediaTypeHint, responseJson, sourceApi, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarcodeCacheTableData &&
          other.barcode == this.barcode &&
          other.mediaTypeHint == this.mediaTypeHint &&
          other.responseJson == this.responseJson &&
          other.sourceApi == this.sourceApi &&
          other.cachedAt == this.cachedAt);
}

class BarcodeCacheTableCompanion
    extends UpdateCompanion<BarcodeCacheTableData> {
  final Value<String> barcode;
  final Value<String?> mediaTypeHint;
  final Value<String> responseJson;
  final Value<String> sourceApi;
  final Value<int> cachedAt;
  final Value<int> rowid;
  const BarcodeCacheTableCompanion({
    this.barcode = const Value.absent(),
    this.mediaTypeHint = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.sourceApi = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BarcodeCacheTableCompanion.insert({
    required String barcode,
    this.mediaTypeHint = const Value.absent(),
    required String responseJson,
    required String sourceApi,
    required int cachedAt,
    this.rowid = const Value.absent(),
  }) : barcode = Value(barcode),
       responseJson = Value(responseJson),
       sourceApi = Value(sourceApi),
       cachedAt = Value(cachedAt);
  static Insertable<BarcodeCacheTableData> custom({
    Expression<String>? barcode,
    Expression<String>? mediaTypeHint,
    Expression<String>? responseJson,
    Expression<String>? sourceApi,
    Expression<int>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (barcode != null) 'barcode': barcode,
      if (mediaTypeHint != null) 'media_type_hint': mediaTypeHint,
      if (responseJson != null) 'response_json': responseJson,
      if (sourceApi != null) 'source_api': sourceApi,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BarcodeCacheTableCompanion copyWith({
    Value<String>? barcode,
    Value<String?>? mediaTypeHint,
    Value<String>? responseJson,
    Value<String>? sourceApi,
    Value<int>? cachedAt,
    Value<int>? rowid,
  }) {
    return BarcodeCacheTableCompanion(
      barcode: barcode ?? this.barcode,
      mediaTypeHint: mediaTypeHint ?? this.mediaTypeHint,
      responseJson: responseJson ?? this.responseJson,
      sourceApi: sourceApi ?? this.sourceApi,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (mediaTypeHint.present) {
      map['media_type_hint'] = Variable<String>(mediaTypeHint.value);
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (sourceApi.present) {
      map['source_api'] = Variable<String>(sourceApi.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarcodeCacheTableCompanion(')
          ..write('barcode: $barcode, ')
          ..write('mediaTypeHint: $mediaTypeHint, ')
          ..write('responseJson: $responseJson, ')
          ..write('sourceApi: $sourceApi, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncLogTableTable extends SyncLogTable
    with TableInfo<$SyncLogTableTable, SyncLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptedAtMeta = const VerificationMeta(
    'attemptedAt',
  );
  @override
  late final GeneratedColumn<int> attemptedAt = GeneratedColumn<int>(
    'attempted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<int> synced = GeneratedColumn<int>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    createdAt,
    attemptedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempted_at')) {
      context.handle(
        _attemptedAtMeta,
        attemptedAt.isAcceptableOrUnknown(
          data['attempted_at']!,
          _attemptedAtMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      attemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempted_at'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $SyncLogTableTable createAlias(String alias) {
    return $SyncLogTableTable(attachedDatabase, alias);
  }
}

class SyncLogTableData extends DataClass
    implements Insertable<SyncLogTableData> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payloadJson;
  final int createdAt;
  final int? attemptedAt;
  final int synced;
  const SyncLogTableData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    this.attemptedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || attemptedAt != null) {
      map['attempted_at'] = Variable<int>(attemptedAt);
    }
    map['synced'] = Variable<int>(synced);
    return map;
  }

  SyncLogTableCompanion toCompanion(bool nullToAbsent) {
    return SyncLogTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attemptedAt: attemptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(attemptedAt),
      synced: Value(synced),
    );
  }

  factory SyncLogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLogTableData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      attemptedAt: serializer.fromJson<int?>(json['attemptedAt']),
      synced: serializer.fromJson<int>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'attemptedAt': serializer.toJson<int?>(attemptedAt),
      'synced': serializer.toJson<int>(synced),
    };
  }

  SyncLogTableData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payloadJson,
    int? createdAt,
    Value<int?> attemptedAt = const Value.absent(),
    int? synced,
  }) => SyncLogTableData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attemptedAt: attemptedAt.present ? attemptedAt.value : this.attemptedAt,
    synced: synced ?? this.synced,
  );
  SyncLogTableData copyWithCompanion(SyncLogTableCompanion data) {
    return SyncLogTableData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptedAt: data.attemptedAt.present
          ? data.attemptedAt.value
          : this.attemptedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogTableData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptedAt: $attemptedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    createdAt,
    attemptedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLogTableData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attemptedAt == this.attemptedAt &&
          other.synced == this.synced);
}

class SyncLogTableCompanion extends UpdateCompanion<SyncLogTableData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<int> createdAt;
  final Value<int?> attemptedAt;
  final Value<int> synced;
  final Value<int> rowid;
  const SyncLogTableCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncLogTableCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
    required int createdAt,
    this.attemptedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncLogTableData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<int>? createdAt,
    Expression<int>? attemptedAt,
    Expression<int>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptedAt != null) 'attempted_at': attemptedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncLogTableCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<int>? createdAt,
    Value<int?>? attemptedAt,
    Value<int>? synced,
    Value<int>? rowid,
  }) {
    return SyncLogTableCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attemptedAt: attemptedAt ?? this.attemptedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (attemptedAt.present) {
      map['attempted_at'] = Variable<int>(attemptedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<int>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogTableCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptedAt: $attemptedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BorrowersTableTable extends BorrowersTable
    with TableInfo<$BorrowersTableTable, BorrowersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BorrowersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    phone,
    notes,
    updatedAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'borrowers';
  @override
  VerificationContext validateIntegrity(
    Insertable<BorrowersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BorrowersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BorrowersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $BorrowersTableTable createAlias(String alias) {
    return $BorrowersTableTable(attachedDatabase, alias);
  }
}

class BorrowersTableData extends DataClass
    implements Insertable<BorrowersTableData> {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? notes;
  final int updatedAt;
  final int deleted;
  const BorrowersTableData({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.notes,
    required this.updatedAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  BorrowersTableCompanion toCompanion(bool nullToAbsent) {
    return BorrowersTableCompanion(
      id: Value(id),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
    );
  }

  factory BorrowersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BorrowersTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  BorrowersTableData copyWith({
    String? id,
    String? name,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? updatedAt,
    int? deleted,
  }) => BorrowersTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
  BorrowersTableData copyWithCompanion(BorrowersTableCompanion data) {
    return BorrowersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BorrowersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, phone, notes, updatedAt, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BorrowersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted);
}

class BorrowersTableCompanion extends UpdateCompanion<BorrowersTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> notes;
  final Value<int> updatedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const BorrowersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BorrowersTableCompanion.insert({
    required String id,
    required String name,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    required int updatedAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<BorrowersTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? notes,
    Expression<int>? updatedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BorrowersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? notes,
    Value<int>? updatedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return BorrowersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BorrowersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTableTable extends LoansTable
    with TableInfo<$LoansTableTable, LoansTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id)',
    ),
  );
  static const VerificationMeta _borrowerIdMeta = const VerificationMeta(
    'borrowerId',
  );
  @override
  late final GeneratedColumn<String> borrowerId = GeneratedColumn<String>(
    'borrower_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES borrowers (id)',
    ),
  );
  static const VerificationMeta _lentAtMeta = const VerificationMeta('lentAt');
  @override
  late final GeneratedColumn<int> lentAt = GeneratedColumn<int>(
    'lent_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returnedAtMeta = const VerificationMeta(
    'returnedAt',
  );
  @override
  late final GeneratedColumn<int> returnedAt = GeneratedColumn<int>(
    'returned_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    borrowerId,
    lentAt,
    returnedAt,
    notes,
    updatedAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoansTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('borrower_id')) {
      context.handle(
        _borrowerIdMeta,
        borrowerId.isAcceptableOrUnknown(data['borrower_id']!, _borrowerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_borrowerIdMeta);
    }
    if (data.containsKey('lent_at')) {
      context.handle(
        _lentAtMeta,
        lentAt.isAcceptableOrUnknown(data['lent_at']!, _lentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lentAtMeta);
    }
    if (data.containsKey('returned_at')) {
      context.handle(
        _returnedAtMeta,
        returnedAt.isAcceptableOrUnknown(data['returned_at']!, _returnedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoansTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoansTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      borrowerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}borrower_id'],
      )!,
      lentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lent_at'],
      )!,
      returnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}returned_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $LoansTableTable createAlias(String alias) {
    return $LoansTableTable(attachedDatabase, alias);
  }
}

class LoansTableData extends DataClass implements Insertable<LoansTableData> {
  final String id;
  final String mediaItemId;
  final String borrowerId;
  final int lentAt;
  final int? returnedAt;
  final String? notes;
  final int updatedAt;
  final int deleted;
  const LoansTableData({
    required this.id,
    required this.mediaItemId,
    required this.borrowerId,
    required this.lentAt,
    this.returnedAt,
    this.notes,
    required this.updatedAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['borrower_id'] = Variable<String>(borrowerId);
    map['lent_at'] = Variable<int>(lentAt);
    if (!nullToAbsent || returnedAt != null) {
      map['returned_at'] = Variable<int>(returnedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  LoansTableCompanion toCompanion(bool nullToAbsent) {
    return LoansTableCompanion(
      id: Value(id),
      mediaItemId: Value(mediaItemId),
      borrowerId: Value(borrowerId),
      lentAt: Value(lentAt),
      returnedAt: returnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
    );
  }

  factory LoansTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoansTableData(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      borrowerId: serializer.fromJson<String>(json['borrowerId']),
      lentAt: serializer.fromJson<int>(json['lentAt']),
      returnedAt: serializer.fromJson<int?>(json['returnedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'borrowerId': serializer.toJson<String>(borrowerId),
      'lentAt': serializer.toJson<int>(lentAt),
      'returnedAt': serializer.toJson<int?>(returnedAt),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  LoansTableData copyWith({
    String? id,
    String? mediaItemId,
    String? borrowerId,
    int? lentAt,
    Value<int?> returnedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? updatedAt,
    int? deleted,
  }) => LoansTableData(
    id: id ?? this.id,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    borrowerId: borrowerId ?? this.borrowerId,
    lentAt: lentAt ?? this.lentAt,
    returnedAt: returnedAt.present ? returnedAt.value : this.returnedAt,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
  LoansTableData copyWithCompanion(LoansTableCompanion data) {
    return LoansTableData(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      borrowerId: data.borrowerId.present
          ? data.borrowerId.value
          : this.borrowerId,
      lentAt: data.lentAt.present ? data.lentAt.value : this.lentAt,
      returnedAt: data.returnedAt.present
          ? data.returnedAt.value
          : this.returnedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoansTableData(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('borrowerId: $borrowerId, ')
          ..write('lentAt: $lentAt, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaItemId,
    borrowerId,
    lentAt,
    returnedAt,
    notes,
    updatedAt,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoansTableData &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.borrowerId == this.borrowerId &&
          other.lentAt == this.lentAt &&
          other.returnedAt == this.returnedAt &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted);
}

class LoansTableCompanion extends UpdateCompanion<LoansTableData> {
  final Value<String> id;
  final Value<String> mediaItemId;
  final Value<String> borrowerId;
  final Value<int> lentAt;
  final Value<int?> returnedAt;
  final Value<String?> notes;
  final Value<int> updatedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const LoansTableCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.borrowerId = const Value.absent(),
    this.lentAt = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansTableCompanion.insert({
    required String id,
    required String mediaItemId,
    required String borrowerId,
    required int lentAt,
    this.returnedAt = const Value.absent(),
    this.notes = const Value.absent(),
    required int updatedAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaItemId = Value(mediaItemId),
       borrowerId = Value(borrowerId),
       lentAt = Value(lentAt),
       updatedAt = Value(updatedAt);
  static Insertable<LoansTableData> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<String>? borrowerId,
    Expression<int>? lentAt,
    Expression<int>? returnedAt,
    Expression<String>? notes,
    Expression<int>? updatedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (borrowerId != null) 'borrower_id': borrowerId,
      if (lentAt != null) 'lent_at': lentAt,
      if (returnedAt != null) 'returned_at': returnedAt,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansTableCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaItemId,
    Value<String>? borrowerId,
    Value<int>? lentAt,
    Value<int?>? returnedAt,
    Value<String?>? notes,
    Value<int>? updatedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return LoansTableCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      borrowerId: borrowerId ?? this.borrowerId,
      lentAt: lentAt ?? this.lentAt,
      returnedAt: returnedAt ?? this.returnedAt,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (borrowerId.present) {
      map['borrower_id'] = Variable<String>(borrowerId.value);
    }
    if (lentAt.present) {
      map['lent_at'] = Variable<int>(lentAt.value);
    }
    if (returnedAt.present) {
      map['returned_at'] = Variable<int>(returnedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansTableCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('borrowerId: $borrowerId, ')
          ..write('lentAt: $lentAt, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MediaItemsTableTable mediaItemsTable = $MediaItemsTableTable(
    this,
  );
  late final $TagsTableTable tagsTable = $TagsTableTable(this);
  late final $MediaItemTagsTableTable mediaItemTagsTable =
      $MediaItemTagsTableTable(this);
  late final $ShelvesTableTable shelvesTable = $ShelvesTableTable(this);
  late final $ShelfItemsTableTable shelfItemsTable = $ShelfItemsTableTable(
    this,
  );
  late final $BarcodeCacheTableTable barcodeCacheTable =
      $BarcodeCacheTableTable(this);
  late final $SyncLogTableTable syncLogTable = $SyncLogTableTable(this);
  late final $BorrowersTableTable borrowersTable = $BorrowersTableTable(this);
  late final $LoansTableTable loansTable = $LoansTableTable(this);
  late final MediaItemsDao mediaItemsDao = MediaItemsDao(this as AppDatabase);
  late final TagsDao tagsDao = TagsDao(this as AppDatabase);
  late final ShelvesDao shelvesDao = ShelvesDao(this as AppDatabase);
  late final BarcodeCacheDao barcodeCacheDao = BarcodeCacheDao(
    this as AppDatabase,
  );
  late final SyncLogDao syncLogDao = SyncLogDao(this as AppDatabase);
  late final BorrowersDao borrowersDao = BorrowersDao(this as AppDatabase);
  late final LoansDao loansDao = LoansDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mediaItemsTable,
    tagsTable,
    mediaItemTagsTable,
    shelvesTable,
    shelfItemsTable,
    barcodeCacheTable,
    syncLogTable,
    borrowersTable,
    loansTable,
  ];
}

typedef $$MediaItemsTableTableCreateCompanionBuilder =
    MediaItemsTableCompanion Function({
      required String id,
      required String barcode,
      required String barcodeType,
      required String mediaType,
      required String title,
      Value<String?> subtitle,
      Value<String?> description,
      Value<String?> coverUrl,
      Value<int?> year,
      Value<String?> publisher,
      Value<String?> format,
      Value<String> genres,
      Value<String> extraMetadata,
      Value<String> sourceApis,
      Value<double?> userRating,
      Value<String?> userReview,
      Value<double?> criticScore,
      Value<String?> criticSource,
      required int dateAdded,
      required int dateScanned,
      required int updatedAt,
      Value<int?> syncedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$MediaItemsTableTableUpdateCompanionBuilder =
    MediaItemsTableCompanion Function({
      Value<String> id,
      Value<String> barcode,
      Value<String> barcodeType,
      Value<String> mediaType,
      Value<String> title,
      Value<String?> subtitle,
      Value<String?> description,
      Value<String?> coverUrl,
      Value<int?> year,
      Value<String?> publisher,
      Value<String?> format,
      Value<String> genres,
      Value<String> extraMetadata,
      Value<String> sourceApis,
      Value<double?> userRating,
      Value<String?> userReview,
      Value<double?> criticScore,
      Value<String?> criticSource,
      Value<int> dateAdded,
      Value<int> dateScanned,
      Value<int> updatedAt,
      Value<int?> syncedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

final class $$MediaItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MediaItemsTableTable,
          MediaItemsTableData
        > {
  $$MediaItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $MediaItemTagsTableTable,
    List<MediaItemTagsTableData>
  >
  _mediaItemTagsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mediaItemTagsTable,
        aliasName: $_aliasNameGenerator(
          db.mediaItemsTable.id,
          db.mediaItemTagsTable.mediaItemId,
        ),
      );

  $$MediaItemTagsTableTableProcessedTableManager get mediaItemTagsTableRefs {
    final manager = $$MediaItemTagsTableTableTableManager(
      $_db,
      $_db.mediaItemTagsTable,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mediaItemTagsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShelfItemsTableTable, List<ShelfItemsTableData>>
  _shelfItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shelfItemsTable,
    aliasName: $_aliasNameGenerator(
      db.mediaItemsTable.id,
      db.shelfItemsTable.mediaItemId,
    ),
  );

  $$ShelfItemsTableTableProcessedTableManager get shelfItemsTableRefs {
    final manager = $$ShelfItemsTableTableTableManager(
      $_db,
      $_db.shelfItemsTable,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _shelfItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoansTableTable, List<LoansTableData>>
  _loansTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.loansTable,
    aliasName: $_aliasNameGenerator(
      db.mediaItemsTable.id,
      db.loansTable.mediaItemId,
    ),
  );

  $$LoansTableTableProcessedTableManager get loansTableRefs {
    final manager = $$LoansTableTableTableManager(
      $_db,
      $_db.loansTable,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MediaItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTableTable> {
  $$MediaItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcodeType => $composableBuilder(
    column: $table.barcodeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraMetadata => $composableBuilder(
    column: $table.extraMetadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceApis => $composableBuilder(
    column: $table.sourceApis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userReview => $composableBuilder(
    column: $table.userReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get criticScore => $composableBuilder(
    column: $table.criticScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criticSource => $composableBuilder(
    column: $table.criticSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mediaItemTagsTableRefs(
    Expression<bool> Function($$MediaItemTagsTableTableFilterComposer f) f,
  ) {
    final $$MediaItemTagsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaItemTagsTable,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemTagsTableTableFilterComposer(
            $db: $db,
            $table: $db.mediaItemTagsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shelfItemsTableRefs(
    Expression<bool> Function($$ShelfItemsTableTableFilterComposer f) f,
  ) {
    final $$ShelfItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfItemsTable,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.shelfItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loansTableRefs(
    Expression<bool> Function($$LoansTableTableFilterComposer f) f,
  ) {
    final $$LoansTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loansTable,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableTableFilterComposer(
            $db: $db,
            $table: $db.loansTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTableTable> {
  $$MediaItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcodeType => $composableBuilder(
    column: $table.barcodeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraMetadata => $composableBuilder(
    column: $table.extraMetadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceApis => $composableBuilder(
    column: $table.sourceApis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userReview => $composableBuilder(
    column: $table.userReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get criticScore => $composableBuilder(
    column: $table.criticScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criticSource => $composableBuilder(
    column: $table.criticSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTableTable> {
  $$MediaItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get barcodeType => $composableBuilder(
    column: $table.barcodeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<String> get extraMetadata => $composableBuilder(
    column: $table.extraMetadata,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceApis => $composableBuilder(
    column: $table.sourceApis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userReview => $composableBuilder(
    column: $table.userReview,
    builder: (column) => column,
  );

  GeneratedColumn<double> get criticScore => $composableBuilder(
    column: $table.criticScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get criticSource => $composableBuilder(
    column: $table.criticSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<int> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> mediaItemTagsTableRefs<T extends Object>(
    Expression<T> Function($$MediaItemTagsTableTableAnnotationComposer a) f,
  ) {
    final $$MediaItemTagsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mediaItemTagsTable,
          getReferencedColumn: (t) => t.mediaItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MediaItemTagsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.mediaItemTagsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> shelfItemsTableRefs<T extends Object>(
    Expression<T> Function($$ShelfItemsTableTableAnnotationComposer a) f,
  ) {
    final $$ShelfItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfItemsTable,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loansTableRefs<T extends Object>(
    Expression<T> Function($$LoansTableTableAnnotationComposer a) f,
  ) {
    final $$LoansTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loansTable,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableTableAnnotationComposer(
            $db: $db,
            $table: $db.loansTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTableTable,
          MediaItemsTableData,
          $$MediaItemsTableTableFilterComposer,
          $$MediaItemsTableTableOrderingComposer,
          $$MediaItemsTableTableAnnotationComposer,
          $$MediaItemsTableTableCreateCompanionBuilder,
          $$MediaItemsTableTableUpdateCompanionBuilder,
          (MediaItemsTableData, $$MediaItemsTableTableReferences),
          MediaItemsTableData,
          PrefetchHooks Function({
            bool mediaItemTagsTableRefs,
            bool shelfItemsTableRefs,
            bool loansTableRefs,
          })
        > {
  $$MediaItemsTableTableTableManager(
    _$AppDatabase db,
    $MediaItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> barcode = const Value.absent(),
                Value<String> barcodeType = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String> genres = const Value.absent(),
                Value<String> extraMetadata = const Value.absent(),
                Value<String> sourceApis = const Value.absent(),
                Value<double?> userRating = const Value.absent(),
                Value<String?> userReview = const Value.absent(),
                Value<double?> criticScore = const Value.absent(),
                Value<String?> criticSource = const Value.absent(),
                Value<int> dateAdded = const Value.absent(),
                Value<int> dateScanned = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsTableCompanion(
                id: id,
                barcode: barcode,
                barcodeType: barcodeType,
                mediaType: mediaType,
                title: title,
                subtitle: subtitle,
                description: description,
                coverUrl: coverUrl,
                year: year,
                publisher: publisher,
                format: format,
                genres: genres,
                extraMetadata: extraMetadata,
                sourceApis: sourceApis,
                userRating: userRating,
                userReview: userReview,
                criticScore: criticScore,
                criticSource: criticSource,
                dateAdded: dateAdded,
                dateScanned: dateScanned,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String barcode,
                required String barcodeType,
                required String mediaType,
                required String title,
                Value<String?> subtitle = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> format = const Value.absent(),
                Value<String> genres = const Value.absent(),
                Value<String> extraMetadata = const Value.absent(),
                Value<String> sourceApis = const Value.absent(),
                Value<double?> userRating = const Value.absent(),
                Value<String?> userReview = const Value.absent(),
                Value<double?> criticScore = const Value.absent(),
                Value<String?> criticSource = const Value.absent(),
                required int dateAdded,
                required int dateScanned,
                required int updatedAt,
                Value<int?> syncedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsTableCompanion.insert(
                id: id,
                barcode: barcode,
                barcodeType: barcodeType,
                mediaType: mediaType,
                title: title,
                subtitle: subtitle,
                description: description,
                coverUrl: coverUrl,
                year: year,
                publisher: publisher,
                format: format,
                genres: genres,
                extraMetadata: extraMetadata,
                sourceApis: sourceApis,
                userRating: userRating,
                userReview: userReview,
                criticScore: criticScore,
                criticSource: criticSource,
                dateAdded: dateAdded,
                dateScanned: dateScanned,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                mediaItemTagsTableRefs = false,
                shelfItemsTableRefs = false,
                loansTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mediaItemTagsTableRefs) db.mediaItemTagsTable,
                    if (shelfItemsTableRefs) db.shelfItemsTable,
                    if (loansTableRefs) db.loansTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mediaItemTagsTableRefs)
                        await $_getPrefetchedData<
                          MediaItemsTableData,
                          $MediaItemsTableTable,
                          MediaItemTagsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableTableReferences
                              ._mediaItemTagsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaItemTagsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shelfItemsTableRefs)
                        await $_getPrefetchedData<
                          MediaItemsTableData,
                          $MediaItemsTableTable,
                          ShelfItemsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableTableReferences
                              ._shelfItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).shelfItemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (loansTableRefs)
                        await $_getPrefetchedData<
                          MediaItemsTableData,
                          $MediaItemsTableTable,
                          LoansTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableTableReferences
                              ._loansTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).loansTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MediaItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTableTable,
      MediaItemsTableData,
      $$MediaItemsTableTableFilterComposer,
      $$MediaItemsTableTableOrderingComposer,
      $$MediaItemsTableTableAnnotationComposer,
      $$MediaItemsTableTableCreateCompanionBuilder,
      $$MediaItemsTableTableUpdateCompanionBuilder,
      (MediaItemsTableData, $$MediaItemsTableTableReferences),
      MediaItemsTableData,
      PrefetchHooks Function({
        bool mediaItemTagsTableRefs,
        bool shelfItemsTableRefs,
        bool loansTableRefs,
      })
    >;
typedef $$TagsTableTableCreateCompanionBuilder =
    TagsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> colour,
      required int updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$TagsTableTableUpdateCompanionBuilder =
    TagsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> colour,
      Value<int> updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

final class $$TagsTableTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTableTable, TagsTableData> {
  $$TagsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $MediaItemTagsTableTable,
    List<MediaItemTagsTableData>
  >
  _mediaItemTagsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mediaItemTagsTable,
        aliasName: $_aliasNameGenerator(
          db.tagsTable.id,
          db.mediaItemTagsTable.tagId,
        ),
      );

  $$MediaItemTagsTableTableProcessedTableManager get mediaItemTagsTableRefs {
    final manager = $$MediaItemTagsTableTableTableManager(
      $_db,
      $_db.mediaItemTagsTable,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mediaItemTagsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TagsTableTable> {
  $$TagsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mediaItemTagsTableRefs(
    Expression<bool> Function($$MediaItemTagsTableTableFilterComposer f) f,
  ) {
    final $$MediaItemTagsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaItemTagsTable,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemTagsTableTableFilterComposer(
            $db: $db,
            $table: $db.mediaItemTagsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TagsTableTable> {
  $$TagsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTableTable> {
  $$TagsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colour =>
      $composableBuilder(column: $table.colour, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> mediaItemTagsTableRefs<T extends Object>(
    Expression<T> Function($$MediaItemTagsTableTableAnnotationComposer a) f,
  ) {
    final $$MediaItemTagsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mediaItemTagsTable,
          getReferencedColumn: (t) => t.tagId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MediaItemTagsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.mediaItemTagsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TagsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTableTable,
          TagsTableData,
          $$TagsTableTableFilterComposer,
          $$TagsTableTableOrderingComposer,
          $$TagsTableTableAnnotationComposer,
          $$TagsTableTableCreateCompanionBuilder,
          $$TagsTableTableUpdateCompanionBuilder,
          (TagsTableData, $$TagsTableTableReferences),
          TagsTableData,
          PrefetchHooks Function({bool mediaItemTagsTableRefs})
        > {
  $$TagsTableTableTableManager(_$AppDatabase db, $TagsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsTableCompanion(
                id: id,
                name: name,
                colour: colour,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> colour = const Value.absent(),
                required int updatedAt,
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsTableCompanion.insert(
                id: id,
                name: name,
                colour: colour,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TagsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaItemTagsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mediaItemTagsTableRefs) db.mediaItemTagsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mediaItemTagsTableRefs)
                    await $_getPrefetchedData<
                      TagsTableData,
                      $TagsTableTable,
                      MediaItemTagsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$TagsTableTableReferences
                          ._mediaItemTagsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).mediaItemTagsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTableTable,
      TagsTableData,
      $$TagsTableTableFilterComposer,
      $$TagsTableTableOrderingComposer,
      $$TagsTableTableAnnotationComposer,
      $$TagsTableTableCreateCompanionBuilder,
      $$TagsTableTableUpdateCompanionBuilder,
      (TagsTableData, $$TagsTableTableReferences),
      TagsTableData,
      PrefetchHooks Function({bool mediaItemTagsTableRefs})
    >;
typedef $$MediaItemTagsTableTableCreateCompanionBuilder =
    MediaItemTagsTableCompanion Function({
      required String mediaItemId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$MediaItemTagsTableTableUpdateCompanionBuilder =
    MediaItemTagsTableCompanion Function({
      Value<String> mediaItemId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$MediaItemTagsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MediaItemTagsTableTable,
          MediaItemTagsTableData
        > {
  $$MediaItemTagsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaItemsTableTable _mediaItemIdTable(_$AppDatabase db) =>
      db.mediaItemsTable.createAlias(
        $_aliasNameGenerator(
          db.mediaItemTagsTable.mediaItemId,
          db.mediaItemsTable.id,
        ),
      );

  $$MediaItemsTableTableProcessedTableManager get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id')!;

    final manager = $$MediaItemsTableTableTableManager(
      $_db,
      $_db.mediaItemsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTableTable _tagIdTable(_$AppDatabase db) =>
      db.tagsTable.createAlias(
        $_aliasNameGenerator(db.mediaItemTagsTable.tagId, db.tagsTable.id),
      );

  $$TagsTableTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableTableManager(
      $_db,
      $_db.tagsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaItemTagsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemTagsTableTable> {
  $$MediaItemTagsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MediaItemsTableTableFilterComposer get mediaItemId {
    final $$MediaItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableTableFilterComposer get tagId {
    final $$TagsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tagsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableTableFilterComposer(
            $db: $db,
            $table: $db.tagsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaItemTagsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemTagsTableTable> {
  $$MediaItemTagsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MediaItemsTableTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableTableOrderingComposer get tagId {
    final $$TagsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tagsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableTableOrderingComposer(
            $db: $db,
            $table: $db.tagsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaItemTagsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemTagsTableTable> {
  $$MediaItemTagsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MediaItemsTableTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableTableAnnotationComposer get tagId {
    final $$TagsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tagsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.tagsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaItemTagsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemTagsTableTable,
          MediaItemTagsTableData,
          $$MediaItemTagsTableTableFilterComposer,
          $$MediaItemTagsTableTableOrderingComposer,
          $$MediaItemTagsTableTableAnnotationComposer,
          $$MediaItemTagsTableTableCreateCompanionBuilder,
          $$MediaItemTagsTableTableUpdateCompanionBuilder,
          (MediaItemTagsTableData, $$MediaItemTagsTableTableReferences),
          MediaItemTagsTableData,
          PrefetchHooks Function({bool mediaItemId, bool tagId})
        > {
  $$MediaItemTagsTableTableTableManager(
    _$AppDatabase db,
    $MediaItemTagsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemTagsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemTagsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemTagsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaItemId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemTagsTableCompanion(
                mediaItemId: mediaItemId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaItemId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => MediaItemTagsTableCompanion.insert(
                mediaItemId: mediaItemId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaItemTagsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaItemId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaItemId,
                                referencedTable:
                                    $$MediaItemTagsTableTableReferences
                                        ._mediaItemIdTable(db),
                                referencedColumn:
                                    $$MediaItemTagsTableTableReferences
                                        ._mediaItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable:
                                    $$MediaItemTagsTableTableReferences
                                        ._tagIdTable(db),
                                referencedColumn:
                                    $$MediaItemTagsTableTableReferences
                                        ._tagIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MediaItemTagsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemTagsTableTable,
      MediaItemTagsTableData,
      $$MediaItemTagsTableTableFilterComposer,
      $$MediaItemTagsTableTableOrderingComposer,
      $$MediaItemTagsTableTableAnnotationComposer,
      $$MediaItemTagsTableTableCreateCompanionBuilder,
      $$MediaItemTagsTableTableUpdateCompanionBuilder,
      (MediaItemTagsTableData, $$MediaItemTagsTableTableReferences),
      MediaItemTagsTableData,
      PrefetchHooks Function({bool mediaItemId, bool tagId})
    >;
typedef $$ShelvesTableTableCreateCompanionBuilder =
    ShelvesTableCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<int> sortOrder,
      required int updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$ShelvesTableTableUpdateCompanionBuilder =
    ShelvesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<int> sortOrder,
      Value<int> updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

final class $$ShelvesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ShelvesTableTable, ShelvesTableData> {
  $$ShelvesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShelfItemsTableTable, List<ShelfItemsTableData>>
  _shelfItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shelfItemsTable,
    aliasName: $_aliasNameGenerator(
      db.shelvesTable.id,
      db.shelfItemsTable.shelfId,
    ),
  );

  $$ShelfItemsTableTableProcessedTableManager get shelfItemsTableRefs {
    final manager = $$ShelfItemsTableTableTableManager(
      $_db,
      $_db.shelfItemsTable,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _shelfItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelvesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShelvesTableTable> {
  $$ShelvesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shelfItemsTableRefs(
    Expression<bool> Function($$ShelfItemsTableTableFilterComposer f) f,
  ) {
    final $$ShelfItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfItemsTable,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.shelfItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelvesTableTable> {
  $$ShelvesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShelvesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelvesTableTable> {
  $$ShelvesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> shelfItemsTableRefs<T extends Object>(
    Expression<T> Function($$ShelfItemsTableTableAnnotationComposer a) f,
  ) {
    final $$ShelfItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfItemsTable,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelvesTableTable,
          ShelvesTableData,
          $$ShelvesTableTableFilterComposer,
          $$ShelvesTableTableOrderingComposer,
          $$ShelvesTableTableAnnotationComposer,
          $$ShelvesTableTableCreateCompanionBuilder,
          $$ShelvesTableTableUpdateCompanionBuilder,
          (ShelvesTableData, $$ShelvesTableTableReferences),
          ShelvesTableData,
          PrefetchHooks Function({bool shelfItemsTableRefs})
        > {
  $$ShelvesTableTableTableManager(_$AppDatabase db, $ShelvesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelvesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelvesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelvesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelvesTableCompanion(
                id: id,
                name: name,
                description: description,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int updatedAt,
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelvesTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShelvesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shelfItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (shelfItemsTableRefs) db.shelfItemsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shelfItemsTableRefs)
                    await $_getPrefetchedData<
                      ShelvesTableData,
                      $ShelvesTableTable,
                      ShelfItemsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$ShelvesTableTableReferences
                          ._shelfItemsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShelvesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).shelfItemsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shelfId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShelvesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelvesTableTable,
      ShelvesTableData,
      $$ShelvesTableTableFilterComposer,
      $$ShelvesTableTableOrderingComposer,
      $$ShelvesTableTableAnnotationComposer,
      $$ShelvesTableTableCreateCompanionBuilder,
      $$ShelvesTableTableUpdateCompanionBuilder,
      (ShelvesTableData, $$ShelvesTableTableReferences),
      ShelvesTableData,
      PrefetchHooks Function({bool shelfItemsTableRefs})
    >;
typedef $$ShelfItemsTableTableCreateCompanionBuilder =
    ShelfItemsTableCompanion Function({
      required String shelfId,
      required String mediaItemId,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$ShelfItemsTableTableUpdateCompanionBuilder =
    ShelfItemsTableCompanion Function({
      Value<String> shelfId,
      Value<String> mediaItemId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$ShelfItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ShelfItemsTableTable,
          ShelfItemsTableData
        > {
  $$ShelfItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ShelvesTableTable _shelfIdTable(_$AppDatabase db) =>
      db.shelvesTable.createAlias(
        $_aliasNameGenerator(db.shelfItemsTable.shelfId, db.shelvesTable.id),
      );

  $$ShelvesTableTableProcessedTableManager get shelfId {
    final $_column = $_itemColumn<String>('shelf_id')!;

    final manager = $$ShelvesTableTableTableManager(
      $_db,
      $_db.shelvesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MediaItemsTableTable _mediaItemIdTable(_$AppDatabase db) =>
      db.mediaItemsTable.createAlias(
        $_aliasNameGenerator(
          db.shelfItemsTable.mediaItemId,
          db.mediaItemsTable.id,
        ),
      );

  $$MediaItemsTableTableProcessedTableManager get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id')!;

    final manager = $$MediaItemsTableTableTableManager(
      $_db,
      $_db.mediaItemsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShelfItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShelfItemsTableTable> {
  $$ShelfItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$ShelvesTableTableFilterComposer get shelfId {
    final $$ShelvesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelvesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableTableFilterComposer(
            $db: $db,
            $table: $db.shelvesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaItemsTableTableFilterComposer get mediaItemId {
    final $$MediaItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelfItemsTableTable> {
  $$ShelfItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShelvesTableTableOrderingComposer get shelfId {
    final $$ShelvesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelvesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableTableOrderingComposer(
            $db: $db,
            $table: $db.shelvesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaItemsTableTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelfItemsTableTable> {
  $$ShelfItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$ShelvesTableTableAnnotationComposer get shelfId {
    final $$ShelvesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelvesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.shelvesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaItemsTableTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelfItemsTableTable,
          ShelfItemsTableData,
          $$ShelfItemsTableTableFilterComposer,
          $$ShelfItemsTableTableOrderingComposer,
          $$ShelfItemsTableTableAnnotationComposer,
          $$ShelfItemsTableTableCreateCompanionBuilder,
          $$ShelfItemsTableTableUpdateCompanionBuilder,
          (ShelfItemsTableData, $$ShelfItemsTableTableReferences),
          ShelfItemsTableData,
          PrefetchHooks Function({bool shelfId, bool mediaItemId})
        > {
  $$ShelfItemsTableTableTableManager(
    _$AppDatabase db,
    $ShelfItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelfItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelfItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelfItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> shelfId = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelfItemsTableCompanion(
                shelfId: shelfId,
                mediaItemId: mediaItemId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String shelfId,
                required String mediaItemId,
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelfItemsTableCompanion.insert(
                shelfId: shelfId,
                mediaItemId: mediaItemId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShelfItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shelfId = false, mediaItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shelfId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shelfId,
                                referencedTable:
                                    $$ShelfItemsTableTableReferences
                                        ._shelfIdTable(db),
                                referencedColumn:
                                    $$ShelfItemsTableTableReferences
                                        ._shelfIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (mediaItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaItemId,
                                referencedTable:
                                    $$ShelfItemsTableTableReferences
                                        ._mediaItemIdTable(db),
                                referencedColumn:
                                    $$ShelfItemsTableTableReferences
                                        ._mediaItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShelfItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelfItemsTableTable,
      ShelfItemsTableData,
      $$ShelfItemsTableTableFilterComposer,
      $$ShelfItemsTableTableOrderingComposer,
      $$ShelfItemsTableTableAnnotationComposer,
      $$ShelfItemsTableTableCreateCompanionBuilder,
      $$ShelfItemsTableTableUpdateCompanionBuilder,
      (ShelfItemsTableData, $$ShelfItemsTableTableReferences),
      ShelfItemsTableData,
      PrefetchHooks Function({bool shelfId, bool mediaItemId})
    >;
typedef $$BarcodeCacheTableTableCreateCompanionBuilder =
    BarcodeCacheTableCompanion Function({
      required String barcode,
      Value<String?> mediaTypeHint,
      required String responseJson,
      required String sourceApi,
      required int cachedAt,
      Value<int> rowid,
    });
typedef $$BarcodeCacheTableTableUpdateCompanionBuilder =
    BarcodeCacheTableCompanion Function({
      Value<String> barcode,
      Value<String?> mediaTypeHint,
      Value<String> responseJson,
      Value<String> sourceApi,
      Value<int> cachedAt,
      Value<int> rowid,
    });

class $$BarcodeCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $BarcodeCacheTableTable> {
  $$BarcodeCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaTypeHint => $composableBuilder(
    column: $table.mediaTypeHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceApi => $composableBuilder(
    column: $table.sourceApi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BarcodeCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BarcodeCacheTableTable> {
  $$BarcodeCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaTypeHint => $composableBuilder(
    column: $table.mediaTypeHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceApi => $composableBuilder(
    column: $table.sourceApi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BarcodeCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarcodeCacheTableTable> {
  $$BarcodeCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get mediaTypeHint => $composableBuilder(
    column: $table.mediaTypeHint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceApi =>
      $composableBuilder(column: $table.sourceApi, builder: (column) => column);

  GeneratedColumn<int> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$BarcodeCacheTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BarcodeCacheTableTable,
          BarcodeCacheTableData,
          $$BarcodeCacheTableTableFilterComposer,
          $$BarcodeCacheTableTableOrderingComposer,
          $$BarcodeCacheTableTableAnnotationComposer,
          $$BarcodeCacheTableTableCreateCompanionBuilder,
          $$BarcodeCacheTableTableUpdateCompanionBuilder,
          (
            BarcodeCacheTableData,
            BaseReferences<
              _$AppDatabase,
              $BarcodeCacheTableTable,
              BarcodeCacheTableData
            >,
          ),
          BarcodeCacheTableData,
          PrefetchHooks Function()
        > {
  $$BarcodeCacheTableTableTableManager(
    _$AppDatabase db,
    $BarcodeCacheTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarcodeCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarcodeCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarcodeCacheTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> barcode = const Value.absent(),
                Value<String?> mediaTypeHint = const Value.absent(),
                Value<String> responseJson = const Value.absent(),
                Value<String> sourceApi = const Value.absent(),
                Value<int> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BarcodeCacheTableCompanion(
                barcode: barcode,
                mediaTypeHint: mediaTypeHint,
                responseJson: responseJson,
                sourceApi: sourceApi,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String barcode,
                Value<String?> mediaTypeHint = const Value.absent(),
                required String responseJson,
                required String sourceApi,
                required int cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => BarcodeCacheTableCompanion.insert(
                barcode: barcode,
                mediaTypeHint: mediaTypeHint,
                responseJson: responseJson,
                sourceApi: sourceApi,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BarcodeCacheTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BarcodeCacheTableTable,
      BarcodeCacheTableData,
      $$BarcodeCacheTableTableFilterComposer,
      $$BarcodeCacheTableTableOrderingComposer,
      $$BarcodeCacheTableTableAnnotationComposer,
      $$BarcodeCacheTableTableCreateCompanionBuilder,
      $$BarcodeCacheTableTableUpdateCompanionBuilder,
      (
        BarcodeCacheTableData,
        BaseReferences<
          _$AppDatabase,
          $BarcodeCacheTableTable,
          BarcodeCacheTableData
        >,
      ),
      BarcodeCacheTableData,
      PrefetchHooks Function()
    >;
typedef $$SyncLogTableTableCreateCompanionBuilder =
    SyncLogTableCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String operation,
      required String payloadJson,
      required int createdAt,
      Value<int?> attemptedAt,
      Value<int> synced,
      Value<int> rowid,
    });
typedef $$SyncLogTableTableUpdateCompanionBuilder =
    SyncLogTableCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<int> createdAt,
      Value<int?> attemptedAt,
      Value<int> synced,
      Value<int> rowid,
    });

class $$SyncLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogTableTable> {
  $$SyncLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogTableTable> {
  $$SyncLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogTableTable> {
  $$SyncLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$SyncLogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogTableTable,
          SyncLogTableData,
          $$SyncLogTableTableFilterComposer,
          $$SyncLogTableTableOrderingComposer,
          $$SyncLogTableTableAnnotationComposer,
          $$SyncLogTableTableCreateCompanionBuilder,
          $$SyncLogTableTableUpdateCompanionBuilder,
          (
            SyncLogTableData,
            BaseReferences<_$AppDatabase, $SyncLogTableTable, SyncLogTableData>,
          ),
          SyncLogTableData,
          PrefetchHooks Function()
        > {
  $$SyncLogTableTableTableManager(_$AppDatabase db, $SyncLogTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> attemptedAt = const Value.absent(),
                Value<int> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncLogTableCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptedAt: attemptedAt,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String operation,
                required String payloadJson,
                required int createdAt,
                Value<int?> attemptedAt = const Value.absent(),
                Value<int> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncLogTableCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptedAt: attemptedAt,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogTableTable,
      SyncLogTableData,
      $$SyncLogTableTableFilterComposer,
      $$SyncLogTableTableOrderingComposer,
      $$SyncLogTableTableAnnotationComposer,
      $$SyncLogTableTableCreateCompanionBuilder,
      $$SyncLogTableTableUpdateCompanionBuilder,
      (
        SyncLogTableData,
        BaseReferences<_$AppDatabase, $SyncLogTableTable, SyncLogTableData>,
      ),
      SyncLogTableData,
      PrefetchHooks Function()
    >;
typedef $$BorrowersTableTableCreateCompanionBuilder =
    BorrowersTableCompanion Function({
      required String id,
      required String name,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> notes,
      required int updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$BorrowersTableTableUpdateCompanionBuilder =
    BorrowersTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> notes,
      Value<int> updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

final class $$BorrowersTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BorrowersTableTable,
          BorrowersTableData
        > {
  $$BorrowersTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LoansTableTable, List<LoansTableData>>
  _loansTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.loansTable,
    aliasName: $_aliasNameGenerator(
      db.borrowersTable.id,
      db.loansTable.borrowerId,
    ),
  );

  $$LoansTableTableProcessedTableManager get loansTableRefs {
    final manager = $$LoansTableTableTableManager(
      $_db,
      $_db.loansTable,
    ).filter((f) => f.borrowerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BorrowersTableTableFilterComposer
    extends Composer<_$AppDatabase, $BorrowersTableTable> {
  $$BorrowersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> loansTableRefs(
    Expression<bool> Function($$LoansTableTableFilterComposer f) f,
  ) {
    final $$LoansTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loansTable,
      getReferencedColumn: (t) => t.borrowerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableTableFilterComposer(
            $db: $db,
            $table: $db.loansTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BorrowersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BorrowersTableTable> {
  $$BorrowersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BorrowersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BorrowersTableTable> {
  $$BorrowersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> loansTableRefs<T extends Object>(
    Expression<T> Function($$LoansTableTableAnnotationComposer a) f,
  ) {
    final $$LoansTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loansTable,
      getReferencedColumn: (t) => t.borrowerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableTableAnnotationComposer(
            $db: $db,
            $table: $db.loansTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BorrowersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BorrowersTableTable,
          BorrowersTableData,
          $$BorrowersTableTableFilterComposer,
          $$BorrowersTableTableOrderingComposer,
          $$BorrowersTableTableAnnotationComposer,
          $$BorrowersTableTableCreateCompanionBuilder,
          $$BorrowersTableTableUpdateCompanionBuilder,
          (BorrowersTableData, $$BorrowersTableTableReferences),
          BorrowersTableData,
          PrefetchHooks Function({bool loansTableRefs})
        > {
  $$BorrowersTableTableTableManager(
    _$AppDatabase db,
    $BorrowersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BorrowersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BorrowersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BorrowersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BorrowersTableCompanion(
                id: id,
                name: name,
                email: email,
                phone: phone,
                notes: notes,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int updatedAt,
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BorrowersTableCompanion.insert(
                id: id,
                name: name,
                email: email,
                phone: phone,
                notes: notes,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BorrowersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({loansTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (loansTableRefs) db.loansTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loansTableRefs)
                    await $_getPrefetchedData<
                      BorrowersTableData,
                      $BorrowersTableTable,
                      LoansTableData
                    >(
                      currentTable: table,
                      referencedTable: $$BorrowersTableTableReferences
                          ._loansTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BorrowersTableTableReferences(
                            db,
                            table,
                            p0,
                          ).loansTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.borrowerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BorrowersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BorrowersTableTable,
      BorrowersTableData,
      $$BorrowersTableTableFilterComposer,
      $$BorrowersTableTableOrderingComposer,
      $$BorrowersTableTableAnnotationComposer,
      $$BorrowersTableTableCreateCompanionBuilder,
      $$BorrowersTableTableUpdateCompanionBuilder,
      (BorrowersTableData, $$BorrowersTableTableReferences),
      BorrowersTableData,
      PrefetchHooks Function({bool loansTableRefs})
    >;
typedef $$LoansTableTableCreateCompanionBuilder =
    LoansTableCompanion Function({
      required String id,
      required String mediaItemId,
      required String borrowerId,
      required int lentAt,
      Value<int?> returnedAt,
      Value<String?> notes,
      required int updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$LoansTableTableUpdateCompanionBuilder =
    LoansTableCompanion Function({
      Value<String> id,
      Value<String> mediaItemId,
      Value<String> borrowerId,
      Value<int> lentAt,
      Value<int?> returnedAt,
      Value<String?> notes,
      Value<int> updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

final class $$LoansTableTableReferences
    extends BaseReferences<_$AppDatabase, $LoansTableTable, LoansTableData> {
  $$LoansTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaItemsTableTable _mediaItemIdTable(_$AppDatabase db) =>
      db.mediaItemsTable.createAlias(
        $_aliasNameGenerator(db.loansTable.mediaItemId, db.mediaItemsTable.id),
      );

  $$MediaItemsTableTableProcessedTableManager get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id')!;

    final manager = $$MediaItemsTableTableTableManager(
      $_db,
      $_db.mediaItemsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BorrowersTableTable _borrowerIdTable(_$AppDatabase db) =>
      db.borrowersTable.createAlias(
        $_aliasNameGenerator(db.loansTable.borrowerId, db.borrowersTable.id),
      );

  $$BorrowersTableTableProcessedTableManager get borrowerId {
    final $_column = $_itemColumn<String>('borrower_id')!;

    final manager = $$BorrowersTableTableTableManager(
      $_db,
      $_db.borrowersTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_borrowerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoansTableTableFilterComposer
    extends Composer<_$AppDatabase, $LoansTableTable> {
  $$LoansTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lentAt => $composableBuilder(
    column: $table.lentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaItemsTableTableFilterComposer get mediaItemId {
    final $$MediaItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BorrowersTableTableFilterComposer get borrowerId {
    final $$BorrowersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowerId,
      referencedTable: $db.borrowersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowersTableTableFilterComposer(
            $db: $db,
            $table: $db.borrowersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTableTable> {
  $$LoansTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lentAt => $composableBuilder(
    column: $table.lentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BorrowersTableTableOrderingComposer get borrowerId {
    final $$BorrowersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowerId,
      referencedTable: $db.borrowersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowersTableTableOrderingComposer(
            $db: $db,
            $table: $db.borrowersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTableTable> {
  $$LoansTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lentAt =>
      $composableBuilder(column: $table.lentAt, builder: (column) => column);

  GeneratedColumn<int> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  $$MediaItemsTableTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItemsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BorrowersTableTableAnnotationComposer get borrowerId {
    final $$BorrowersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowerId,
      referencedTable: $db.borrowersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.borrowersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoansTableTable,
          LoansTableData,
          $$LoansTableTableFilterComposer,
          $$LoansTableTableOrderingComposer,
          $$LoansTableTableAnnotationComposer,
          $$LoansTableTableCreateCompanionBuilder,
          $$LoansTableTableUpdateCompanionBuilder,
          (LoansTableData, $$LoansTableTableReferences),
          LoansTableData,
          PrefetchHooks Function({bool mediaItemId, bool borrowerId})
        > {
  $$LoansTableTableTableManager(_$AppDatabase db, $LoansTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<String> borrowerId = const Value.absent(),
                Value<int> lentAt = const Value.absent(),
                Value<int?> returnedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoansTableCompanion(
                id: id,
                mediaItemId: mediaItemId,
                borrowerId: borrowerId,
                lentAt: lentAt,
                returnedAt: returnedAt,
                notes: notes,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaItemId,
                required String borrowerId,
                required int lentAt,
                Value<int?> returnedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int updatedAt,
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoansTableCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                borrowerId: borrowerId,
                lentAt: lentAt,
                returnedAt: returnedAt,
                notes: notes,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LoansTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaItemId = false, borrowerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaItemId,
                                referencedTable: $$LoansTableTableReferences
                                    ._mediaItemIdTable(db),
                                referencedColumn: $$LoansTableTableReferences
                                    ._mediaItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (borrowerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.borrowerId,
                                referencedTable: $$LoansTableTableReferences
                                    ._borrowerIdTable(db),
                                referencedColumn: $$LoansTableTableReferences
                                    ._borrowerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LoansTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoansTableTable,
      LoansTableData,
      $$LoansTableTableFilterComposer,
      $$LoansTableTableOrderingComposer,
      $$LoansTableTableAnnotationComposer,
      $$LoansTableTableCreateCompanionBuilder,
      $$LoansTableTableUpdateCompanionBuilder,
      (LoansTableData, $$LoansTableTableReferences),
      LoansTableData,
      PrefetchHooks Function({bool mediaItemId, bool borrowerId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaItemsTableTableTableManager get mediaItemsTable =>
      $$MediaItemsTableTableTableManager(_db, _db.mediaItemsTable);
  $$TagsTableTableTableManager get tagsTable =>
      $$TagsTableTableTableManager(_db, _db.tagsTable);
  $$MediaItemTagsTableTableTableManager get mediaItemTagsTable =>
      $$MediaItemTagsTableTableTableManager(_db, _db.mediaItemTagsTable);
  $$ShelvesTableTableTableManager get shelvesTable =>
      $$ShelvesTableTableTableManager(_db, _db.shelvesTable);
  $$ShelfItemsTableTableTableManager get shelfItemsTable =>
      $$ShelfItemsTableTableTableManager(_db, _db.shelfItemsTable);
  $$BarcodeCacheTableTableTableManager get barcodeCacheTable =>
      $$BarcodeCacheTableTableTableManager(_db, _db.barcodeCacheTable);
  $$SyncLogTableTableTableManager get syncLogTable =>
      $$SyncLogTableTableTableManager(_db, _db.syncLogTable);
  $$BorrowersTableTableTableManager get borrowersTable =>
      $$BorrowersTableTableTableManager(_db, _db.borrowersTable);
  $$LoansTableTableTableManager get loansTable =>
      $$LoansTableTableTableManager(_db, _db.loansTable);
}
