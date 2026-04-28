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
  static const VerificationMeta _ownershipStatusMeta = const VerificationMeta(
    'ownershipStatus',
  );
  @override
  late final GeneratedColumn<String> ownershipStatus = GeneratedColumn<String>(
    'ownership_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owned'),
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricePaidMeta = const VerificationMeta(
    'pricePaid',
  );
  @override
  late final GeneratedColumn<double> pricePaid = GeneratedColumn<double>(
    'price_paid',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta(
    'acquiredAt',
  );
  @override
  late final GeneratedColumn<int> acquiredAt = GeneratedColumn<int>(
    'acquired_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retailerMeta = const VerificationMeta(
    'retailer',
  );
  @override
  late final GeneratedColumn<String> retailer = GeneratedColumn<String>(
    'retailer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesPositionMeta = const VerificationMeta(
    'seriesPosition',
  );
  @override
  late final GeneratedColumn<int> seriesPosition = GeneratedColumn<int>(
    'series_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressCurrentMeta = const VerificationMeta(
    'progressCurrent',
  );
  @override
  late final GeneratedColumn<int> progressCurrent = GeneratedColumn<int>(
    'progress_current',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressTotalMeta = const VerificationMeta(
    'progressTotal',
  );
  @override
  late final GeneratedColumn<int> progressTotal = GeneratedColumn<int>(
    'progress_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressUnitMeta = const VerificationMeta(
    'progressUnit',
  );
  @override
  late final GeneratedColumn<String> progressUnit = GeneratedColumn<String>(
    'progress_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consumedMeta = const VerificationMeta(
    'consumed',
  );
  @override
  late final GeneratedColumn<int> consumed = GeneratedColumn<int>(
    'consumed',
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
    ownershipStatus,
    condition,
    pricePaid,
    acquiredAt,
    retailer,
    locationId,
    seriesId,
    seriesPosition,
    progressCurrent,
    progressTotal,
    progressUnit,
    startedAt,
    completedAt,
    consumed,
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
    if (data.containsKey('ownership_status')) {
      context.handle(
        _ownershipStatusMeta,
        ownershipStatus.isAcceptableOrUnknown(
          data['ownership_status']!,
          _ownershipStatusMeta,
        ),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('price_paid')) {
      context.handle(
        _pricePaidMeta,
        pricePaid.isAcceptableOrUnknown(data['price_paid']!, _pricePaidMeta),
      );
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    }
    if (data.containsKey('retailer')) {
      context.handle(
        _retailerMeta,
        retailer.isAcceptableOrUnknown(data['retailer']!, _retailerMeta),
      );
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('series_position')) {
      context.handle(
        _seriesPositionMeta,
        seriesPosition.isAcceptableOrUnknown(
          data['series_position']!,
          _seriesPositionMeta,
        ),
      );
    }
    if (data.containsKey('progress_current')) {
      context.handle(
        _progressCurrentMeta,
        progressCurrent.isAcceptableOrUnknown(
          data['progress_current']!,
          _progressCurrentMeta,
        ),
      );
    }
    if (data.containsKey('progress_total')) {
      context.handle(
        _progressTotalMeta,
        progressTotal.isAcceptableOrUnknown(
          data['progress_total']!,
          _progressTotalMeta,
        ),
      );
    }
    if (data.containsKey('progress_unit')) {
      context.handle(
        _progressUnitMeta,
        progressUnit.isAcceptableOrUnknown(
          data['progress_unit']!,
          _progressUnitMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('consumed')) {
      context.handle(
        _consumedMeta,
        consumed.isAcceptableOrUnknown(data['consumed']!, _consumedMeta),
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
      ownershipStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ownership_status'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      ),
      pricePaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_paid'],
      ),
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}acquired_at'],
      ),
      retailer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retailer'],
      ),
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      seriesPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_position'],
      ),
      progressCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_current'],
      ),
      progressTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_total'],
      ),
      progressUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}progress_unit'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      consumed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consumed'],
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
  final String ownershipStatus;
  final String? condition;
  final double? pricePaid;
  final int? acquiredAt;
  final String? retailer;
  final String? locationId;
  final String? seriesId;
  final int? seriesPosition;
  final int? progressCurrent;
  final int? progressTotal;
  final String? progressUnit;
  final int? startedAt;
  final int? completedAt;
  final int consumed;
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
    required this.ownershipStatus,
    this.condition,
    this.pricePaid,
    this.acquiredAt,
    this.retailer,
    this.locationId,
    this.seriesId,
    this.seriesPosition,
    this.progressCurrent,
    this.progressTotal,
    this.progressUnit,
    this.startedAt,
    this.completedAt,
    required this.consumed,
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
    map['ownership_status'] = Variable<String>(ownershipStatus);
    if (!nullToAbsent || condition != null) {
      map['condition'] = Variable<String>(condition);
    }
    if (!nullToAbsent || pricePaid != null) {
      map['price_paid'] = Variable<double>(pricePaid);
    }
    if (!nullToAbsent || acquiredAt != null) {
      map['acquired_at'] = Variable<int>(acquiredAt);
    }
    if (!nullToAbsent || retailer != null) {
      map['retailer'] = Variable<String>(retailer);
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    if (!nullToAbsent || seriesPosition != null) {
      map['series_position'] = Variable<int>(seriesPosition);
    }
    if (!nullToAbsent || progressCurrent != null) {
      map['progress_current'] = Variable<int>(progressCurrent);
    }
    if (!nullToAbsent || progressTotal != null) {
      map['progress_total'] = Variable<int>(progressTotal);
    }
    if (!nullToAbsent || progressUnit != null) {
      map['progress_unit'] = Variable<String>(progressUnit);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['consumed'] = Variable<int>(consumed);
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
      ownershipStatus: Value(ownershipStatus),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      pricePaid: pricePaid == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePaid),
      acquiredAt: acquiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acquiredAt),
      retailer: retailer == null && nullToAbsent
          ? const Value.absent()
          : Value(retailer),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      seriesPosition: seriesPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesPosition),
      progressCurrent: progressCurrent == null && nullToAbsent
          ? const Value.absent()
          : Value(progressCurrent),
      progressTotal: progressTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(progressTotal),
      progressUnit: progressUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(progressUnit),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      consumed: Value(consumed),
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
      ownershipStatus: serializer.fromJson<String>(json['ownershipStatus']),
      condition: serializer.fromJson<String?>(json['condition']),
      pricePaid: serializer.fromJson<double?>(json['pricePaid']),
      acquiredAt: serializer.fromJson<int?>(json['acquiredAt']),
      retailer: serializer.fromJson<String?>(json['retailer']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      seriesPosition: serializer.fromJson<int?>(json['seriesPosition']),
      progressCurrent: serializer.fromJson<int?>(json['progressCurrent']),
      progressTotal: serializer.fromJson<int?>(json['progressTotal']),
      progressUnit: serializer.fromJson<String?>(json['progressUnit']),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      consumed: serializer.fromJson<int>(json['consumed']),
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
      'ownershipStatus': serializer.toJson<String>(ownershipStatus),
      'condition': serializer.toJson<String?>(condition),
      'pricePaid': serializer.toJson<double?>(pricePaid),
      'acquiredAt': serializer.toJson<int?>(acquiredAt),
      'retailer': serializer.toJson<String?>(retailer),
      'locationId': serializer.toJson<String?>(locationId),
      'seriesId': serializer.toJson<String?>(seriesId),
      'seriesPosition': serializer.toJson<int?>(seriesPosition),
      'progressCurrent': serializer.toJson<int?>(progressCurrent),
      'progressTotal': serializer.toJson<int?>(progressTotal),
      'progressUnit': serializer.toJson<String?>(progressUnit),
      'startedAt': serializer.toJson<int?>(startedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'consumed': serializer.toJson<int>(consumed),
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
    String? ownershipStatus,
    Value<String?> condition = const Value.absent(),
    Value<double?> pricePaid = const Value.absent(),
    Value<int?> acquiredAt = const Value.absent(),
    Value<String?> retailer = const Value.absent(),
    Value<String?> locationId = const Value.absent(),
    Value<String?> seriesId = const Value.absent(),
    Value<int?> seriesPosition = const Value.absent(),
    Value<int?> progressCurrent = const Value.absent(),
    Value<int?> progressTotal = const Value.absent(),
    Value<String?> progressUnit = const Value.absent(),
    Value<int?> startedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    int? consumed,
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
    ownershipStatus: ownershipStatus ?? this.ownershipStatus,
    condition: condition.present ? condition.value : this.condition,
    pricePaid: pricePaid.present ? pricePaid.value : this.pricePaid,
    acquiredAt: acquiredAt.present ? acquiredAt.value : this.acquiredAt,
    retailer: retailer.present ? retailer.value : this.retailer,
    locationId: locationId.present ? locationId.value : this.locationId,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    seriesPosition: seriesPosition.present
        ? seriesPosition.value
        : this.seriesPosition,
    progressCurrent: progressCurrent.present
        ? progressCurrent.value
        : this.progressCurrent,
    progressTotal: progressTotal.present
        ? progressTotal.value
        : this.progressTotal,
    progressUnit: progressUnit.present ? progressUnit.value : this.progressUnit,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    consumed: consumed ?? this.consumed,
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
      ownershipStatus: data.ownershipStatus.present
          ? data.ownershipStatus.value
          : this.ownershipStatus,
      condition: data.condition.present ? data.condition.value : this.condition,
      pricePaid: data.pricePaid.present ? data.pricePaid.value : this.pricePaid,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
      retailer: data.retailer.present ? data.retailer.value : this.retailer,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      seriesPosition: data.seriesPosition.present
          ? data.seriesPosition.value
          : this.seriesPosition,
      progressCurrent: data.progressCurrent.present
          ? data.progressCurrent.value
          : this.progressCurrent,
      progressTotal: data.progressTotal.present
          ? data.progressTotal.value
          : this.progressTotal,
      progressUnit: data.progressUnit.present
          ? data.progressUnit.value
          : this.progressUnit,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      consumed: data.consumed.present ? data.consumed.value : this.consumed,
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
          ..write('deleted: $deleted, ')
          ..write('ownershipStatus: $ownershipStatus, ')
          ..write('condition: $condition, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('retailer: $retailer, ')
          ..write('locationId: $locationId, ')
          ..write('seriesId: $seriesId, ')
          ..write('seriesPosition: $seriesPosition, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('progressTotal: $progressTotal, ')
          ..write('progressUnit: $progressUnit, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('consumed: $consumed')
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
    ownershipStatus,
    condition,
    pricePaid,
    acquiredAt,
    retailer,
    locationId,
    seriesId,
    seriesPosition,
    progressCurrent,
    progressTotal,
    progressUnit,
    startedAt,
    completedAt,
    consumed,
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
          other.deleted == this.deleted &&
          other.ownershipStatus == this.ownershipStatus &&
          other.condition == this.condition &&
          other.pricePaid == this.pricePaid &&
          other.acquiredAt == this.acquiredAt &&
          other.retailer == this.retailer &&
          other.locationId == this.locationId &&
          other.seriesId == this.seriesId &&
          other.seriesPosition == this.seriesPosition &&
          other.progressCurrent == this.progressCurrent &&
          other.progressTotal == this.progressTotal &&
          other.progressUnit == this.progressUnit &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.consumed == this.consumed);
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
  final Value<String> ownershipStatus;
  final Value<String?> condition;
  final Value<double?> pricePaid;
  final Value<int?> acquiredAt;
  final Value<String?> retailer;
  final Value<String?> locationId;
  final Value<String?> seriesId;
  final Value<int?> seriesPosition;
  final Value<int?> progressCurrent;
  final Value<int?> progressTotal;
  final Value<String?> progressUnit;
  final Value<int?> startedAt;
  final Value<int?> completedAt;
  final Value<int> consumed;
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
    this.ownershipStatus = const Value.absent(),
    this.condition = const Value.absent(),
    this.pricePaid = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.retailer = const Value.absent(),
    this.locationId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.seriesPosition = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.progressTotal = const Value.absent(),
    this.progressUnit = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.consumed = const Value.absent(),
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
    this.ownershipStatus = const Value.absent(),
    this.condition = const Value.absent(),
    this.pricePaid = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.retailer = const Value.absent(),
    this.locationId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.seriesPosition = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.progressTotal = const Value.absent(),
    this.progressUnit = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.consumed = const Value.absent(),
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
    Expression<String>? ownershipStatus,
    Expression<String>? condition,
    Expression<double>? pricePaid,
    Expression<int>? acquiredAt,
    Expression<String>? retailer,
    Expression<String>? locationId,
    Expression<String>? seriesId,
    Expression<int>? seriesPosition,
    Expression<int>? progressCurrent,
    Expression<int>? progressTotal,
    Expression<String>? progressUnit,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
    Expression<int>? consumed,
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
      if (ownershipStatus != null) 'ownership_status': ownershipStatus,
      if (condition != null) 'condition': condition,
      if (pricePaid != null) 'price_paid': pricePaid,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (retailer != null) 'retailer': retailer,
      if (locationId != null) 'location_id': locationId,
      if (seriesId != null) 'series_id': seriesId,
      if (seriesPosition != null) 'series_position': seriesPosition,
      if (progressCurrent != null) 'progress_current': progressCurrent,
      if (progressTotal != null) 'progress_total': progressTotal,
      if (progressUnit != null) 'progress_unit': progressUnit,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (consumed != null) 'consumed': consumed,
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
    Value<String>? ownershipStatus,
    Value<String?>? condition,
    Value<double?>? pricePaid,
    Value<int?>? acquiredAt,
    Value<String?>? retailer,
    Value<String?>? locationId,
    Value<String?>? seriesId,
    Value<int?>? seriesPosition,
    Value<int?>? progressCurrent,
    Value<int?>? progressTotal,
    Value<String?>? progressUnit,
    Value<int?>? startedAt,
    Value<int?>? completedAt,
    Value<int>? consumed,
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
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      condition: condition ?? this.condition,
      pricePaid: pricePaid ?? this.pricePaid,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      retailer: retailer ?? this.retailer,
      locationId: locationId ?? this.locationId,
      seriesId: seriesId ?? this.seriesId,
      seriesPosition: seriesPosition ?? this.seriesPosition,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      progressUnit: progressUnit ?? this.progressUnit,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      consumed: consumed ?? this.consumed,
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
    if (ownershipStatus.present) {
      map['ownership_status'] = Variable<String>(ownershipStatus.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (pricePaid.present) {
      map['price_paid'] = Variable<double>(pricePaid.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<int>(acquiredAt.value);
    }
    if (retailer.present) {
      map['retailer'] = Variable<String>(retailer.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (seriesPosition.present) {
      map['series_position'] = Variable<int>(seriesPosition.value);
    }
    if (progressCurrent.present) {
      map['progress_current'] = Variable<int>(progressCurrent.value);
    }
    if (progressTotal.present) {
      map['progress_total'] = Variable<int>(progressTotal.value);
    }
    if (progressUnit.present) {
      map['progress_unit'] = Variable<String>(progressUnit.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (consumed.present) {
      map['consumed'] = Variable<int>(consumed.value);
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
          ..write('ownershipStatus: $ownershipStatus, ')
          ..write('condition: $condition, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('retailer: $retailer, ')
          ..write('locationId: $locationId, ')
          ..write('seriesId: $seriesId, ')
          ..write('seriesPosition: $seriesPosition, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('progressTotal: $progressTotal, ')
          ..write('progressUnit: $progressUnit, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('consumed: $consumed, ')
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
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedByMeta = const VerificationMeta(
    'resolvedBy',
  );
  @override
  late final GeneratedColumn<String> resolvedBy = GeneratedColumn<String>(
    'resolved_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    errorMessage,
    durationMs,
    direction,
    resolvedBy,
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
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('resolved_by')) {
      context.handle(
        _resolvedByMeta,
        resolvedBy.isAcceptableOrUnknown(data['resolved_by']!, _resolvedByMeta),
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
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      ),
      resolvedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_by'],
      ),
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
  final String? errorMessage;
  final int? durationMs;
  final String? direction;
  final String? resolvedBy;
  const SyncLogTableData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    this.attemptedAt,
    required this.synced,
    this.errorMessage,
    this.durationMs,
    this.direction,
    this.resolvedBy,
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
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || direction != null) {
      map['direction'] = Variable<String>(direction);
    }
    if (!nullToAbsent || resolvedBy != null) {
      map['resolved_by'] = Variable<String>(resolvedBy);
    }
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
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
      resolvedBy: resolvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedBy),
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
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      direction: serializer.fromJson<String?>(json['direction']),
      resolvedBy: serializer.fromJson<String?>(json['resolvedBy']),
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
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'durationMs': serializer.toJson<int?>(durationMs),
      'direction': serializer.toJson<String?>(direction),
      'resolvedBy': serializer.toJson<String?>(resolvedBy),
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
    Value<String?> errorMessage = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> direction = const Value.absent(),
    Value<String?> resolvedBy = const Value.absent(),
  }) => SyncLogTableData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attemptedAt: attemptedAt.present ? attemptedAt.value : this.attemptedAt,
    synced: synced ?? this.synced,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    direction: direction.present ? direction.value : this.direction,
    resolvedBy: resolvedBy.present ? resolvedBy.value : this.resolvedBy,
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
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      direction: data.direction.present ? data.direction.value : this.direction,
      resolvedBy: data.resolvedBy.present
          ? data.resolvedBy.value
          : this.resolvedBy,
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
          ..write('synced: $synced, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('durationMs: $durationMs, ')
          ..write('direction: $direction, ')
          ..write('resolvedBy: $resolvedBy')
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
    errorMessage,
    durationMs,
    direction,
    resolvedBy,
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
          other.synced == this.synced &&
          other.errorMessage == this.errorMessage &&
          other.durationMs == this.durationMs &&
          other.direction == this.direction &&
          other.resolvedBy == this.resolvedBy);
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
  final Value<String?> errorMessage;
  final Value<int?> durationMs;
  final Value<String?> direction;
  final Value<String?> resolvedBy;
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
    this.errorMessage = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.direction = const Value.absent(),
    this.resolvedBy = const Value.absent(),
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
    this.errorMessage = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.direction = const Value.absent(),
    this.resolvedBy = const Value.absent(),
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
    Expression<String>? errorMessage,
    Expression<int>? durationMs,
    Expression<String>? direction,
    Expression<String>? resolvedBy,
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
      if (errorMessage != null) 'error_message': errorMessage,
      if (durationMs != null) 'duration_ms': durationMs,
      if (direction != null) 'direction': direction,
      if (resolvedBy != null) 'resolved_by': resolvedBy,
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
    Value<String?>? errorMessage,
    Value<int?>? durationMs,
    Value<String?>? direction,
    Value<String?>? resolvedBy,
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
      errorMessage: errorMessage ?? this.errorMessage,
      durationMs: durationMs ?? this.durationMs,
      direction: direction ?? this.direction,
      resolvedBy: resolvedBy ?? this.resolvedBy,
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
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (resolvedBy.present) {
      map['resolved_by'] = Variable<String>(resolvedBy.value);
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
          ..write('errorMessage: $errorMessage, ')
          ..write('durationMs: $durationMs, ')
          ..write('direction: $direction, ')
          ..write('resolvedBy: $resolvedBy, ')
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
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
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
    dueAt,
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
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
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
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
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
  final int? dueAt;
  final String? notes;
  final int updatedAt;
  final int deleted;
  const LoansTableData({
    required this.id,
    required this.mediaItemId,
    required this.borrowerId,
    required this.lentAt,
    this.returnedAt,
    this.dueAt,
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
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
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
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
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
      dueAt: serializer.fromJson<int?>(json['dueAt']),
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
      'dueAt': serializer.toJson<int?>(dueAt),
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
    Value<int?> dueAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? updatedAt,
    int? deleted,
  }) => LoansTableData(
    id: id ?? this.id,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    borrowerId: borrowerId ?? this.borrowerId,
    lentAt: lentAt ?? this.lentAt,
    returnedAt: returnedAt.present ? returnedAt.value : this.returnedAt,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
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
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
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
          ..write('dueAt: $dueAt, ')
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
    dueAt,
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
          other.dueAt == this.dueAt &&
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
  final Value<int?> dueAt;
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
    this.dueAt = const Value.absent(),
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
    this.dueAt = const Value.absent(),
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
    Expression<int>? dueAt,
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
      if (dueAt != null) 'due_at': dueAt,
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
    Value<int?>? dueAt,
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
      dueAt: dueAt ?? this.dueAt,
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
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
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
          ..write('dueAt: $dueAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RipAlbumsTableTable extends RipAlbumsTable
    with TableInfo<$RipAlbumsTableTable, RipAlbumsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RipAlbumsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryPathMeta = const VerificationMeta(
    'libraryPath',
  );
  @override
  late final GeneratedColumn<String> libraryPath = GeneratedColumn<String>(
    'library_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumTitleMeta = const VerificationMeta(
    'albumTitle',
  );
  @override
  late final GeneratedColumn<String> albumTitle = GeneratedColumn<String>(
    'album_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackCountMeta = const VerificationMeta(
    'trackCount',
  );
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
    'track_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discCountMeta = const VerificationMeta(
    'discCount',
  );
  @override
  late final GeneratedColumn<int> discCount = GeneratedColumn<int>(
    'disc_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _totalSizeBytesMeta = const VerificationMeta(
    'totalSizeBytes',
  );
  @override
  late final GeneratedColumn<int> totalSizeBytes = GeneratedColumn<int>(
    'total_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id)',
    ),
  );
  static const VerificationMeta _lastScannedAtMeta = const VerificationMeta(
    'lastScannedAt',
  );
  @override
  late final GeneratedColumn<int> lastScannedAt = GeneratedColumn<int>(
    'last_scanned_at',
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
  static const VerificationMeta _cueFilePathMeta = const VerificationMeta(
    'cueFilePath',
  );
  @override
  late final GeneratedColumn<String> cueFilePath = GeneratedColumn<String>(
    'cue_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gnudbDiscIdMeta = const VerificationMeta(
    'gnudbDiscId',
  );
  @override
  late final GeneratedColumn<String> gnudbDiscId = GeneratedColumn<String>(
    'gnudb_disc_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    libraryPath,
    artist,
    albumTitle,
    barcode,
    trackCount,
    discCount,
    totalSizeBytes,
    mediaItemId,
    lastScannedAt,
    updatedAt,
    cueFilePath,
    gnudbDiscId,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rip_albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<RipAlbumsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('library_path')) {
      context.handle(
        _libraryPathMeta,
        libraryPath.isAcceptableOrUnknown(
          data['library_path']!,
          _libraryPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_libraryPathMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album_title')) {
      context.handle(
        _albumTitleMeta,
        albumTitle.isAcceptableOrUnknown(data['album_title']!, _albumTitleMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('track_count')) {
      context.handle(
        _trackCountMeta,
        trackCount.isAcceptableOrUnknown(data['track_count']!, _trackCountMeta),
      );
    } else if (isInserting) {
      context.missing(_trackCountMeta);
    }
    if (data.containsKey('disc_count')) {
      context.handle(
        _discCountMeta,
        discCount.isAcceptableOrUnknown(data['disc_count']!, _discCountMeta),
      );
    }
    if (data.containsKey('total_size_bytes')) {
      context.handle(
        _totalSizeBytesMeta,
        totalSizeBytes.isAcceptableOrUnknown(
          data['total_size_bytes']!,
          _totalSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalSizeBytesMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    }
    if (data.containsKey('last_scanned_at')) {
      context.handle(
        _lastScannedAtMeta,
        lastScannedAt.isAcceptableOrUnknown(
          data['last_scanned_at']!,
          _lastScannedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastScannedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cue_file_path')) {
      context.handle(
        _cueFilePathMeta,
        cueFilePath.isAcceptableOrUnknown(
          data['cue_file_path']!,
          _cueFilePathMeta,
        ),
      );
    }
    if (data.containsKey('gnudb_disc_id')) {
      context.handle(
        _gnudbDiscIdMeta,
        gnudbDiscId.isAcceptableOrUnknown(
          data['gnudb_disc_id']!,
          _gnudbDiscIdMeta,
        ),
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
  RipAlbumsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RipAlbumsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      libraryPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_path'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      albumTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_title'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      trackCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_count'],
      )!,
      discCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_count'],
      )!,
      totalSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_size_bytes'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      ),
      lastScannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_scanned_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      cueFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue_file_path'],
      ),
      gnudbDiscId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gnudb_disc_id'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $RipAlbumsTableTable createAlias(String alias) {
    return $RipAlbumsTableTable(attachedDatabase, alias);
  }
}

class RipAlbumsTableData extends DataClass
    implements Insertable<RipAlbumsTableData> {
  final String id;
  final String libraryPath;
  final String? artist;
  final String? albumTitle;
  final String? barcode;
  final int trackCount;
  final int discCount;
  final int totalSizeBytes;
  final String? mediaItemId;
  final int lastScannedAt;
  final int updatedAt;
  final String? cueFilePath;
  final String? gnudbDiscId;
  final int deleted;
  const RipAlbumsTableData({
    required this.id,
    required this.libraryPath,
    this.artist,
    this.albumTitle,
    this.barcode,
    required this.trackCount,
    required this.discCount,
    required this.totalSizeBytes,
    this.mediaItemId,
    required this.lastScannedAt,
    required this.updatedAt,
    this.cueFilePath,
    this.gnudbDiscId,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['library_path'] = Variable<String>(libraryPath);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || albumTitle != null) {
      map['album_title'] = Variable<String>(albumTitle);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['track_count'] = Variable<int>(trackCount);
    map['disc_count'] = Variable<int>(discCount);
    map['total_size_bytes'] = Variable<int>(totalSizeBytes);
    if (!nullToAbsent || mediaItemId != null) {
      map['media_item_id'] = Variable<String>(mediaItemId);
    }
    map['last_scanned_at'] = Variable<int>(lastScannedAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || cueFilePath != null) {
      map['cue_file_path'] = Variable<String>(cueFilePath);
    }
    if (!nullToAbsent || gnudbDiscId != null) {
      map['gnudb_disc_id'] = Variable<String>(gnudbDiscId);
    }
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  RipAlbumsTableCompanion toCompanion(bool nullToAbsent) {
    return RipAlbumsTableCompanion(
      id: Value(id),
      libraryPath: Value(libraryPath),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      albumTitle: albumTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(albumTitle),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      trackCount: Value(trackCount),
      discCount: Value(discCount),
      totalSizeBytes: Value(totalSizeBytes),
      mediaItemId: mediaItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaItemId),
      lastScannedAt: Value(lastScannedAt),
      updatedAt: Value(updatedAt),
      cueFilePath: cueFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(cueFilePath),
      gnudbDiscId: gnudbDiscId == null && nullToAbsent
          ? const Value.absent()
          : Value(gnudbDiscId),
      deleted: Value(deleted),
    );
  }

  factory RipAlbumsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RipAlbumsTableData(
      id: serializer.fromJson<String>(json['id']),
      libraryPath: serializer.fromJson<String>(json['libraryPath']),
      artist: serializer.fromJson<String?>(json['artist']),
      albumTitle: serializer.fromJson<String?>(json['albumTitle']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      trackCount: serializer.fromJson<int>(json['trackCount']),
      discCount: serializer.fromJson<int>(json['discCount']),
      totalSizeBytes: serializer.fromJson<int>(json['totalSizeBytes']),
      mediaItemId: serializer.fromJson<String?>(json['mediaItemId']),
      lastScannedAt: serializer.fromJson<int>(json['lastScannedAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      cueFilePath: serializer.fromJson<String?>(json['cueFilePath']),
      gnudbDiscId: serializer.fromJson<String?>(json['gnudbDiscId']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'libraryPath': serializer.toJson<String>(libraryPath),
      'artist': serializer.toJson<String?>(artist),
      'albumTitle': serializer.toJson<String?>(albumTitle),
      'barcode': serializer.toJson<String?>(barcode),
      'trackCount': serializer.toJson<int>(trackCount),
      'discCount': serializer.toJson<int>(discCount),
      'totalSizeBytes': serializer.toJson<int>(totalSizeBytes),
      'mediaItemId': serializer.toJson<String?>(mediaItemId),
      'lastScannedAt': serializer.toJson<int>(lastScannedAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'cueFilePath': serializer.toJson<String?>(cueFilePath),
      'gnudbDiscId': serializer.toJson<String?>(gnudbDiscId),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  RipAlbumsTableData copyWith({
    String? id,
    String? libraryPath,
    Value<String?> artist = const Value.absent(),
    Value<String?> albumTitle = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    int? trackCount,
    int? discCount,
    int? totalSizeBytes,
    Value<String?> mediaItemId = const Value.absent(),
    int? lastScannedAt,
    int? updatedAt,
    Value<String?> cueFilePath = const Value.absent(),
    Value<String?> gnudbDiscId = const Value.absent(),
    int? deleted,
  }) => RipAlbumsTableData(
    id: id ?? this.id,
    libraryPath: libraryPath ?? this.libraryPath,
    artist: artist.present ? artist.value : this.artist,
    albumTitle: albumTitle.present ? albumTitle.value : this.albumTitle,
    barcode: barcode.present ? barcode.value : this.barcode,
    trackCount: trackCount ?? this.trackCount,
    discCount: discCount ?? this.discCount,
    totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
    mediaItemId: mediaItemId.present ? mediaItemId.value : this.mediaItemId,
    lastScannedAt: lastScannedAt ?? this.lastScannedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cueFilePath: cueFilePath.present ? cueFilePath.value : this.cueFilePath,
    gnudbDiscId: gnudbDiscId.present ? gnudbDiscId.value : this.gnudbDiscId,
    deleted: deleted ?? this.deleted,
  );
  RipAlbumsTableData copyWithCompanion(RipAlbumsTableCompanion data) {
    return RipAlbumsTableData(
      id: data.id.present ? data.id.value : this.id,
      libraryPath: data.libraryPath.present
          ? data.libraryPath.value
          : this.libraryPath,
      artist: data.artist.present ? data.artist.value : this.artist,
      albumTitle: data.albumTitle.present
          ? data.albumTitle.value
          : this.albumTitle,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      trackCount: data.trackCount.present
          ? data.trackCount.value
          : this.trackCount,
      discCount: data.discCount.present ? data.discCount.value : this.discCount,
      totalSizeBytes: data.totalSizeBytes.present
          ? data.totalSizeBytes.value
          : this.totalSizeBytes,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      lastScannedAt: data.lastScannedAt.present
          ? data.lastScannedAt.value
          : this.lastScannedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cueFilePath: data.cueFilePath.present
          ? data.cueFilePath.value
          : this.cueFilePath,
      gnudbDiscId: data.gnudbDiscId.present
          ? data.gnudbDiscId.value
          : this.gnudbDiscId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RipAlbumsTableData(')
          ..write('id: $id, ')
          ..write('libraryPath: $libraryPath, ')
          ..write('artist: $artist, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('barcode: $barcode, ')
          ..write('trackCount: $trackCount, ')
          ..write('discCount: $discCount, ')
          ..write('totalSizeBytes: $totalSizeBytes, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('lastScannedAt: $lastScannedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cueFilePath: $cueFilePath, ')
          ..write('gnudbDiscId: $gnudbDiscId, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    libraryPath,
    artist,
    albumTitle,
    barcode,
    trackCount,
    discCount,
    totalSizeBytes,
    mediaItemId,
    lastScannedAt,
    updatedAt,
    cueFilePath,
    gnudbDiscId,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RipAlbumsTableData &&
          other.id == this.id &&
          other.libraryPath == this.libraryPath &&
          other.artist == this.artist &&
          other.albumTitle == this.albumTitle &&
          other.barcode == this.barcode &&
          other.trackCount == this.trackCount &&
          other.discCount == this.discCount &&
          other.totalSizeBytes == this.totalSizeBytes &&
          other.mediaItemId == this.mediaItemId &&
          other.lastScannedAt == this.lastScannedAt &&
          other.updatedAt == this.updatedAt &&
          other.cueFilePath == this.cueFilePath &&
          other.gnudbDiscId == this.gnudbDiscId &&
          other.deleted == this.deleted);
}

class RipAlbumsTableCompanion extends UpdateCompanion<RipAlbumsTableData> {
  final Value<String> id;
  final Value<String> libraryPath;
  final Value<String?> artist;
  final Value<String?> albumTitle;
  final Value<String?> barcode;
  final Value<int> trackCount;
  final Value<int> discCount;
  final Value<int> totalSizeBytes;
  final Value<String?> mediaItemId;
  final Value<int> lastScannedAt;
  final Value<int> updatedAt;
  final Value<String?> cueFilePath;
  final Value<String?> gnudbDiscId;
  final Value<int> deleted;
  final Value<int> rowid;
  const RipAlbumsTableCompanion({
    this.id = const Value.absent(),
    this.libraryPath = const Value.absent(),
    this.artist = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.barcode = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.discCount = const Value.absent(),
    this.totalSizeBytes = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.lastScannedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cueFilePath = const Value.absent(),
    this.gnudbDiscId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RipAlbumsTableCompanion.insert({
    required String id,
    required String libraryPath,
    this.artist = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.barcode = const Value.absent(),
    required int trackCount,
    this.discCount = const Value.absent(),
    required int totalSizeBytes,
    this.mediaItemId = const Value.absent(),
    required int lastScannedAt,
    required int updatedAt,
    this.cueFilePath = const Value.absent(),
    this.gnudbDiscId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       libraryPath = Value(libraryPath),
       trackCount = Value(trackCount),
       totalSizeBytes = Value(totalSizeBytes),
       lastScannedAt = Value(lastScannedAt),
       updatedAt = Value(updatedAt);
  static Insertable<RipAlbumsTableData> custom({
    Expression<String>? id,
    Expression<String>? libraryPath,
    Expression<String>? artist,
    Expression<String>? albumTitle,
    Expression<String>? barcode,
    Expression<int>? trackCount,
    Expression<int>? discCount,
    Expression<int>? totalSizeBytes,
    Expression<String>? mediaItemId,
    Expression<int>? lastScannedAt,
    Expression<int>? updatedAt,
    Expression<String>? cueFilePath,
    Expression<String>? gnudbDiscId,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (libraryPath != null) 'library_path': libraryPath,
      if (artist != null) 'artist': artist,
      if (albumTitle != null) 'album_title': albumTitle,
      if (barcode != null) 'barcode': barcode,
      if (trackCount != null) 'track_count': trackCount,
      if (discCount != null) 'disc_count': discCount,
      if (totalSizeBytes != null) 'total_size_bytes': totalSizeBytes,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (lastScannedAt != null) 'last_scanned_at': lastScannedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cueFilePath != null) 'cue_file_path': cueFilePath,
      if (gnudbDiscId != null) 'gnudb_disc_id': gnudbDiscId,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RipAlbumsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? libraryPath,
    Value<String?>? artist,
    Value<String?>? albumTitle,
    Value<String?>? barcode,
    Value<int>? trackCount,
    Value<int>? discCount,
    Value<int>? totalSizeBytes,
    Value<String?>? mediaItemId,
    Value<int>? lastScannedAt,
    Value<int>? updatedAt,
    Value<String?>? cueFilePath,
    Value<String?>? gnudbDiscId,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return RipAlbumsTableCompanion(
      id: id ?? this.id,
      libraryPath: libraryPath ?? this.libraryPath,
      artist: artist ?? this.artist,
      albumTitle: albumTitle ?? this.albumTitle,
      barcode: barcode ?? this.barcode,
      trackCount: trackCount ?? this.trackCount,
      discCount: discCount ?? this.discCount,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cueFilePath: cueFilePath ?? this.cueFilePath,
      gnudbDiscId: gnudbDiscId ?? this.gnudbDiscId,
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
    if (libraryPath.present) {
      map['library_path'] = Variable<String>(libraryPath.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (albumTitle.present) {
      map['album_title'] = Variable<String>(albumTitle.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (discCount.present) {
      map['disc_count'] = Variable<int>(discCount.value);
    }
    if (totalSizeBytes.present) {
      map['total_size_bytes'] = Variable<int>(totalSizeBytes.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (lastScannedAt.present) {
      map['last_scanned_at'] = Variable<int>(lastScannedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (cueFilePath.present) {
      map['cue_file_path'] = Variable<String>(cueFilePath.value);
    }
    if (gnudbDiscId.present) {
      map['gnudb_disc_id'] = Variable<String>(gnudbDiscId.value);
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
    return (StringBuffer('RipAlbumsTableCompanion(')
          ..write('id: $id, ')
          ..write('libraryPath: $libraryPath, ')
          ..write('artist: $artist, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('barcode: $barcode, ')
          ..write('trackCount: $trackCount, ')
          ..write('discCount: $discCount, ')
          ..write('totalSizeBytes: $totalSizeBytes, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('lastScannedAt: $lastScannedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cueFilePath: $cueFilePath, ')
          ..write('gnudbDiscId: $gnudbDiscId, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RipTracksTableTable extends RipTracksTable
    with TableInfo<$RipTracksTableTable, RipTracksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RipTracksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ripAlbumIdMeta = const VerificationMeta(
    'ripAlbumId',
  );
  @override
  late final GeneratedColumn<String> ripAlbumId = GeneratedColumn<String>(
    'rip_album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rip_albums (id)',
    ),
  );
  static const VerificationMeta _discNumberMeta = const VerificationMeta(
    'discNumber',
  );
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
    'disc_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
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
  static const VerificationMeta _accurateripStatusMeta = const VerificationMeta(
    'accurateripStatus',
  );
  @override
  late final GeneratedColumn<String> accurateripStatus =
      GeneratedColumn<String>(
        'accuraterip_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accurateripConfidenceMeta =
      const VerificationMeta('accurateripConfidence');
  @override
  late final GeneratedColumn<int> accurateripConfidence = GeneratedColumn<int>(
    'accuraterip_confidence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accurateripCrcV1Meta = const VerificationMeta(
    'accurateripCrcV1',
  );
  @override
  late final GeneratedColumn<String> accurateripCrcV1 = GeneratedColumn<String>(
    'accuraterip_crc_v1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accurateripCrcV2Meta = const VerificationMeta(
    'accurateripCrcV2',
  );
  @override
  late final GeneratedColumn<String> accurateripCrcV2 = GeneratedColumn<String>(
    'accuraterip_crc_v2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peakLevelMeta = const VerificationMeta(
    'peakLevel',
  );
  @override
  late final GeneratedColumn<double> peakLevel = GeneratedColumn<double>(
    'peak_level',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackQualityMeta = const VerificationMeta(
    'trackQuality',
  );
  @override
  late final GeneratedColumn<double> trackQuality = GeneratedColumn<double>(
    'track_quality',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _copyCrcMeta = const VerificationMeta(
    'copyCrc',
  );
  @override
  late final GeneratedColumn<String> copyCrc = GeneratedColumn<String>(
    'copy_crc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clickCountMeta = const VerificationMeta(
    'clickCount',
  );
  @override
  late final GeneratedColumn<int> clickCount = GeneratedColumn<int>(
    'click_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ripLogSourceMeta = const VerificationMeta(
    'ripLogSource',
  );
  @override
  late final GeneratedColumn<String> ripLogSource = GeneratedColumn<String>(
    'rip_log_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityCheckedAtMeta = const VerificationMeta(
    'qualityCheckedAt',
  );
  @override
  late final GeneratedColumn<int> qualityCheckedAt = GeneratedColumn<int>(
    'quality_checked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ripAlbumId,
    discNumber,
    trackNumber,
    title,
    filePath,
    durationMs,
    fileSizeBytes,
    updatedAt,
    accurateripStatus,
    accurateripConfidence,
    accurateripCrcV1,
    accurateripCrcV2,
    peakLevel,
    trackQuality,
    copyCrc,
    clickCount,
    ripLogSource,
    qualityCheckedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rip_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<RipTracksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rip_album_id')) {
      context.handle(
        _ripAlbumIdMeta,
        ripAlbumId.isAcceptableOrUnknown(
          data['rip_album_id']!,
          _ripAlbumIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ripAlbumIdMeta);
    }
    if (data.containsKey('disc_number')) {
      context.handle(
        _discNumberMeta,
        discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('accuraterip_status')) {
      context.handle(
        _accurateripStatusMeta,
        accurateripStatus.isAcceptableOrUnknown(
          data['accuraterip_status']!,
          _accurateripStatusMeta,
        ),
      );
    }
    if (data.containsKey('accuraterip_confidence')) {
      context.handle(
        _accurateripConfidenceMeta,
        accurateripConfidence.isAcceptableOrUnknown(
          data['accuraterip_confidence']!,
          _accurateripConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('accuraterip_crc_v1')) {
      context.handle(
        _accurateripCrcV1Meta,
        accurateripCrcV1.isAcceptableOrUnknown(
          data['accuraterip_crc_v1']!,
          _accurateripCrcV1Meta,
        ),
      );
    }
    if (data.containsKey('accuraterip_crc_v2')) {
      context.handle(
        _accurateripCrcV2Meta,
        accurateripCrcV2.isAcceptableOrUnknown(
          data['accuraterip_crc_v2']!,
          _accurateripCrcV2Meta,
        ),
      );
    }
    if (data.containsKey('peak_level')) {
      context.handle(
        _peakLevelMeta,
        peakLevel.isAcceptableOrUnknown(data['peak_level']!, _peakLevelMeta),
      );
    }
    if (data.containsKey('track_quality')) {
      context.handle(
        _trackQualityMeta,
        trackQuality.isAcceptableOrUnknown(
          data['track_quality']!,
          _trackQualityMeta,
        ),
      );
    }
    if (data.containsKey('copy_crc')) {
      context.handle(
        _copyCrcMeta,
        copyCrc.isAcceptableOrUnknown(data['copy_crc']!, _copyCrcMeta),
      );
    }
    if (data.containsKey('click_count')) {
      context.handle(
        _clickCountMeta,
        clickCount.isAcceptableOrUnknown(data['click_count']!, _clickCountMeta),
      );
    }
    if (data.containsKey('rip_log_source')) {
      context.handle(
        _ripLogSourceMeta,
        ripLogSource.isAcceptableOrUnknown(
          data['rip_log_source']!,
          _ripLogSourceMeta,
        ),
      );
    }
    if (data.containsKey('quality_checked_at')) {
      context.handle(
        _qualityCheckedAtMeta,
        qualityCheckedAt.isAcceptableOrUnknown(
          data['quality_checked_at']!,
          _qualityCheckedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RipTracksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RipTracksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ripAlbumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rip_album_id'],
      )!,
      discNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_number'],
      )!,
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      accurateripStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accuraterip_status'],
      ),
      accurateripConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuraterip_confidence'],
      ),
      accurateripCrcV1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accuraterip_crc_v1'],
      ),
      accurateripCrcV2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accuraterip_crc_v2'],
      ),
      peakLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_level'],
      ),
      trackQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}track_quality'],
      ),
      copyCrc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}copy_crc'],
      ),
      clickCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}click_count'],
      ),
      ripLogSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rip_log_source'],
      ),
      qualityCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality_checked_at'],
      ),
    );
  }

  @override
  $RipTracksTableTable createAlias(String alias) {
    return $RipTracksTableTable(attachedDatabase, alias);
  }
}

class RipTracksTableData extends DataClass
    implements Insertable<RipTracksTableData> {
  final String id;
  final String ripAlbumId;
  final int discNumber;
  final int trackNumber;
  final String? title;
  final String filePath;
  final int? durationMs;
  final int fileSizeBytes;
  final int updatedAt;
  final String? accurateripStatus;
  final int? accurateripConfidence;
  final String? accurateripCrcV1;
  final String? accurateripCrcV2;
  final double? peakLevel;
  final double? trackQuality;
  final String? copyCrc;
  final int? clickCount;
  final String? ripLogSource;
  final int? qualityCheckedAt;
  const RipTracksTableData({
    required this.id,
    required this.ripAlbumId,
    required this.discNumber,
    required this.trackNumber,
    this.title,
    required this.filePath,
    this.durationMs,
    required this.fileSizeBytes,
    required this.updatedAt,
    this.accurateripStatus,
    this.accurateripConfidence,
    this.accurateripCrcV1,
    this.accurateripCrcV2,
    this.peakLevel,
    this.trackQuality,
    this.copyCrc,
    this.clickCount,
    this.ripLogSource,
    this.qualityCheckedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rip_album_id'] = Variable<String>(ripAlbumId);
    map['disc_number'] = Variable<int>(discNumber);
    map['track_number'] = Variable<int>(trackNumber);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || accurateripStatus != null) {
      map['accuraterip_status'] = Variable<String>(accurateripStatus);
    }
    if (!nullToAbsent || accurateripConfidence != null) {
      map['accuraterip_confidence'] = Variable<int>(accurateripConfidence);
    }
    if (!nullToAbsent || accurateripCrcV1 != null) {
      map['accuraterip_crc_v1'] = Variable<String>(accurateripCrcV1);
    }
    if (!nullToAbsent || accurateripCrcV2 != null) {
      map['accuraterip_crc_v2'] = Variable<String>(accurateripCrcV2);
    }
    if (!nullToAbsent || peakLevel != null) {
      map['peak_level'] = Variable<double>(peakLevel);
    }
    if (!nullToAbsent || trackQuality != null) {
      map['track_quality'] = Variable<double>(trackQuality);
    }
    if (!nullToAbsent || copyCrc != null) {
      map['copy_crc'] = Variable<String>(copyCrc);
    }
    if (!nullToAbsent || clickCount != null) {
      map['click_count'] = Variable<int>(clickCount);
    }
    if (!nullToAbsent || ripLogSource != null) {
      map['rip_log_source'] = Variable<String>(ripLogSource);
    }
    if (!nullToAbsent || qualityCheckedAt != null) {
      map['quality_checked_at'] = Variable<int>(qualityCheckedAt);
    }
    return map;
  }

  RipTracksTableCompanion toCompanion(bool nullToAbsent) {
    return RipTracksTableCompanion(
      id: Value(id),
      ripAlbumId: Value(ripAlbumId),
      discNumber: Value(discNumber),
      trackNumber: Value(trackNumber),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      filePath: Value(filePath),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      fileSizeBytes: Value(fileSizeBytes),
      updatedAt: Value(updatedAt),
      accurateripStatus: accurateripStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(accurateripStatus),
      accurateripConfidence: accurateripConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(accurateripConfidence),
      accurateripCrcV1: accurateripCrcV1 == null && nullToAbsent
          ? const Value.absent()
          : Value(accurateripCrcV1),
      accurateripCrcV2: accurateripCrcV2 == null && nullToAbsent
          ? const Value.absent()
          : Value(accurateripCrcV2),
      peakLevel: peakLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(peakLevel),
      trackQuality: trackQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(trackQuality),
      copyCrc: copyCrc == null && nullToAbsent
          ? const Value.absent()
          : Value(copyCrc),
      clickCount: clickCount == null && nullToAbsent
          ? const Value.absent()
          : Value(clickCount),
      ripLogSource: ripLogSource == null && nullToAbsent
          ? const Value.absent()
          : Value(ripLogSource),
      qualityCheckedAt: qualityCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityCheckedAt),
    );
  }

  factory RipTracksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RipTracksTableData(
      id: serializer.fromJson<String>(json['id']),
      ripAlbumId: serializer.fromJson<String>(json['ripAlbumId']),
      discNumber: serializer.fromJson<int>(json['discNumber']),
      trackNumber: serializer.fromJson<int>(json['trackNumber']),
      title: serializer.fromJson<String?>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      accurateripStatus: serializer.fromJson<String?>(
        json['accurateripStatus'],
      ),
      accurateripConfidence: serializer.fromJson<int?>(
        json['accurateripConfidence'],
      ),
      accurateripCrcV1: serializer.fromJson<String?>(json['accurateripCrcV1']),
      accurateripCrcV2: serializer.fromJson<String?>(json['accurateripCrcV2']),
      peakLevel: serializer.fromJson<double?>(json['peakLevel']),
      trackQuality: serializer.fromJson<double?>(json['trackQuality']),
      copyCrc: serializer.fromJson<String?>(json['copyCrc']),
      clickCount: serializer.fromJson<int?>(json['clickCount']),
      ripLogSource: serializer.fromJson<String?>(json['ripLogSource']),
      qualityCheckedAt: serializer.fromJson<int?>(json['qualityCheckedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ripAlbumId': serializer.toJson<String>(ripAlbumId),
      'discNumber': serializer.toJson<int>(discNumber),
      'trackNumber': serializer.toJson<int>(trackNumber),
      'title': serializer.toJson<String?>(title),
      'filePath': serializer.toJson<String>(filePath),
      'durationMs': serializer.toJson<int?>(durationMs),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'accurateripStatus': serializer.toJson<String?>(accurateripStatus),
      'accurateripConfidence': serializer.toJson<int?>(accurateripConfidence),
      'accurateripCrcV1': serializer.toJson<String?>(accurateripCrcV1),
      'accurateripCrcV2': serializer.toJson<String?>(accurateripCrcV2),
      'peakLevel': serializer.toJson<double?>(peakLevel),
      'trackQuality': serializer.toJson<double?>(trackQuality),
      'copyCrc': serializer.toJson<String?>(copyCrc),
      'clickCount': serializer.toJson<int?>(clickCount),
      'ripLogSource': serializer.toJson<String?>(ripLogSource),
      'qualityCheckedAt': serializer.toJson<int?>(qualityCheckedAt),
    };
  }

  RipTracksTableData copyWith({
    String? id,
    String? ripAlbumId,
    int? discNumber,
    int? trackNumber,
    Value<String?> title = const Value.absent(),
    String? filePath,
    Value<int?> durationMs = const Value.absent(),
    int? fileSizeBytes,
    int? updatedAt,
    Value<String?> accurateripStatus = const Value.absent(),
    Value<int?> accurateripConfidence = const Value.absent(),
    Value<String?> accurateripCrcV1 = const Value.absent(),
    Value<String?> accurateripCrcV2 = const Value.absent(),
    Value<double?> peakLevel = const Value.absent(),
    Value<double?> trackQuality = const Value.absent(),
    Value<String?> copyCrc = const Value.absent(),
    Value<int?> clickCount = const Value.absent(),
    Value<String?> ripLogSource = const Value.absent(),
    Value<int?> qualityCheckedAt = const Value.absent(),
  }) => RipTracksTableData(
    id: id ?? this.id,
    ripAlbumId: ripAlbumId ?? this.ripAlbumId,
    discNumber: discNumber ?? this.discNumber,
    trackNumber: trackNumber ?? this.trackNumber,
    title: title.present ? title.value : this.title,
    filePath: filePath ?? this.filePath,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    updatedAt: updatedAt ?? this.updatedAt,
    accurateripStatus: accurateripStatus.present
        ? accurateripStatus.value
        : this.accurateripStatus,
    accurateripConfidence: accurateripConfidence.present
        ? accurateripConfidence.value
        : this.accurateripConfidence,
    accurateripCrcV1: accurateripCrcV1.present
        ? accurateripCrcV1.value
        : this.accurateripCrcV1,
    accurateripCrcV2: accurateripCrcV2.present
        ? accurateripCrcV2.value
        : this.accurateripCrcV2,
    peakLevel: peakLevel.present ? peakLevel.value : this.peakLevel,
    trackQuality: trackQuality.present ? trackQuality.value : this.trackQuality,
    copyCrc: copyCrc.present ? copyCrc.value : this.copyCrc,
    clickCount: clickCount.present ? clickCount.value : this.clickCount,
    ripLogSource: ripLogSource.present ? ripLogSource.value : this.ripLogSource,
    qualityCheckedAt: qualityCheckedAt.present
        ? qualityCheckedAt.value
        : this.qualityCheckedAt,
  );
  RipTracksTableData copyWithCompanion(RipTracksTableCompanion data) {
    return RipTracksTableData(
      id: data.id.present ? data.id.value : this.id,
      ripAlbumId: data.ripAlbumId.present
          ? data.ripAlbumId.value
          : this.ripAlbumId,
      discNumber: data.discNumber.present
          ? data.discNumber.value
          : this.discNumber,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      accurateripStatus: data.accurateripStatus.present
          ? data.accurateripStatus.value
          : this.accurateripStatus,
      accurateripConfidence: data.accurateripConfidence.present
          ? data.accurateripConfidence.value
          : this.accurateripConfidence,
      accurateripCrcV1: data.accurateripCrcV1.present
          ? data.accurateripCrcV1.value
          : this.accurateripCrcV1,
      accurateripCrcV2: data.accurateripCrcV2.present
          ? data.accurateripCrcV2.value
          : this.accurateripCrcV2,
      peakLevel: data.peakLevel.present ? data.peakLevel.value : this.peakLevel,
      trackQuality: data.trackQuality.present
          ? data.trackQuality.value
          : this.trackQuality,
      copyCrc: data.copyCrc.present ? data.copyCrc.value : this.copyCrc,
      clickCount: data.clickCount.present
          ? data.clickCount.value
          : this.clickCount,
      ripLogSource: data.ripLogSource.present
          ? data.ripLogSource.value
          : this.ripLogSource,
      qualityCheckedAt: data.qualityCheckedAt.present
          ? data.qualityCheckedAt.value
          : this.qualityCheckedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RipTracksTableData(')
          ..write('id: $id, ')
          ..write('ripAlbumId: $ripAlbumId, ')
          ..write('discNumber: $discNumber, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('accurateripStatus: $accurateripStatus, ')
          ..write('accurateripConfidence: $accurateripConfidence, ')
          ..write('accurateripCrcV1: $accurateripCrcV1, ')
          ..write('accurateripCrcV2: $accurateripCrcV2, ')
          ..write('peakLevel: $peakLevel, ')
          ..write('trackQuality: $trackQuality, ')
          ..write('copyCrc: $copyCrc, ')
          ..write('clickCount: $clickCount, ')
          ..write('ripLogSource: $ripLogSource, ')
          ..write('qualityCheckedAt: $qualityCheckedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ripAlbumId,
    discNumber,
    trackNumber,
    title,
    filePath,
    durationMs,
    fileSizeBytes,
    updatedAt,
    accurateripStatus,
    accurateripConfidence,
    accurateripCrcV1,
    accurateripCrcV2,
    peakLevel,
    trackQuality,
    copyCrc,
    clickCount,
    ripLogSource,
    qualityCheckedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RipTracksTableData &&
          other.id == this.id &&
          other.ripAlbumId == this.ripAlbumId &&
          other.discNumber == this.discNumber &&
          other.trackNumber == this.trackNumber &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.durationMs == this.durationMs &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.updatedAt == this.updatedAt &&
          other.accurateripStatus == this.accurateripStatus &&
          other.accurateripConfidence == this.accurateripConfidence &&
          other.accurateripCrcV1 == this.accurateripCrcV1 &&
          other.accurateripCrcV2 == this.accurateripCrcV2 &&
          other.peakLevel == this.peakLevel &&
          other.trackQuality == this.trackQuality &&
          other.copyCrc == this.copyCrc &&
          other.clickCount == this.clickCount &&
          other.ripLogSource == this.ripLogSource &&
          other.qualityCheckedAt == this.qualityCheckedAt);
}

class RipTracksTableCompanion extends UpdateCompanion<RipTracksTableData> {
  final Value<String> id;
  final Value<String> ripAlbumId;
  final Value<int> discNumber;
  final Value<int> trackNumber;
  final Value<String?> title;
  final Value<String> filePath;
  final Value<int?> durationMs;
  final Value<int> fileSizeBytes;
  final Value<int> updatedAt;
  final Value<String?> accurateripStatus;
  final Value<int?> accurateripConfidence;
  final Value<String?> accurateripCrcV1;
  final Value<String?> accurateripCrcV2;
  final Value<double?> peakLevel;
  final Value<double?> trackQuality;
  final Value<String?> copyCrc;
  final Value<int?> clickCount;
  final Value<String?> ripLogSource;
  final Value<int?> qualityCheckedAt;
  final Value<int> rowid;
  const RipTracksTableCompanion({
    this.id = const Value.absent(),
    this.ripAlbumId = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.accurateripStatus = const Value.absent(),
    this.accurateripConfidence = const Value.absent(),
    this.accurateripCrcV1 = const Value.absent(),
    this.accurateripCrcV2 = const Value.absent(),
    this.peakLevel = const Value.absent(),
    this.trackQuality = const Value.absent(),
    this.copyCrc = const Value.absent(),
    this.clickCount = const Value.absent(),
    this.ripLogSource = const Value.absent(),
    this.qualityCheckedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RipTracksTableCompanion.insert({
    required String id,
    required String ripAlbumId,
    this.discNumber = const Value.absent(),
    required int trackNumber,
    this.title = const Value.absent(),
    required String filePath,
    this.durationMs = const Value.absent(),
    required int fileSizeBytes,
    required int updatedAt,
    this.accurateripStatus = const Value.absent(),
    this.accurateripConfidence = const Value.absent(),
    this.accurateripCrcV1 = const Value.absent(),
    this.accurateripCrcV2 = const Value.absent(),
    this.peakLevel = const Value.absent(),
    this.trackQuality = const Value.absent(),
    this.copyCrc = const Value.absent(),
    this.clickCount = const Value.absent(),
    this.ripLogSource = const Value.absent(),
    this.qualityCheckedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ripAlbumId = Value(ripAlbumId),
       trackNumber = Value(trackNumber),
       filePath = Value(filePath),
       fileSizeBytes = Value(fileSizeBytes),
       updatedAt = Value(updatedAt);
  static Insertable<RipTracksTableData> custom({
    Expression<String>? id,
    Expression<String>? ripAlbumId,
    Expression<int>? discNumber,
    Expression<int>? trackNumber,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<int>? durationMs,
    Expression<int>? fileSizeBytes,
    Expression<int>? updatedAt,
    Expression<String>? accurateripStatus,
    Expression<int>? accurateripConfidence,
    Expression<String>? accurateripCrcV1,
    Expression<String>? accurateripCrcV2,
    Expression<double>? peakLevel,
    Expression<double>? trackQuality,
    Expression<String>? copyCrc,
    Expression<int>? clickCount,
    Expression<String>? ripLogSource,
    Expression<int>? qualityCheckedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ripAlbumId != null) 'rip_album_id': ripAlbumId,
      if (discNumber != null) 'disc_number': discNumber,
      if (trackNumber != null) 'track_number': trackNumber,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (durationMs != null) 'duration_ms': durationMs,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (accurateripStatus != null) 'accuraterip_status': accurateripStatus,
      if (accurateripConfidence != null)
        'accuraterip_confidence': accurateripConfidence,
      if (accurateripCrcV1 != null) 'accuraterip_crc_v1': accurateripCrcV1,
      if (accurateripCrcV2 != null) 'accuraterip_crc_v2': accurateripCrcV2,
      if (peakLevel != null) 'peak_level': peakLevel,
      if (trackQuality != null) 'track_quality': trackQuality,
      if (copyCrc != null) 'copy_crc': copyCrc,
      if (clickCount != null) 'click_count': clickCount,
      if (ripLogSource != null) 'rip_log_source': ripLogSource,
      if (qualityCheckedAt != null) 'quality_checked_at': qualityCheckedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RipTracksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? ripAlbumId,
    Value<int>? discNumber,
    Value<int>? trackNumber,
    Value<String?>? title,
    Value<String>? filePath,
    Value<int?>? durationMs,
    Value<int>? fileSizeBytes,
    Value<int>? updatedAt,
    Value<String?>? accurateripStatus,
    Value<int?>? accurateripConfidence,
    Value<String?>? accurateripCrcV1,
    Value<String?>? accurateripCrcV2,
    Value<double?>? peakLevel,
    Value<double?>? trackQuality,
    Value<String?>? copyCrc,
    Value<int?>? clickCount,
    Value<String?>? ripLogSource,
    Value<int?>? qualityCheckedAt,
    Value<int>? rowid,
  }) {
    return RipTracksTableCompanion(
      id: id ?? this.id,
      ripAlbumId: ripAlbumId ?? this.ripAlbumId,
      discNumber: discNumber ?? this.discNumber,
      trackNumber: trackNumber ?? this.trackNumber,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      updatedAt: updatedAt ?? this.updatedAt,
      accurateripStatus: accurateripStatus ?? this.accurateripStatus,
      accurateripConfidence:
          accurateripConfidence ?? this.accurateripConfidence,
      accurateripCrcV1: accurateripCrcV1 ?? this.accurateripCrcV1,
      accurateripCrcV2: accurateripCrcV2 ?? this.accurateripCrcV2,
      peakLevel: peakLevel ?? this.peakLevel,
      trackQuality: trackQuality ?? this.trackQuality,
      copyCrc: copyCrc ?? this.copyCrc,
      clickCount: clickCount ?? this.clickCount,
      ripLogSource: ripLogSource ?? this.ripLogSource,
      qualityCheckedAt: qualityCheckedAt ?? this.qualityCheckedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ripAlbumId.present) {
      map['rip_album_id'] = Variable<String>(ripAlbumId.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (accurateripStatus.present) {
      map['accuraterip_status'] = Variable<String>(accurateripStatus.value);
    }
    if (accurateripConfidence.present) {
      map['accuraterip_confidence'] = Variable<int>(
        accurateripConfidence.value,
      );
    }
    if (accurateripCrcV1.present) {
      map['accuraterip_crc_v1'] = Variable<String>(accurateripCrcV1.value);
    }
    if (accurateripCrcV2.present) {
      map['accuraterip_crc_v2'] = Variable<String>(accurateripCrcV2.value);
    }
    if (peakLevel.present) {
      map['peak_level'] = Variable<double>(peakLevel.value);
    }
    if (trackQuality.present) {
      map['track_quality'] = Variable<double>(trackQuality.value);
    }
    if (copyCrc.present) {
      map['copy_crc'] = Variable<String>(copyCrc.value);
    }
    if (clickCount.present) {
      map['click_count'] = Variable<int>(clickCount.value);
    }
    if (ripLogSource.present) {
      map['rip_log_source'] = Variable<String>(ripLogSource.value);
    }
    if (qualityCheckedAt.present) {
      map['quality_checked_at'] = Variable<int>(qualityCheckedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RipTracksTableCompanion(')
          ..write('id: $id, ')
          ..write('ripAlbumId: $ripAlbumId, ')
          ..write('discNumber: $discNumber, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('accurateripStatus: $accurateripStatus, ')
          ..write('accurateripConfidence: $accurateripConfidence, ')
          ..write('accurateripCrcV1: $accurateripCrcV1, ')
          ..write('accurateripCrcV2: $accurateripCrcV2, ')
          ..write('peakLevel: $peakLevel, ')
          ..write('trackQuality: $trackQuality, ')
          ..write('copyCrc: $copyCrc, ')
          ..write('clickCount: $clickCount, ')
          ..write('ripLogSource: $ripLogSource, ')
          ..write('qualityCheckedAt: $qualityCheckedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchSessionsTableTable extends BatchSessionsTable
    with TableInfo<$BatchSessionsTableTable, BatchSessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    completedAt,
    status,
    itemCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batch_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchSessionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatchSessionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchSessionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
    );
  }

  @override
  $BatchSessionsTableTable createAlias(String alias) {
    return $BatchSessionsTableTable(attachedDatabase, alias);
  }
}

class BatchSessionsTableData extends DataClass
    implements Insertable<BatchSessionsTableData> {
  final String id;
  final int createdAt;
  final int? completedAt;
  final String status;
  final int itemCount;
  const BatchSessionsTableData({
    required this.id,
    required this.createdAt,
    this.completedAt,
    required this.status,
    required this.itemCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['status'] = Variable<String>(status);
    map['item_count'] = Variable<int>(itemCount);
    return map;
  }

  BatchSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return BatchSessionsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
      itemCount: Value(itemCount),
    );
  }

  factory BatchSessionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchSessionsTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      status: serializer.fromJson<String>(json['status']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'status': serializer.toJson<String>(status),
      'itemCount': serializer.toJson<int>(itemCount),
    };
  }

  BatchSessionsTableData copyWith({
    String? id,
    int? createdAt,
    Value<int?> completedAt = const Value.absent(),
    String? status,
    int? itemCount,
  }) => BatchSessionsTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    status: status ?? this.status,
    itemCount: itemCount ?? this.itemCount,
  );
  BatchSessionsTableData copyWithCompanion(BatchSessionsTableCompanion data) {
    return BatchSessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchSessionsTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('itemCount: $itemCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, completedAt, status, itemCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchSessionsTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status &&
          other.itemCount == this.itemCount);
}

class BatchSessionsTableCompanion
    extends UpdateCompanion<BatchSessionsTableData> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int?> completedAt;
  final Value<String> status;
  final Value<int> itemCount;
  final Value<int> rowid;
  const BatchSessionsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchSessionsTableCompanion.insert({
    required String id,
    required int createdAt,
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt);
  static Insertable<BatchSessionsTableData> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? completedAt,
    Expression<String>? status,
    Expression<int>? itemCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
      if (itemCount != null) 'item_count': itemCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchSessionsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int?>? completedAt,
    Value<String>? status,
    Value<int>? itemCount,
    Value<int>? rowid,
  }) {
    return BatchSessionsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      itemCount: itemCount ?? this.itemCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('itemCount: $itemCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchQueueItemsTableTable extends BatchQueueItemsTable
    with TableInfo<$BatchQueueItemsTableTable, BatchQueueItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchQueueItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<int> scannedAt = GeneratedColumn<int>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scanResultJsonMeta = const VerificationMeta(
    'scanResultJson',
  );
  @override
  late final GeneratedColumn<String> scanResultJson = GeneratedColumn<String>(
    'scan_result_json',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    barcode,
    barcodeType,
    status,
    scannedAt,
    metadataJson,
    scanResultJson,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batch_queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchQueueItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('scan_result_json')) {
      context.handle(
        _scanResultJsonMeta,
        scanResultJson.isAcceptableOrUnknown(
          data['scan_result_json']!,
          _scanResultJsonMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatchQueueItemsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchQueueItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      barcodeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scanned_at'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      scanResultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_result_json'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $BatchQueueItemsTableTable createAlias(String alias) {
    return $BatchQueueItemsTableTable(attachedDatabase, alias);
  }
}

class BatchQueueItemsTableData extends DataClass
    implements Insertable<BatchQueueItemsTableData> {
  final String id;
  final String sessionId;
  final String barcode;
  final String barcodeType;
  final String status;
  final int scannedAt;
  final String? metadataJson;
  final String? scanResultJson;
  final int sortOrder;
  const BatchQueueItemsTableData({
    required this.id,
    required this.sessionId,
    required this.barcode,
    required this.barcodeType,
    required this.status,
    required this.scannedAt,
    this.metadataJson,
    this.scanResultJson,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['barcode'] = Variable<String>(barcode);
    map['barcode_type'] = Variable<String>(barcodeType);
    map['status'] = Variable<String>(status);
    map['scanned_at'] = Variable<int>(scannedAt);
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    if (!nullToAbsent || scanResultJson != null) {
      map['scan_result_json'] = Variable<String>(scanResultJson);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  BatchQueueItemsTableCompanion toCompanion(bool nullToAbsent) {
    return BatchQueueItemsTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      barcode: Value(barcode),
      barcodeType: Value(barcodeType),
      status: Value(status),
      scannedAt: Value(scannedAt),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      scanResultJson: scanResultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(scanResultJson),
      sortOrder: Value(sortOrder),
    );
  }

  factory BatchQueueItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchQueueItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      barcode: serializer.fromJson<String>(json['barcode']),
      barcodeType: serializer.fromJson<String>(json['barcodeType']),
      status: serializer.fromJson<String>(json['status']),
      scannedAt: serializer.fromJson<int>(json['scannedAt']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      scanResultJson: serializer.fromJson<String?>(json['scanResultJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'barcode': serializer.toJson<String>(barcode),
      'barcodeType': serializer.toJson<String>(barcodeType),
      'status': serializer.toJson<String>(status),
      'scannedAt': serializer.toJson<int>(scannedAt),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'scanResultJson': serializer.toJson<String?>(scanResultJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  BatchQueueItemsTableData copyWith({
    String? id,
    String? sessionId,
    String? barcode,
    String? barcodeType,
    String? status,
    int? scannedAt,
    Value<String?> metadataJson = const Value.absent(),
    Value<String?> scanResultJson = const Value.absent(),
    int? sortOrder,
  }) => BatchQueueItemsTableData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    barcode: barcode ?? this.barcode,
    barcodeType: barcodeType ?? this.barcodeType,
    status: status ?? this.status,
    scannedAt: scannedAt ?? this.scannedAt,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    scanResultJson: scanResultJson.present
        ? scanResultJson.value
        : this.scanResultJson,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  BatchQueueItemsTableData copyWithCompanion(
    BatchQueueItemsTableCompanion data,
  ) {
    return BatchQueueItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      barcodeType: data.barcodeType.present
          ? data.barcodeType.value
          : this.barcodeType,
      status: data.status.present ? data.status.value : this.status,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      scanResultJson: data.scanResultJson.present
          ? data.scanResultJson.value
          : this.scanResultJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchQueueItemsTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('barcode: $barcode, ')
          ..write('barcodeType: $barcodeType, ')
          ..write('status: $status, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('scanResultJson: $scanResultJson, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    barcode,
    barcodeType,
    status,
    scannedAt,
    metadataJson,
    scanResultJson,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchQueueItemsTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.barcode == this.barcode &&
          other.barcodeType == this.barcodeType &&
          other.status == this.status &&
          other.scannedAt == this.scannedAt &&
          other.metadataJson == this.metadataJson &&
          other.scanResultJson == this.scanResultJson &&
          other.sortOrder == this.sortOrder);
}

class BatchQueueItemsTableCompanion
    extends UpdateCompanion<BatchQueueItemsTableData> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> barcode;
  final Value<String> barcodeType;
  final Value<String> status;
  final Value<int> scannedAt;
  final Value<String?> metadataJson;
  final Value<String?> scanResultJson;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const BatchQueueItemsTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.barcode = const Value.absent(),
    this.barcodeType = const Value.absent(),
    this.status = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.scanResultJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchQueueItemsTableCompanion.insert({
    required String id,
    required String sessionId,
    required String barcode,
    required String barcodeType,
    required String status,
    required int scannedAt,
    this.metadataJson = const Value.absent(),
    this.scanResultJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       barcode = Value(barcode),
       barcodeType = Value(barcodeType),
       status = Value(status),
       scannedAt = Value(scannedAt);
  static Insertable<BatchQueueItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? barcode,
    Expression<String>? barcodeType,
    Expression<String>? status,
    Expression<int>? scannedAt,
    Expression<String>? metadataJson,
    Expression<String>? scanResultJson,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (barcode != null) 'barcode': barcode,
      if (barcodeType != null) 'barcode_type': barcodeType,
      if (status != null) 'status': status,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (scanResultJson != null) 'scan_result_json': scanResultJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchQueueItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? barcode,
    Value<String>? barcodeType,
    Value<String>? status,
    Value<int>? scannedAt,
    Value<String?>? metadataJson,
    Value<String?>? scanResultJson,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return BatchQueueItemsTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      barcode: barcode ?? this.barcode,
      barcodeType: barcodeType ?? this.barcodeType,
      status: status ?? this.status,
      scannedAt: scannedAt ?? this.scannedAt,
      metadataJson: metadataJson ?? this.metadataJson,
      scanResultJson: scanResultJson ?? this.scanResultJson,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (barcodeType.present) {
      map['barcode_type'] = Variable<String>(barcodeType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<int>(scannedAt.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (scanResultJson.present) {
      map['scan_result_json'] = Variable<String>(scanResultJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchQueueItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('barcode: $barcode, ')
          ..write('barcodeType: $barcodeType, ')
          ..write('status: $status, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('scanResultJson: $scanResultJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTableTable extends PlaylistsTable
    with TableInfo<$PlaylistsTableTable, PlaylistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _coverAlbumIdMeta = const VerificationMeta(
    'coverAlbumId',
  );
  @override
  late final GeneratedColumn<String> coverAlbumId = GeneratedColumn<String>(
    'cover_album_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    coverAlbumId,
    createdAt,
    updatedAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistsTableData> instance, {
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
    if (data.containsKey('cover_album_id')) {
      context.handle(
        _coverAlbumIdMeta,
        coverAlbumId.isAcceptableOrUnknown(
          data['cover_album_id']!,
          _coverAlbumIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  PlaylistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistsTableData(
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
      coverAlbumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_album_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
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
  $PlaylistsTableTable createAlias(String alias) {
    return $PlaylistsTableTable(attachedDatabase, alias);
  }
}

class PlaylistsTableData extends DataClass
    implements Insertable<PlaylistsTableData> {
  final String id;
  final String name;
  final String? description;
  final String? coverAlbumId;
  final int createdAt;
  final int updatedAt;
  final int deleted;
  const PlaylistsTableData({
    required this.id,
    required this.name,
    this.description,
    this.coverAlbumId,
    required this.createdAt,
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
    if (!nullToAbsent || coverAlbumId != null) {
      map['cover_album_id'] = Variable<String>(coverAlbumId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  PlaylistsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverAlbumId: coverAlbumId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverAlbumId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
    );
  }

  factory PlaylistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      coverAlbumId: serializer.fromJson<String?>(json['coverAlbumId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
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
      'coverAlbumId': serializer.toJson<String?>(coverAlbumId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  PlaylistsTableData copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> coverAlbumId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? deleted,
  }) => PlaylistsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    coverAlbumId: coverAlbumId.present ? coverAlbumId.value : this.coverAlbumId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
  PlaylistsTableData copyWithCompanion(PlaylistsTableCompanion data) {
    return PlaylistsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverAlbumId: data.coverAlbumId.present
          ? data.coverAlbumId.value
          : this.coverAlbumId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverAlbumId: $coverAlbumId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    coverAlbumId,
    createdAt,
    updatedAt,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverAlbumId == this.coverAlbumId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted);
}

class PlaylistsTableCompanion extends UpdateCompanion<PlaylistsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> coverAlbumId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const PlaylistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverAlbumId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.coverAlbumId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlaylistsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverAlbumId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverAlbumId != null) 'cover_album_id': coverAlbumId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? coverAlbumId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return PlaylistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverAlbumId: coverAlbumId ?? this.coverAlbumId,
      createdAt: createdAt ?? this.createdAt,
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
    if (coverAlbumId.present) {
      map['cover_album_id'] = Variable<String>(coverAlbumId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
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
    return (StringBuffer('PlaylistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverAlbumId: $coverAlbumId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTracksTableTable extends PlaylistTracksTable
    with TableInfo<$PlaylistTracksTableTable, PlaylistTracksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTracksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ripTrackIdMeta = const VerificationMeta(
    'ripTrackId',
  );
  @override
  late final GeneratedColumn<String> ripTrackId = GeneratedColumn<String>(
    'rip_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rip_tracks (id) ON DELETE CASCADE',
    ),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playlistId,
    ripTrackId,
    sortOrder,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTracksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('rip_track_id')) {
      context.handle(
        _ripTrackIdMeta,
        ripTrackId.isAcceptableOrUnknown(
          data['rip_track_id']!,
          _ripTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ripTrackIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistTracksTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTracksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      ripTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rip_track_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $PlaylistTracksTableTable createAlias(String alias) {
    return $PlaylistTracksTableTable(attachedDatabase, alias);
  }
}

class PlaylistTracksTableData extends DataClass
    implements Insertable<PlaylistTracksTableData> {
  final String id;
  final String playlistId;
  final String ripTrackId;
  final int sortOrder;
  final int addedAt;
  const PlaylistTracksTableData({
    required this.id,
    required this.playlistId,
    required this.ripTrackId,
    required this.sortOrder,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['playlist_id'] = Variable<String>(playlistId);
    map['rip_track_id'] = Variable<String>(ripTrackId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['added_at'] = Variable<int>(addedAt);
    return map;
  }

  PlaylistTracksTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTracksTableCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      ripTrackId: Value(ripTrackId),
      sortOrder: Value(sortOrder),
      addedAt: Value(addedAt),
    );
  }

  factory PlaylistTracksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTracksTableData(
      id: serializer.fromJson<String>(json['id']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      ripTrackId: serializer.fromJson<String>(json['ripTrackId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'playlistId': serializer.toJson<String>(playlistId),
      'ripTrackId': serializer.toJson<String>(ripTrackId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'addedAt': serializer.toJson<int>(addedAt),
    };
  }

  PlaylistTracksTableData copyWith({
    String? id,
    String? playlistId,
    String? ripTrackId,
    int? sortOrder,
    int? addedAt,
  }) => PlaylistTracksTableData(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    ripTrackId: ripTrackId ?? this.ripTrackId,
    sortOrder: sortOrder ?? this.sortOrder,
    addedAt: addedAt ?? this.addedAt,
  );
  PlaylistTracksTableData copyWithCompanion(PlaylistTracksTableCompanion data) {
    return PlaylistTracksTableData(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      ripTrackId: data.ripTrackId.present
          ? data.ripTrackId.value
          : this.ripTrackId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksTableData(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('ripTrackId: $ripTrackId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, playlistId, ripTrackId, sortOrder, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTracksTableData &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.ripTrackId == this.ripTrackId &&
          other.sortOrder == this.sortOrder &&
          other.addedAt == this.addedAt);
}

class PlaylistTracksTableCompanion
    extends UpdateCompanion<PlaylistTracksTableData> {
  final Value<String> id;
  final Value<String> playlistId;
  final Value<String> ripTrackId;
  final Value<int> sortOrder;
  final Value<int> addedAt;
  final Value<int> rowid;
  const PlaylistTracksTableCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.ripTrackId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTracksTableCompanion.insert({
    required String id,
    required String playlistId,
    required String ripTrackId,
    required int sortOrder,
    required int addedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       playlistId = Value(playlistId),
       ripTrackId = Value(ripTrackId),
       sortOrder = Value(sortOrder),
       addedAt = Value(addedAt);
  static Insertable<PlaylistTracksTableData> custom({
    Expression<String>? id,
    Expression<String>? playlistId,
    Expression<String>? ripTrackId,
    Expression<int>? sortOrder,
    Expression<int>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (ripTrackId != null) 'rip_track_id': ripTrackId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTracksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? playlistId,
    Value<String>? ripTrackId,
    Value<int>? sortOrder,
    Value<int>? addedAt,
    Value<int>? rowid,
  }) {
    return PlaylistTracksTableCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      ripTrackId: ripTrackId ?? this.ripTrackId,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (ripTrackId.present) {
      map['rip_track_id'] = Variable<String>(ripTrackId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksTableCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('ripTrackId: $ripTrackId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTableTable extends LocationsTable
    with TableInfo<$LocationsTableTable, LocationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    parentId,
    name,
    sortOrder,
    updatedAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  LocationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
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
  $LocationsTableTable createAlias(String alias) {
    return $LocationsTableTable(attachedDatabase, alias);
  }
}

class LocationsTableData extends DataClass
    implements Insertable<LocationsTableData> {
  final String id;
  final String? parentId;
  final String name;
  final int sortOrder;
  final int updatedAt;
  final int deleted;
  const LocationsTableData({
    required this.id,
    this.parentId,
    required this.name,
    required this.sortOrder,
    required this.updatedAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  LocationsTableCompanion toCompanion(bool nullToAbsent) {
    return LocationsTableCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
    );
  }

  factory LocationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationsTableData(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
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
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  LocationsTableData copyWith({
    String? id,
    Value<String?> parentId = const Value.absent(),
    String? name,
    int? sortOrder,
    int? updatedAt,
    int? deleted,
  }) => LocationsTableData(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
  LocationsTableData copyWithCompanion(LocationsTableCompanion data) {
    return LocationsTableData(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationsTableData(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, parentId, name, sortOrder, updatedAt, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationsTableData &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted);
}

class LocationsTableCompanion extends UpdateCompanion<LocationsTableData> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> updatedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const LocationsTableCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsTableCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    required int updatedAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<LocationsTableData> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? updatedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? parentId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? updatedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return LocationsTableCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
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
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('LocationsTableCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesTableTable extends SeriesTable
    with TableInfo<$SeriesTableTable, SeriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
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
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    externalId,
    name,
    mediaType,
    source,
    totalCount,
    updatedAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {externalId},
  ];
  @override
  SeriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
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
  $SeriesTableTable createAlias(String alias) {
    return $SeriesTableTable(attachedDatabase, alias);
  }
}

class SeriesTableData extends DataClass implements Insertable<SeriesTableData> {
  final String id;
  final String externalId;
  final String name;
  final String mediaType;
  final String source;
  final int? totalCount;
  final int updatedAt;
  final int deleted;
  const SeriesTableData({
    required this.id,
    required this.externalId,
    required this.name,
    required this.mediaType,
    required this.source,
    this.totalCount,
    required this.updatedAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['external_id'] = Variable<String>(externalId);
    map['name'] = Variable<String>(name);
    map['media_type'] = Variable<String>(mediaType);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || totalCount != null) {
      map['total_count'] = Variable<int>(totalCount);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  SeriesTableCompanion toCompanion(bool nullToAbsent) {
    return SeriesTableCompanion(
      id: Value(id),
      externalId: Value(externalId),
      name: Value(name),
      mediaType: Value(mediaType),
      source: Value(source),
      totalCount: totalCount == null && nullToAbsent
          ? const Value.absent()
          : Value(totalCount),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
    );
  }

  factory SeriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesTableData(
      id: serializer.fromJson<String>(json['id']),
      externalId: serializer.fromJson<String>(json['externalId']),
      name: serializer.fromJson<String>(json['name']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      source: serializer.fromJson<String>(json['source']),
      totalCount: serializer.fromJson<int?>(json['totalCount']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'externalId': serializer.toJson<String>(externalId),
      'name': serializer.toJson<String>(name),
      'mediaType': serializer.toJson<String>(mediaType),
      'source': serializer.toJson<String>(source),
      'totalCount': serializer.toJson<int?>(totalCount),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  SeriesTableData copyWith({
    String? id,
    String? externalId,
    String? name,
    String? mediaType,
    String? source,
    Value<int?> totalCount = const Value.absent(),
    int? updatedAt,
    int? deleted,
  }) => SeriesTableData(
    id: id ?? this.id,
    externalId: externalId ?? this.externalId,
    name: name ?? this.name,
    mediaType: mediaType ?? this.mediaType,
    source: source ?? this.source,
    totalCount: totalCount.present ? totalCount.value : this.totalCount,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
  SeriesTableData copyWithCompanion(SeriesTableCompanion data) {
    return SeriesTableData(
      id: data.id.present ? data.id.value : this.id,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      name: data.name.present ? data.name.value : this.name,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      source: data.source.present ? data.source.value : this.source,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesTableData(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('mediaType: $mediaType, ')
          ..write('source: $source, ')
          ..write('totalCount: $totalCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    externalId,
    name,
    mediaType,
    source,
    totalCount,
    updatedAt,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesTableData &&
          other.id == this.id &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.mediaType == this.mediaType &&
          other.source == this.source &&
          other.totalCount == this.totalCount &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted);
}

class SeriesTableCompanion extends UpdateCompanion<SeriesTableData> {
  final Value<String> id;
  final Value<String> externalId;
  final Value<String> name;
  final Value<String> mediaType;
  final Value<String> source;
  final Value<int?> totalCount;
  final Value<int> updatedAt;
  final Value<int> deleted;
  final Value<int> rowid;
  const SeriesTableCompanion({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.source = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesTableCompanion.insert({
    required String id,
    required String externalId,
    required String name,
    required String mediaType,
    required String source,
    this.totalCount = const Value.absent(),
    required int updatedAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       externalId = Value(externalId),
       name = Value(name),
       mediaType = Value(mediaType),
       source = Value(source),
       updatedAt = Value(updatedAt);
  static Insertable<SeriesTableData> custom({
    Expression<String>? id,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? mediaType,
    Expression<String>? source,
    Expression<int>? totalCount,
    Expression<int>? updatedAt,
    Expression<int>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (mediaType != null) 'media_type': mediaType,
      if (source != null) 'source': source,
      if (totalCount != null) 'total_count': totalCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? externalId,
    Value<String>? name,
    Value<String>? mediaType,
    Value<String>? source,
    Value<int?>? totalCount,
    Value<int>? updatedAt,
    Value<int>? deleted,
    Value<int>? rowid,
  }) {
    return SeriesTableCompanion(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      mediaType: mediaType ?? this.mediaType,
      source: source ?? this.source,
      totalCount: totalCount ?? this.totalCount,
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
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
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
    return (StringBuffer('SeriesTableCompanion(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('mediaType: $mediaType, ')
          ..write('source: $source, ')
          ..write('totalCount: $totalCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TmdbAccountSyncItemsTableTable extends TmdbAccountSyncItemsTable
    with
        TableInfo<
          $TmdbAccountSyncItemsTableTable,
          TmdbAccountSyncItemsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TmdbAccountSyncItemsTableTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tmdbMediaTypeMeta = const VerificationMeta(
    'tmdbMediaType',
  );
  @override
  late final GeneratedColumn<String> tmdbMediaType = GeneratedColumn<String>(
    'tmdb_media_type',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleSnapshotMeta = const VerificationMeta(
    'titleSnapshot',
  );
  @override
  late final GeneratedColumn<String> titleSnapshot = GeneratedColumn<String>(
    'title_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posterPathSnapshotMeta =
      const VerificationMeta('posterPathSnapshot');
  @override
  late final GeneratedColumn<String> posterPathSnapshot =
      GeneratedColumn<String>(
        'poster_path_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tmdbRatingMeta = const VerificationMeta(
    'tmdbRating',
  );
  @override
  late final GeneratedColumn<double> tmdbRating = GeneratedColumn<double>(
    'tmdb_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRatingSnapshotMeta =
      const VerificationMeta('localRatingSnapshot');
  @override
  late final GeneratedColumn<double> localRatingSnapshot =
      GeneratedColumn<double>(
        'local_rating_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _watchlistMeta = const VerificationMeta(
    'watchlist',
  );
  @override
  late final GeneratedColumn<int> watchlist = GeneratedColumn<int>(
    'watchlist',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<int> favorite = GeneratedColumn<int>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _listIdsJsonMeta = const VerificationMeta(
    'listIdsJson',
  );
  @override
  late final GeneratedColumn<String> listIdsJson = GeneratedColumn<String>(
    'list_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _accountStateJsonMeta = const VerificationMeta(
    'accountStateJson',
  );
  @override
  late final GeneratedColumn<String> accountStateJson = GeneratedColumn<String>(
    'account_state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _localDirtyMeta = const VerificationMeta(
    'localDirty',
  );
  @override
  late final GeneratedColumn<int> localDirty = GeneratedColumn<int>(
    'local_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remoteDirtyMeta = const VerificationMeta(
    'remoteDirty',
  );
  @override
  late final GeneratedColumn<int> remoteDirty = GeneratedColumn<int>(
    'remote_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta(
    'lastPulledAt',
  );
  @override
  late final GeneratedColumn<int> lastPulledAt = GeneratedColumn<int>(
    'last_pulled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPushedAtMeta = const VerificationMeta(
    'lastPushedAt',
  );
  @override
  late final GeneratedColumn<int> lastPushedAt = GeneratedColumn<int>(
    'last_pushed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    tmdbId,
    tmdbMediaType,
    barcode,
    titleSnapshot,
    posterPathSnapshot,
    tmdbRating,
    localRatingSnapshot,
    watchlist,
    favorite,
    listIdsJson,
    accountStateJson,
    localDirty,
    remoteDirty,
    lastPulledAt,
    lastPushedAt,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tmdb_account_sync_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TmdbAccountSyncItemsTableData> instance, {
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
    }
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('tmdb_media_type')) {
      context.handle(
        _tmdbMediaTypeMeta,
        tmdbMediaType.isAcceptableOrUnknown(
          data['tmdb_media_type']!,
          _tmdbMediaTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tmdbMediaTypeMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('title_snapshot')) {
      context.handle(
        _titleSnapshotMeta,
        titleSnapshot.isAcceptableOrUnknown(
          data['title_snapshot']!,
          _titleSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('poster_path_snapshot')) {
      context.handle(
        _posterPathSnapshotMeta,
        posterPathSnapshot.isAcceptableOrUnknown(
          data['poster_path_snapshot']!,
          _posterPathSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('tmdb_rating')) {
      context.handle(
        _tmdbRatingMeta,
        tmdbRating.isAcceptableOrUnknown(data['tmdb_rating']!, _tmdbRatingMeta),
      );
    }
    if (data.containsKey('local_rating_snapshot')) {
      context.handle(
        _localRatingSnapshotMeta,
        localRatingSnapshot.isAcceptableOrUnknown(
          data['local_rating_snapshot']!,
          _localRatingSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('watchlist')) {
      context.handle(
        _watchlistMeta,
        watchlist.isAcceptableOrUnknown(data['watchlist']!, _watchlistMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('list_ids_json')) {
      context.handle(
        _listIdsJsonMeta,
        listIdsJson.isAcceptableOrUnknown(
          data['list_ids_json']!,
          _listIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('account_state_json')) {
      context.handle(
        _accountStateJsonMeta,
        accountStateJson.isAcceptableOrUnknown(
          data['account_state_json']!,
          _accountStateJsonMeta,
        ),
      );
    }
    if (data.containsKey('local_dirty')) {
      context.handle(
        _localDirtyMeta,
        localDirty.isAcceptableOrUnknown(data['local_dirty']!, _localDirtyMeta),
      );
    }
    if (data.containsKey('remote_dirty')) {
      context.handle(
        _remoteDirtyMeta,
        remoteDirty.isAcceptableOrUnknown(
          data['remote_dirty']!,
          _remoteDirtyMeta,
        ),
      );
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(
          data['last_pulled_at']!,
          _lastPulledAtMeta,
        ),
      );
    }
    if (data.containsKey('last_pushed_at')) {
      context.handle(
        _lastPushedAtMeta,
        lastPushedAt.isAcceptableOrUnknown(
          data['last_pushed_at']!,
          _lastPushedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tmdbId, tmdbMediaType},
  ];
  @override
  TmdbAccountSyncItemsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TmdbAccountSyncItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      ),
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      )!,
      tmdbMediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tmdb_media_type'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      titleSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_snapshot'],
      ),
      posterPathSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path_snapshot'],
      ),
      tmdbRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tmdb_rating'],
      ),
      localRatingSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}local_rating_snapshot'],
      ),
      watchlist: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}watchlist'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}favorite'],
      )!,
      listIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_ids_json'],
      )!,
      accountStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_state_json'],
      )!,
      localDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_dirty'],
      )!,
      remoteDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_dirty'],
      )!,
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pulled_at'],
      ),
      lastPushedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pushed_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TmdbAccountSyncItemsTableTable createAlias(String alias) {
    return $TmdbAccountSyncItemsTableTable(attachedDatabase, alias);
  }
}

class TmdbAccountSyncItemsTableData extends DataClass
    implements Insertable<TmdbAccountSyncItemsTableData> {
  final String id;
  final String? mediaItemId;
  final int tmdbId;
  final String tmdbMediaType;
  final String? barcode;
  final String? titleSnapshot;
  final String? posterPathSnapshot;
  final double? tmdbRating;
  final double? localRatingSnapshot;
  final int watchlist;
  final int favorite;
  final String listIdsJson;
  final String accountStateJson;
  final int localDirty;
  final int remoteDirty;
  final int? lastPulledAt;
  final int? lastPushedAt;
  final String? lastError;
  final int createdAt;
  final int updatedAt;
  const TmdbAccountSyncItemsTableData({
    required this.id,
    this.mediaItemId,
    required this.tmdbId,
    required this.tmdbMediaType,
    this.barcode,
    this.titleSnapshot,
    this.posterPathSnapshot,
    this.tmdbRating,
    this.localRatingSnapshot,
    required this.watchlist,
    required this.favorite,
    required this.listIdsJson,
    required this.accountStateJson,
    required this.localDirty,
    required this.remoteDirty,
    this.lastPulledAt,
    this.lastPushedAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || mediaItemId != null) {
      map['media_item_id'] = Variable<String>(mediaItemId);
    }
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['tmdb_media_type'] = Variable<String>(tmdbMediaType);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || titleSnapshot != null) {
      map['title_snapshot'] = Variable<String>(titleSnapshot);
    }
    if (!nullToAbsent || posterPathSnapshot != null) {
      map['poster_path_snapshot'] = Variable<String>(posterPathSnapshot);
    }
    if (!nullToAbsent || tmdbRating != null) {
      map['tmdb_rating'] = Variable<double>(tmdbRating);
    }
    if (!nullToAbsent || localRatingSnapshot != null) {
      map['local_rating_snapshot'] = Variable<double>(localRatingSnapshot);
    }
    map['watchlist'] = Variable<int>(watchlist);
    map['favorite'] = Variable<int>(favorite);
    map['list_ids_json'] = Variable<String>(listIdsJson);
    map['account_state_json'] = Variable<String>(accountStateJson);
    map['local_dirty'] = Variable<int>(localDirty);
    map['remote_dirty'] = Variable<int>(remoteDirty);
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt);
    }
    if (!nullToAbsent || lastPushedAt != null) {
      map['last_pushed_at'] = Variable<int>(lastPushedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TmdbAccountSyncItemsTableCompanion toCompanion(bool nullToAbsent) {
    return TmdbAccountSyncItemsTableCompanion(
      id: Value(id),
      mediaItemId: mediaItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaItemId),
      tmdbId: Value(tmdbId),
      tmdbMediaType: Value(tmdbMediaType),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      titleSnapshot: titleSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(titleSnapshot),
      posterPathSnapshot: posterPathSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(posterPathSnapshot),
      tmdbRating: tmdbRating == null && nullToAbsent
          ? const Value.absent()
          : Value(tmdbRating),
      localRatingSnapshot: localRatingSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(localRatingSnapshot),
      watchlist: Value(watchlist),
      favorite: Value(favorite),
      listIdsJson: Value(listIdsJson),
      accountStateJson: Value(accountStateJson),
      localDirty: Value(localDirty),
      remoteDirty: Value(remoteDirty),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
      lastPushedAt: lastPushedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TmdbAccountSyncItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TmdbAccountSyncItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String?>(json['mediaItemId']),
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      tmdbMediaType: serializer.fromJson<String>(json['tmdbMediaType']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      titleSnapshot: serializer.fromJson<String?>(json['titleSnapshot']),
      posterPathSnapshot: serializer.fromJson<String?>(
        json['posterPathSnapshot'],
      ),
      tmdbRating: serializer.fromJson<double?>(json['tmdbRating']),
      localRatingSnapshot: serializer.fromJson<double?>(
        json['localRatingSnapshot'],
      ),
      watchlist: serializer.fromJson<int>(json['watchlist']),
      favorite: serializer.fromJson<int>(json['favorite']),
      listIdsJson: serializer.fromJson<String>(json['listIdsJson']),
      accountStateJson: serializer.fromJson<String>(json['accountStateJson']),
      localDirty: serializer.fromJson<int>(json['localDirty']),
      remoteDirty: serializer.fromJson<int>(json['remoteDirty']),
      lastPulledAt: serializer.fromJson<int?>(json['lastPulledAt']),
      lastPushedAt: serializer.fromJson<int?>(json['lastPushedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String?>(mediaItemId),
      'tmdbId': serializer.toJson<int>(tmdbId),
      'tmdbMediaType': serializer.toJson<String>(tmdbMediaType),
      'barcode': serializer.toJson<String?>(barcode),
      'titleSnapshot': serializer.toJson<String?>(titleSnapshot),
      'posterPathSnapshot': serializer.toJson<String?>(posterPathSnapshot),
      'tmdbRating': serializer.toJson<double?>(tmdbRating),
      'localRatingSnapshot': serializer.toJson<double?>(localRatingSnapshot),
      'watchlist': serializer.toJson<int>(watchlist),
      'favorite': serializer.toJson<int>(favorite),
      'listIdsJson': serializer.toJson<String>(listIdsJson),
      'accountStateJson': serializer.toJson<String>(accountStateJson),
      'localDirty': serializer.toJson<int>(localDirty),
      'remoteDirty': serializer.toJson<int>(remoteDirty),
      'lastPulledAt': serializer.toJson<int?>(lastPulledAt),
      'lastPushedAt': serializer.toJson<int?>(lastPushedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TmdbAccountSyncItemsTableData copyWith({
    String? id,
    Value<String?> mediaItemId = const Value.absent(),
    int? tmdbId,
    String? tmdbMediaType,
    Value<String?> barcode = const Value.absent(),
    Value<String?> titleSnapshot = const Value.absent(),
    Value<String?> posterPathSnapshot = const Value.absent(),
    Value<double?> tmdbRating = const Value.absent(),
    Value<double?> localRatingSnapshot = const Value.absent(),
    int? watchlist,
    int? favorite,
    String? listIdsJson,
    String? accountStateJson,
    int? localDirty,
    int? remoteDirty,
    Value<int?> lastPulledAt = const Value.absent(),
    Value<int?> lastPushedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => TmdbAccountSyncItemsTableData(
    id: id ?? this.id,
    mediaItemId: mediaItemId.present ? mediaItemId.value : this.mediaItemId,
    tmdbId: tmdbId ?? this.tmdbId,
    tmdbMediaType: tmdbMediaType ?? this.tmdbMediaType,
    barcode: barcode.present ? barcode.value : this.barcode,
    titleSnapshot: titleSnapshot.present
        ? titleSnapshot.value
        : this.titleSnapshot,
    posterPathSnapshot: posterPathSnapshot.present
        ? posterPathSnapshot.value
        : this.posterPathSnapshot,
    tmdbRating: tmdbRating.present ? tmdbRating.value : this.tmdbRating,
    localRatingSnapshot: localRatingSnapshot.present
        ? localRatingSnapshot.value
        : this.localRatingSnapshot,
    watchlist: watchlist ?? this.watchlist,
    favorite: favorite ?? this.favorite,
    listIdsJson: listIdsJson ?? this.listIdsJson,
    accountStateJson: accountStateJson ?? this.accountStateJson,
    localDirty: localDirty ?? this.localDirty,
    remoteDirty: remoteDirty ?? this.remoteDirty,
    lastPulledAt: lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
    lastPushedAt: lastPushedAt.present ? lastPushedAt.value : this.lastPushedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TmdbAccountSyncItemsTableData copyWithCompanion(
    TmdbAccountSyncItemsTableCompanion data,
  ) {
    return TmdbAccountSyncItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      tmdbMediaType: data.tmdbMediaType.present
          ? data.tmdbMediaType.value
          : this.tmdbMediaType,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      titleSnapshot: data.titleSnapshot.present
          ? data.titleSnapshot.value
          : this.titleSnapshot,
      posterPathSnapshot: data.posterPathSnapshot.present
          ? data.posterPathSnapshot.value
          : this.posterPathSnapshot,
      tmdbRating: data.tmdbRating.present
          ? data.tmdbRating.value
          : this.tmdbRating,
      localRatingSnapshot: data.localRatingSnapshot.present
          ? data.localRatingSnapshot.value
          : this.localRatingSnapshot,
      watchlist: data.watchlist.present ? data.watchlist.value : this.watchlist,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      listIdsJson: data.listIdsJson.present
          ? data.listIdsJson.value
          : this.listIdsJson,
      accountStateJson: data.accountStateJson.present
          ? data.accountStateJson.value
          : this.accountStateJson,
      localDirty: data.localDirty.present
          ? data.localDirty.value
          : this.localDirty,
      remoteDirty: data.remoteDirty.present
          ? data.remoteDirty.value
          : this.remoteDirty,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
      lastPushedAt: data.lastPushedAt.present
          ? data.lastPushedAt.value
          : this.lastPushedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TmdbAccountSyncItemsTableData(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('tmdbMediaType: $tmdbMediaType, ')
          ..write('barcode: $barcode, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('posterPathSnapshot: $posterPathSnapshot, ')
          ..write('tmdbRating: $tmdbRating, ')
          ..write('localRatingSnapshot: $localRatingSnapshot, ')
          ..write('watchlist: $watchlist, ')
          ..write('favorite: $favorite, ')
          ..write('listIdsJson: $listIdsJson, ')
          ..write('accountStateJson: $accountStateJson, ')
          ..write('localDirty: $localDirty, ')
          ..write('remoteDirty: $remoteDirty, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaItemId,
    tmdbId,
    tmdbMediaType,
    barcode,
    titleSnapshot,
    posterPathSnapshot,
    tmdbRating,
    localRatingSnapshot,
    watchlist,
    favorite,
    listIdsJson,
    accountStateJson,
    localDirty,
    remoteDirty,
    lastPulledAt,
    lastPushedAt,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TmdbAccountSyncItemsTableData &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.tmdbId == this.tmdbId &&
          other.tmdbMediaType == this.tmdbMediaType &&
          other.barcode == this.barcode &&
          other.titleSnapshot == this.titleSnapshot &&
          other.posterPathSnapshot == this.posterPathSnapshot &&
          other.tmdbRating == this.tmdbRating &&
          other.localRatingSnapshot == this.localRatingSnapshot &&
          other.watchlist == this.watchlist &&
          other.favorite == this.favorite &&
          other.listIdsJson == this.listIdsJson &&
          other.accountStateJson == this.accountStateJson &&
          other.localDirty == this.localDirty &&
          other.remoteDirty == this.remoteDirty &&
          other.lastPulledAt == this.lastPulledAt &&
          other.lastPushedAt == this.lastPushedAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TmdbAccountSyncItemsTableCompanion
    extends UpdateCompanion<TmdbAccountSyncItemsTableData> {
  final Value<String> id;
  final Value<String?> mediaItemId;
  final Value<int> tmdbId;
  final Value<String> tmdbMediaType;
  final Value<String?> barcode;
  final Value<String?> titleSnapshot;
  final Value<String?> posterPathSnapshot;
  final Value<double?> tmdbRating;
  final Value<double?> localRatingSnapshot;
  final Value<int> watchlist;
  final Value<int> favorite;
  final Value<String> listIdsJson;
  final Value<String> accountStateJson;
  final Value<int> localDirty;
  final Value<int> remoteDirty;
  final Value<int?> lastPulledAt;
  final Value<int?> lastPushedAt;
  final Value<String?> lastError;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TmdbAccountSyncItemsTableCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.tmdbMediaType = const Value.absent(),
    this.barcode = const Value.absent(),
    this.titleSnapshot = const Value.absent(),
    this.posterPathSnapshot = const Value.absent(),
    this.tmdbRating = const Value.absent(),
    this.localRatingSnapshot = const Value.absent(),
    this.watchlist = const Value.absent(),
    this.favorite = const Value.absent(),
    this.listIdsJson = const Value.absent(),
    this.accountStateJson = const Value.absent(),
    this.localDirty = const Value.absent(),
    this.remoteDirty = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TmdbAccountSyncItemsTableCompanion.insert({
    required String id,
    this.mediaItemId = const Value.absent(),
    required int tmdbId,
    required String tmdbMediaType,
    this.barcode = const Value.absent(),
    this.titleSnapshot = const Value.absent(),
    this.posterPathSnapshot = const Value.absent(),
    this.tmdbRating = const Value.absent(),
    this.localRatingSnapshot = const Value.absent(),
    this.watchlist = const Value.absent(),
    this.favorite = const Value.absent(),
    this.listIdsJson = const Value.absent(),
    this.accountStateJson = const Value.absent(),
    this.localDirty = const Value.absent(),
    this.remoteDirty = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tmdbId = Value(tmdbId),
       tmdbMediaType = Value(tmdbMediaType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TmdbAccountSyncItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<int>? tmdbId,
    Expression<String>? tmdbMediaType,
    Expression<String>? barcode,
    Expression<String>? titleSnapshot,
    Expression<String>? posterPathSnapshot,
    Expression<double>? tmdbRating,
    Expression<double>? localRatingSnapshot,
    Expression<int>? watchlist,
    Expression<int>? favorite,
    Expression<String>? listIdsJson,
    Expression<String>? accountStateJson,
    Expression<int>? localDirty,
    Expression<int>? remoteDirty,
    Expression<int>? lastPulledAt,
    Expression<int>? lastPushedAt,
    Expression<String>? lastError,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (tmdbMediaType != null) 'tmdb_media_type': tmdbMediaType,
      if (barcode != null) 'barcode': barcode,
      if (titleSnapshot != null) 'title_snapshot': titleSnapshot,
      if (posterPathSnapshot != null)
        'poster_path_snapshot': posterPathSnapshot,
      if (tmdbRating != null) 'tmdb_rating': tmdbRating,
      if (localRatingSnapshot != null)
        'local_rating_snapshot': localRatingSnapshot,
      if (watchlist != null) 'watchlist': watchlist,
      if (favorite != null) 'favorite': favorite,
      if (listIdsJson != null) 'list_ids_json': listIdsJson,
      if (accountStateJson != null) 'account_state_json': accountStateJson,
      if (localDirty != null) 'local_dirty': localDirty,
      if (remoteDirty != null) 'remote_dirty': remoteDirty,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (lastPushedAt != null) 'last_pushed_at': lastPushedAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TmdbAccountSyncItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? mediaItemId,
    Value<int>? tmdbId,
    Value<String>? tmdbMediaType,
    Value<String?>? barcode,
    Value<String?>? titleSnapshot,
    Value<String?>? posterPathSnapshot,
    Value<double?>? tmdbRating,
    Value<double?>? localRatingSnapshot,
    Value<int>? watchlist,
    Value<int>? favorite,
    Value<String>? listIdsJson,
    Value<String>? accountStateJson,
    Value<int>? localDirty,
    Value<int>? remoteDirty,
    Value<int?>? lastPulledAt,
    Value<int?>? lastPushedAt,
    Value<String?>? lastError,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TmdbAccountSyncItemsTableCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      tmdbId: tmdbId ?? this.tmdbId,
      tmdbMediaType: tmdbMediaType ?? this.tmdbMediaType,
      barcode: barcode ?? this.barcode,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      posterPathSnapshot: posterPathSnapshot ?? this.posterPathSnapshot,
      tmdbRating: tmdbRating ?? this.tmdbRating,
      localRatingSnapshot: localRatingSnapshot ?? this.localRatingSnapshot,
      watchlist: watchlist ?? this.watchlist,
      favorite: favorite ?? this.favorite,
      listIdsJson: listIdsJson ?? this.listIdsJson,
      accountStateJson: accountStateJson ?? this.accountStateJson,
      localDirty: localDirty ?? this.localDirty,
      remoteDirty: remoteDirty ?? this.remoteDirty,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      lastPushedAt: lastPushedAt ?? this.lastPushedAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (tmdbMediaType.present) {
      map['tmdb_media_type'] = Variable<String>(tmdbMediaType.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (titleSnapshot.present) {
      map['title_snapshot'] = Variable<String>(titleSnapshot.value);
    }
    if (posterPathSnapshot.present) {
      map['poster_path_snapshot'] = Variable<String>(posterPathSnapshot.value);
    }
    if (tmdbRating.present) {
      map['tmdb_rating'] = Variable<double>(tmdbRating.value);
    }
    if (localRatingSnapshot.present) {
      map['local_rating_snapshot'] = Variable<double>(
        localRatingSnapshot.value,
      );
    }
    if (watchlist.present) {
      map['watchlist'] = Variable<int>(watchlist.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<int>(favorite.value);
    }
    if (listIdsJson.present) {
      map['list_ids_json'] = Variable<String>(listIdsJson.value);
    }
    if (accountStateJson.present) {
      map['account_state_json'] = Variable<String>(accountStateJson.value);
    }
    if (localDirty.present) {
      map['local_dirty'] = Variable<int>(localDirty.value);
    }
    if (remoteDirty.present) {
      map['remote_dirty'] = Variable<int>(remoteDirty.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt.value);
    }
    if (lastPushedAt.present) {
      map['last_pushed_at'] = Variable<int>(lastPushedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TmdbAccountSyncItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('tmdbMediaType: $tmdbMediaType, ')
          ..write('barcode: $barcode, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('posterPathSnapshot: $posterPathSnapshot, ')
          ..write('tmdbRating: $tmdbRating, ')
          ..write('localRatingSnapshot: $localRatingSnapshot, ')
          ..write('watchlist: $watchlist, ')
          ..write('favorite: $favorite, ')
          ..write('listIdsJson: $listIdsJson, ')
          ..write('accountStateJson: $accountStateJson, ')
          ..write('localDirty: $localDirty, ')
          ..write('remoteDirty: $remoteDirty, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $RipAlbumsTableTable ripAlbumsTable = $RipAlbumsTableTable(this);
  late final $RipTracksTableTable ripTracksTable = $RipTracksTableTable(this);
  late final $BatchSessionsTableTable batchSessionsTable =
      $BatchSessionsTableTable(this);
  late final $BatchQueueItemsTableTable batchQueueItemsTable =
      $BatchQueueItemsTableTable(this);
  late final $PlaylistsTableTable playlistsTable = $PlaylistsTableTable(this);
  late final $PlaylistTracksTableTable playlistTracksTable =
      $PlaylistTracksTableTable(this);
  late final $LocationsTableTable locationsTable = $LocationsTableTable(this);
  late final $SeriesTableTable seriesTable = $SeriesTableTable(this);
  late final $TmdbAccountSyncItemsTableTable tmdbAccountSyncItemsTable =
      $TmdbAccountSyncItemsTableTable(this);
  late final MediaItemsDao mediaItemsDao = MediaItemsDao(this as AppDatabase);
  late final TagsDao tagsDao = TagsDao(this as AppDatabase);
  late final ShelvesDao shelvesDao = ShelvesDao(this as AppDatabase);
  late final BarcodeCacheDao barcodeCacheDao = BarcodeCacheDao(
    this as AppDatabase,
  );
  late final SyncLogDao syncLogDao = SyncLogDao(this as AppDatabase);
  late final BorrowersDao borrowersDao = BorrowersDao(this as AppDatabase);
  late final LoansDao loansDao = LoansDao(this as AppDatabase);
  late final RipLibraryDao ripLibraryDao = RipLibraryDao(this as AppDatabase);
  late final BatchSessionDao batchSessionDao = BatchSessionDao(
    this as AppDatabase,
  );
  late final PlaylistDao playlistDao = PlaylistDao(this as AppDatabase);
  late final LocationsDao locationsDao = LocationsDao(this as AppDatabase);
  late final SeriesDao seriesDao = SeriesDao(this as AppDatabase);
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
    ripAlbumsTable,
    ripTracksTable,
    batchSessionsTable,
    batchQueueItemsTable,
    playlistsTable,
    playlistTracksTable,
    locationsTable,
    seriesTable,
    tmdbAccountSyncItemsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_tracks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rip_tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_tracks', kind: UpdateKind.delete)],
    ),
  ]);
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
      Value<String> ownershipStatus,
      Value<String?> condition,
      Value<double?> pricePaid,
      Value<int?> acquiredAt,
      Value<String?> retailer,
      Value<String?> locationId,
      Value<String?> seriesId,
      Value<int?> seriesPosition,
      Value<int?> progressCurrent,
      Value<int?> progressTotal,
      Value<String?> progressUnit,
      Value<int?> startedAt,
      Value<int?> completedAt,
      Value<int> consumed,
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
      Value<String> ownershipStatus,
      Value<String?> condition,
      Value<double?> pricePaid,
      Value<int?> acquiredAt,
      Value<String?> retailer,
      Value<String?> locationId,
      Value<String?> seriesId,
      Value<int?> seriesPosition,
      Value<int?> progressCurrent,
      Value<int?> progressTotal,
      Value<String?> progressUnit,
      Value<int?> startedAt,
      Value<int?> completedAt,
      Value<int> consumed,
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

  static MultiTypedResultKey<$RipAlbumsTableTable, List<RipAlbumsTableData>>
  _ripAlbumsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ripAlbumsTable,
    aliasName: $_aliasNameGenerator(
      db.mediaItemsTable.id,
      db.ripAlbumsTable.mediaItemId,
    ),
  );

  $$RipAlbumsTableTableProcessedTableManager get ripAlbumsTableRefs {
    final manager = $$RipAlbumsTableTableTableManager(
      $_db,
      $_db.ripAlbumsTable,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ripAlbumsTableRefsTable($_db));
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

  ColumnFilters<String> get ownershipStatus => $composableBuilder(
    column: $table.ownershipStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePaid => $composableBuilder(
    column: $table.pricePaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retailer => $composableBuilder(
    column: $table.retailer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesPosition => $composableBuilder(
    column: $table.seriesPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressTotal => $composableBuilder(
    column: $table.progressTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get progressUnit => $composableBuilder(
    column: $table.progressUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consumed => $composableBuilder(
    column: $table.consumed,
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

  Expression<bool> ripAlbumsTableRefs(
    Expression<bool> Function($$RipAlbumsTableTableFilterComposer f) f,
  ) {
    final $$RipAlbumsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ripAlbumsTable,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipAlbumsTableTableFilterComposer(
            $db: $db,
            $table: $db.ripAlbumsTable,
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

  ColumnOrderings<String> get ownershipStatus => $composableBuilder(
    column: $table.ownershipStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePaid => $composableBuilder(
    column: $table.pricePaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retailer => $composableBuilder(
    column: $table.retailer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesPosition => $composableBuilder(
    column: $table.seriesPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressTotal => $composableBuilder(
    column: $table.progressTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progressUnit => $composableBuilder(
    column: $table.progressUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consumed => $composableBuilder(
    column: $table.consumed,
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

  GeneratedColumn<String> get ownershipStatus => $composableBuilder(
    column: $table.ownershipStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<double> get pricePaid =>
      $composableBuilder(column: $table.pricePaid, builder: (column) => column);

  GeneratedColumn<int> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retailer =>
      $composableBuilder(column: $table.retailer, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get seriesPosition => $composableBuilder(
    column: $table.seriesPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressCurrent => $composableBuilder(
    column: $table.progressCurrent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressTotal => $composableBuilder(
    column: $table.progressTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get progressUnit => $composableBuilder(
    column: $table.progressUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consumed =>
      $composableBuilder(column: $table.consumed, builder: (column) => column);

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

  Expression<T> ripAlbumsTableRefs<T extends Object>(
    Expression<T> Function($$RipAlbumsTableTableAnnotationComposer a) f,
  ) {
    final $$RipAlbumsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ripAlbumsTable,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipAlbumsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.ripAlbumsTable,
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
            bool ripAlbumsTableRefs,
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
                Value<String> ownershipStatus = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<double?> pricePaid = const Value.absent(),
                Value<int?> acquiredAt = const Value.absent(),
                Value<String?> retailer = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<int?> seriesPosition = const Value.absent(),
                Value<int?> progressCurrent = const Value.absent(),
                Value<int?> progressTotal = const Value.absent(),
                Value<String?> progressUnit = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> consumed = const Value.absent(),
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
                ownershipStatus: ownershipStatus,
                condition: condition,
                pricePaid: pricePaid,
                acquiredAt: acquiredAt,
                retailer: retailer,
                locationId: locationId,
                seriesId: seriesId,
                seriesPosition: seriesPosition,
                progressCurrent: progressCurrent,
                progressTotal: progressTotal,
                progressUnit: progressUnit,
                startedAt: startedAt,
                completedAt: completedAt,
                consumed: consumed,
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
                Value<String> ownershipStatus = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<double?> pricePaid = const Value.absent(),
                Value<int?> acquiredAt = const Value.absent(),
                Value<String?> retailer = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<int?> seriesPosition = const Value.absent(),
                Value<int?> progressCurrent = const Value.absent(),
                Value<int?> progressTotal = const Value.absent(),
                Value<String?> progressUnit = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> consumed = const Value.absent(),
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
                ownershipStatus: ownershipStatus,
                condition: condition,
                pricePaid: pricePaid,
                acquiredAt: acquiredAt,
                retailer: retailer,
                locationId: locationId,
                seriesId: seriesId,
                seriesPosition: seriesPosition,
                progressCurrent: progressCurrent,
                progressTotal: progressTotal,
                progressUnit: progressUnit,
                startedAt: startedAt,
                completedAt: completedAt,
                consumed: consumed,
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
                ripAlbumsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mediaItemTagsTableRefs) db.mediaItemTagsTable,
                    if (shelfItemsTableRefs) db.shelfItemsTable,
                    if (loansTableRefs) db.loansTable,
                    if (ripAlbumsTableRefs) db.ripAlbumsTable,
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
                      if (ripAlbumsTableRefs)
                        await $_getPrefetchedData<
                          MediaItemsTableData,
                          $MediaItemsTableTable,
                          RipAlbumsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableTableReferences
                              ._ripAlbumsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).ripAlbumsTableRefs,
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
        bool ripAlbumsTableRefs,
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
      Value<String?> errorMessage,
      Value<int?> durationMs,
      Value<String?> direction,
      Value<String?> resolvedBy,
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
      Value<String?> errorMessage,
      Value<int?> durationMs,
      Value<String?> direction,
      Value<String?> resolvedBy,
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

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
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

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
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

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
    builder: (column) => column,
  );
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
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> direction = const Value.absent(),
                Value<String?> resolvedBy = const Value.absent(),
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
                errorMessage: errorMessage,
                durationMs: durationMs,
                direction: direction,
                resolvedBy: resolvedBy,
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
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> direction = const Value.absent(),
                Value<String?> resolvedBy = const Value.absent(),
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
                errorMessage: errorMessage,
                durationMs: durationMs,
                direction: direction,
                resolvedBy: resolvedBy,
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
      Value<int?> dueAt,
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
      Value<int?> dueAt,
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

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
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

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
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

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

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
                Value<int?> dueAt = const Value.absent(),
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
                dueAt: dueAt,
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
                Value<int?> dueAt = const Value.absent(),
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
                dueAt: dueAt,
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
typedef $$RipAlbumsTableTableCreateCompanionBuilder =
    RipAlbumsTableCompanion Function({
      required String id,
      required String libraryPath,
      Value<String?> artist,
      Value<String?> albumTitle,
      Value<String?> barcode,
      required int trackCount,
      Value<int> discCount,
      required int totalSizeBytes,
      Value<String?> mediaItemId,
      required int lastScannedAt,
      required int updatedAt,
      Value<String?> cueFilePath,
      Value<String?> gnudbDiscId,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$RipAlbumsTableTableUpdateCompanionBuilder =
    RipAlbumsTableCompanion Function({
      Value<String> id,
      Value<String> libraryPath,
      Value<String?> artist,
      Value<String?> albumTitle,
      Value<String?> barcode,
      Value<int> trackCount,
      Value<int> discCount,
      Value<int> totalSizeBytes,
      Value<String?> mediaItemId,
      Value<int> lastScannedAt,
      Value<int> updatedAt,
      Value<String?> cueFilePath,
      Value<String?> gnudbDiscId,
      Value<int> deleted,
      Value<int> rowid,
    });

final class $$RipAlbumsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RipAlbumsTableTable,
          RipAlbumsTableData
        > {
  $$RipAlbumsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaItemsTableTable _mediaItemIdTable(_$AppDatabase db) =>
      db.mediaItemsTable.createAlias(
        $_aliasNameGenerator(
          db.ripAlbumsTable.mediaItemId,
          db.mediaItemsTable.id,
        ),
      );

  $$MediaItemsTableTableProcessedTableManager? get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id');
    if ($_column == null) return null;
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

  static MultiTypedResultKey<$RipTracksTableTable, List<RipTracksTableData>>
  _ripTracksTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ripTracksTable,
    aliasName: $_aliasNameGenerator(
      db.ripAlbumsTable.id,
      db.ripTracksTable.ripAlbumId,
    ),
  );

  $$RipTracksTableTableProcessedTableManager get ripTracksTableRefs {
    final manager = $$RipTracksTableTableTableManager(
      $_db,
      $_db.ripTracksTable,
    ).filter((f) => f.ripAlbumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ripTracksTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RipAlbumsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RipAlbumsTableTable> {
  $$RipAlbumsTableTableFilterComposer({
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

  ColumnFilters<String> get libraryPath => $composableBuilder(
    column: $table.libraryPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discCount => $composableBuilder(
    column: $table.discCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSizeBytes => $composableBuilder(
    column: $table.totalSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cueFilePath => $composableBuilder(
    column: $table.cueFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gnudbDiscId => $composableBuilder(
    column: $table.gnudbDiscId,
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

  Expression<bool> ripTracksTableRefs(
    Expression<bool> Function($$RipTracksTableTableFilterComposer f) f,
  ) {
    final $$RipTracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ripTracksTable,
      getReferencedColumn: (t) => t.ripAlbumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipTracksTableTableFilterComposer(
            $db: $db,
            $table: $db.ripTracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RipAlbumsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RipAlbumsTableTable> {
  $$RipAlbumsTableTableOrderingComposer({
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

  ColumnOrderings<String> get libraryPath => $composableBuilder(
    column: $table.libraryPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discCount => $composableBuilder(
    column: $table.discCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSizeBytes => $composableBuilder(
    column: $table.totalSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cueFilePath => $composableBuilder(
    column: $table.cueFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gnudbDiscId => $composableBuilder(
    column: $table.gnudbDiscId,
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
}

class $$RipAlbumsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RipAlbumsTableTable> {
  $$RipAlbumsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get libraryPath => $composableBuilder(
    column: $table.libraryPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discCount =>
      $composableBuilder(column: $table.discCount, builder: (column) => column);

  GeneratedColumn<int> get totalSizeBytes => $composableBuilder(
    column: $table.totalSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get cueFilePath => $composableBuilder(
    column: $table.cueFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gnudbDiscId => $composableBuilder(
    column: $table.gnudbDiscId,
    builder: (column) => column,
  );

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

  Expression<T> ripTracksTableRefs<T extends Object>(
    Expression<T> Function($$RipTracksTableTableAnnotationComposer a) f,
  ) {
    final $$RipTracksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ripTracksTable,
      getReferencedColumn: (t) => t.ripAlbumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipTracksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.ripTracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RipAlbumsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RipAlbumsTableTable,
          RipAlbumsTableData,
          $$RipAlbumsTableTableFilterComposer,
          $$RipAlbumsTableTableOrderingComposer,
          $$RipAlbumsTableTableAnnotationComposer,
          $$RipAlbumsTableTableCreateCompanionBuilder,
          $$RipAlbumsTableTableUpdateCompanionBuilder,
          (RipAlbumsTableData, $$RipAlbumsTableTableReferences),
          RipAlbumsTableData,
          PrefetchHooks Function({bool mediaItemId, bool ripTracksTableRefs})
        > {
  $$RipAlbumsTableTableTableManager(
    _$AppDatabase db,
    $RipAlbumsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RipAlbumsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RipAlbumsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RipAlbumsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> libraryPath = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> albumTitle = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<int> trackCount = const Value.absent(),
                Value<int> discCount = const Value.absent(),
                Value<int> totalSizeBytes = const Value.absent(),
                Value<String?> mediaItemId = const Value.absent(),
                Value<int> lastScannedAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> cueFilePath = const Value.absent(),
                Value<String?> gnudbDiscId = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RipAlbumsTableCompanion(
                id: id,
                libraryPath: libraryPath,
                artist: artist,
                albumTitle: albumTitle,
                barcode: barcode,
                trackCount: trackCount,
                discCount: discCount,
                totalSizeBytes: totalSizeBytes,
                mediaItemId: mediaItemId,
                lastScannedAt: lastScannedAt,
                updatedAt: updatedAt,
                cueFilePath: cueFilePath,
                gnudbDiscId: gnudbDiscId,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String libraryPath,
                Value<String?> artist = const Value.absent(),
                Value<String?> albumTitle = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required int trackCount,
                Value<int> discCount = const Value.absent(),
                required int totalSizeBytes,
                Value<String?> mediaItemId = const Value.absent(),
                required int lastScannedAt,
                required int updatedAt,
                Value<String?> cueFilePath = const Value.absent(),
                Value<String?> gnudbDiscId = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RipAlbumsTableCompanion.insert(
                id: id,
                libraryPath: libraryPath,
                artist: artist,
                albumTitle: albumTitle,
                barcode: barcode,
                trackCount: trackCount,
                discCount: discCount,
                totalSizeBytes: totalSizeBytes,
                mediaItemId: mediaItemId,
                lastScannedAt: lastScannedAt,
                updatedAt: updatedAt,
                cueFilePath: cueFilePath,
                gnudbDiscId: gnudbDiscId,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RipAlbumsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mediaItemId = false, ripTracksTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ripTracksTableRefs) db.ripTracksTable,
                  ],
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
                                        $$RipAlbumsTableTableReferences
                                            ._mediaItemIdTable(db),
                                    referencedColumn:
                                        $$RipAlbumsTableTableReferences
                                            ._mediaItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ripTracksTableRefs)
                        await $_getPrefetchedData<
                          RipAlbumsTableData,
                          $RipAlbumsTableTable,
                          RipTracksTableData
                        >(
                          currentTable: table,
                          referencedTable: $$RipAlbumsTableTableReferences
                              ._ripTracksTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RipAlbumsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).ripTracksTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ripAlbumId == item.id,
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

typedef $$RipAlbumsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RipAlbumsTableTable,
      RipAlbumsTableData,
      $$RipAlbumsTableTableFilterComposer,
      $$RipAlbumsTableTableOrderingComposer,
      $$RipAlbumsTableTableAnnotationComposer,
      $$RipAlbumsTableTableCreateCompanionBuilder,
      $$RipAlbumsTableTableUpdateCompanionBuilder,
      (RipAlbumsTableData, $$RipAlbumsTableTableReferences),
      RipAlbumsTableData,
      PrefetchHooks Function({bool mediaItemId, bool ripTracksTableRefs})
    >;
typedef $$RipTracksTableTableCreateCompanionBuilder =
    RipTracksTableCompanion Function({
      required String id,
      required String ripAlbumId,
      Value<int> discNumber,
      required int trackNumber,
      Value<String?> title,
      required String filePath,
      Value<int?> durationMs,
      required int fileSizeBytes,
      required int updatedAt,
      Value<String?> accurateripStatus,
      Value<int?> accurateripConfidence,
      Value<String?> accurateripCrcV1,
      Value<String?> accurateripCrcV2,
      Value<double?> peakLevel,
      Value<double?> trackQuality,
      Value<String?> copyCrc,
      Value<int?> clickCount,
      Value<String?> ripLogSource,
      Value<int?> qualityCheckedAt,
      Value<int> rowid,
    });
typedef $$RipTracksTableTableUpdateCompanionBuilder =
    RipTracksTableCompanion Function({
      Value<String> id,
      Value<String> ripAlbumId,
      Value<int> discNumber,
      Value<int> trackNumber,
      Value<String?> title,
      Value<String> filePath,
      Value<int?> durationMs,
      Value<int> fileSizeBytes,
      Value<int> updatedAt,
      Value<String?> accurateripStatus,
      Value<int?> accurateripConfidence,
      Value<String?> accurateripCrcV1,
      Value<String?> accurateripCrcV2,
      Value<double?> peakLevel,
      Value<double?> trackQuality,
      Value<String?> copyCrc,
      Value<int?> clickCount,
      Value<String?> ripLogSource,
      Value<int?> qualityCheckedAt,
      Value<int> rowid,
    });

final class $$RipTracksTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RipTracksTableTable,
          RipTracksTableData
        > {
  $$RipTracksTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RipAlbumsTableTable _ripAlbumIdTable(_$AppDatabase db) =>
      db.ripAlbumsTable.createAlias(
        $_aliasNameGenerator(
          db.ripTracksTable.ripAlbumId,
          db.ripAlbumsTable.id,
        ),
      );

  $$RipAlbumsTableTableProcessedTableManager get ripAlbumId {
    final $_column = $_itemColumn<String>('rip_album_id')!;

    final manager = $$RipAlbumsTableTableTableManager(
      $_db,
      $_db.ripAlbumsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ripAlbumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PlaylistTracksTableTable,
    List<PlaylistTracksTableData>
  >
  _playlistTracksTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTracksTable,
        aliasName: $_aliasNameGenerator(
          db.ripTracksTable.id,
          db.playlistTracksTable.ripTrackId,
        ),
      );

  $$PlaylistTracksTableTableProcessedTableManager get playlistTracksTableRefs {
    final manager = $$PlaylistTracksTableTableTableManager(
      $_db,
      $_db.playlistTracksTable,
    ).filter((f) => f.ripTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTracksTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RipTracksTableTableFilterComposer
    extends Composer<_$AppDatabase, $RipTracksTableTable> {
  $$RipTracksTableTableFilterComposer({
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

  ColumnFilters<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accurateripStatus => $composableBuilder(
    column: $table.accurateripStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accurateripConfidence => $composableBuilder(
    column: $table.accurateripConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accurateripCrcV1 => $composableBuilder(
    column: $table.accurateripCrcV1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accurateripCrcV2 => $composableBuilder(
    column: $table.accurateripCrcV2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakLevel => $composableBuilder(
    column: $table.peakLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get trackQuality => $composableBuilder(
    column: $table.trackQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get copyCrc => $composableBuilder(
    column: $table.copyCrc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clickCount => $composableBuilder(
    column: $table.clickCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ripLogSource => $composableBuilder(
    column: $table.ripLogSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qualityCheckedAt => $composableBuilder(
    column: $table.qualityCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RipAlbumsTableTableFilterComposer get ripAlbumId {
    final $$RipAlbumsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ripAlbumId,
      referencedTable: $db.ripAlbumsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipAlbumsTableTableFilterComposer(
            $db: $db,
            $table: $db.ripAlbumsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playlistTracksTableRefs(
    Expression<bool> Function($$PlaylistTracksTableTableFilterComposer f) f,
  ) {
    final $$PlaylistTracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracksTable,
      getReferencedColumn: (t) => t.ripTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RipTracksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RipTracksTableTable> {
  $$RipTracksTableTableOrderingComposer({
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

  ColumnOrderings<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accurateripStatus => $composableBuilder(
    column: $table.accurateripStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accurateripConfidence => $composableBuilder(
    column: $table.accurateripConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accurateripCrcV1 => $composableBuilder(
    column: $table.accurateripCrcV1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accurateripCrcV2 => $composableBuilder(
    column: $table.accurateripCrcV2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakLevel => $composableBuilder(
    column: $table.peakLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get trackQuality => $composableBuilder(
    column: $table.trackQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get copyCrc => $composableBuilder(
    column: $table.copyCrc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clickCount => $composableBuilder(
    column: $table.clickCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ripLogSource => $composableBuilder(
    column: $table.ripLogSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qualityCheckedAt => $composableBuilder(
    column: $table.qualityCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RipAlbumsTableTableOrderingComposer get ripAlbumId {
    final $$RipAlbumsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ripAlbumId,
      referencedTable: $db.ripAlbumsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipAlbumsTableTableOrderingComposer(
            $db: $db,
            $table: $db.ripAlbumsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RipTracksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RipTracksTableTable> {
  $$RipTracksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get accurateripStatus => $composableBuilder(
    column: $table.accurateripStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accurateripConfidence => $composableBuilder(
    column: $table.accurateripConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accurateripCrcV1 => $composableBuilder(
    column: $table.accurateripCrcV1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accurateripCrcV2 => $composableBuilder(
    column: $table.accurateripCrcV2,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakLevel =>
      $composableBuilder(column: $table.peakLevel, builder: (column) => column);

  GeneratedColumn<double> get trackQuality => $composableBuilder(
    column: $table.trackQuality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get copyCrc =>
      $composableBuilder(column: $table.copyCrc, builder: (column) => column);

  GeneratedColumn<int> get clickCount => $composableBuilder(
    column: $table.clickCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ripLogSource => $composableBuilder(
    column: $table.ripLogSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qualityCheckedAt => $composableBuilder(
    column: $table.qualityCheckedAt,
    builder: (column) => column,
  );

  $$RipAlbumsTableTableAnnotationComposer get ripAlbumId {
    final $$RipAlbumsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ripAlbumId,
      referencedTable: $db.ripAlbumsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipAlbumsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.ripAlbumsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playlistTracksTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistTracksTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTracksTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTracksTable,
          getReferencedColumn: (t) => t.ripTrackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTracksTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTracksTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RipTracksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RipTracksTableTable,
          RipTracksTableData,
          $$RipTracksTableTableFilterComposer,
          $$RipTracksTableTableOrderingComposer,
          $$RipTracksTableTableAnnotationComposer,
          $$RipTracksTableTableCreateCompanionBuilder,
          $$RipTracksTableTableUpdateCompanionBuilder,
          (RipTracksTableData, $$RipTracksTableTableReferences),
          RipTracksTableData,
          PrefetchHooks Function({
            bool ripAlbumId,
            bool playlistTracksTableRefs,
          })
        > {
  $$RipTracksTableTableTableManager(
    _$AppDatabase db,
    $RipTracksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RipTracksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RipTracksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RipTracksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ripAlbumId = const Value.absent(),
                Value<int> discNumber = const Value.absent(),
                Value<int> trackNumber = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> accurateripStatus = const Value.absent(),
                Value<int?> accurateripConfidence = const Value.absent(),
                Value<String?> accurateripCrcV1 = const Value.absent(),
                Value<String?> accurateripCrcV2 = const Value.absent(),
                Value<double?> peakLevel = const Value.absent(),
                Value<double?> trackQuality = const Value.absent(),
                Value<String?> copyCrc = const Value.absent(),
                Value<int?> clickCount = const Value.absent(),
                Value<String?> ripLogSource = const Value.absent(),
                Value<int?> qualityCheckedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RipTracksTableCompanion(
                id: id,
                ripAlbumId: ripAlbumId,
                discNumber: discNumber,
                trackNumber: trackNumber,
                title: title,
                filePath: filePath,
                durationMs: durationMs,
                fileSizeBytes: fileSizeBytes,
                updatedAt: updatedAt,
                accurateripStatus: accurateripStatus,
                accurateripConfidence: accurateripConfidence,
                accurateripCrcV1: accurateripCrcV1,
                accurateripCrcV2: accurateripCrcV2,
                peakLevel: peakLevel,
                trackQuality: trackQuality,
                copyCrc: copyCrc,
                clickCount: clickCount,
                ripLogSource: ripLogSource,
                qualityCheckedAt: qualityCheckedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ripAlbumId,
                Value<int> discNumber = const Value.absent(),
                required int trackNumber,
                Value<String?> title = const Value.absent(),
                required String filePath,
                Value<int?> durationMs = const Value.absent(),
                required int fileSizeBytes,
                required int updatedAt,
                Value<String?> accurateripStatus = const Value.absent(),
                Value<int?> accurateripConfidence = const Value.absent(),
                Value<String?> accurateripCrcV1 = const Value.absent(),
                Value<String?> accurateripCrcV2 = const Value.absent(),
                Value<double?> peakLevel = const Value.absent(),
                Value<double?> trackQuality = const Value.absent(),
                Value<String?> copyCrc = const Value.absent(),
                Value<int?> clickCount = const Value.absent(),
                Value<String?> ripLogSource = const Value.absent(),
                Value<int?> qualityCheckedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RipTracksTableCompanion.insert(
                id: id,
                ripAlbumId: ripAlbumId,
                discNumber: discNumber,
                trackNumber: trackNumber,
                title: title,
                filePath: filePath,
                durationMs: durationMs,
                fileSizeBytes: fileSizeBytes,
                updatedAt: updatedAt,
                accurateripStatus: accurateripStatus,
                accurateripConfidence: accurateripConfidence,
                accurateripCrcV1: accurateripCrcV1,
                accurateripCrcV2: accurateripCrcV2,
                peakLevel: peakLevel,
                trackQuality: trackQuality,
                copyCrc: copyCrc,
                clickCount: clickCount,
                ripLogSource: ripLogSource,
                qualityCheckedAt: qualityCheckedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RipTracksTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ripAlbumId = false, playlistTracksTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistTracksTableRefs) db.playlistTracksTable,
                  ],
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
                        if (ripAlbumId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ripAlbumId,
                                    referencedTable:
                                        $$RipTracksTableTableReferences
                                            ._ripAlbumIdTable(db),
                                    referencedColumn:
                                        $$RipTracksTableTableReferences
                                            ._ripAlbumIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistTracksTableRefs)
                        await $_getPrefetchedData<
                          RipTracksTableData,
                          $RipTracksTableTable,
                          PlaylistTracksTableData
                        >(
                          currentTable: table,
                          referencedTable: $$RipTracksTableTableReferences
                              ._playlistTracksTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RipTracksTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistTracksTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ripTrackId == item.id,
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

typedef $$RipTracksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RipTracksTableTable,
      RipTracksTableData,
      $$RipTracksTableTableFilterComposer,
      $$RipTracksTableTableOrderingComposer,
      $$RipTracksTableTableAnnotationComposer,
      $$RipTracksTableTableCreateCompanionBuilder,
      $$RipTracksTableTableUpdateCompanionBuilder,
      (RipTracksTableData, $$RipTracksTableTableReferences),
      RipTracksTableData,
      PrefetchHooks Function({bool ripAlbumId, bool playlistTracksTableRefs})
    >;
typedef $$BatchSessionsTableTableCreateCompanionBuilder =
    BatchSessionsTableCompanion Function({
      required String id,
      required int createdAt,
      Value<int?> completedAt,
      Value<String> status,
      Value<int> itemCount,
      Value<int> rowid,
    });
typedef $$BatchSessionsTableTableUpdateCompanionBuilder =
    BatchSessionsTableCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int?> completedAt,
      Value<String> status,
      Value<int> itemCount,
      Value<int> rowid,
    });

class $$BatchSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BatchSessionsTableTable> {
  $$BatchSessionsTableTableFilterComposer({
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

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchSessionsTableTable> {
  $$BatchSessionsTableTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchSessionsTableTable> {
  $$BatchSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);
}

class $$BatchSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchSessionsTableTable,
          BatchSessionsTableData,
          $$BatchSessionsTableTableFilterComposer,
          $$BatchSessionsTableTableOrderingComposer,
          $$BatchSessionsTableTableAnnotationComposer,
          $$BatchSessionsTableTableCreateCompanionBuilder,
          $$BatchSessionsTableTableUpdateCompanionBuilder,
          (
            BatchSessionsTableData,
            BaseReferences<
              _$AppDatabase,
              $BatchSessionsTableTable,
              BatchSessionsTableData
            >,
          ),
          BatchSessionsTableData,
          PrefetchHooks Function()
        > {
  $$BatchSessionsTableTableTableManager(
    _$AppDatabase db,
    $BatchSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchSessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchSessionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchSessionsTableCompanion(
                id: id,
                createdAt: createdAt,
                completedAt: completedAt,
                status: status,
                itemCount: itemCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                Value<int?> completedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchSessionsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                completedAt: completedAt,
                status: status,
                itemCount: itemCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchSessionsTableTable,
      BatchSessionsTableData,
      $$BatchSessionsTableTableFilterComposer,
      $$BatchSessionsTableTableOrderingComposer,
      $$BatchSessionsTableTableAnnotationComposer,
      $$BatchSessionsTableTableCreateCompanionBuilder,
      $$BatchSessionsTableTableUpdateCompanionBuilder,
      (
        BatchSessionsTableData,
        BaseReferences<
          _$AppDatabase,
          $BatchSessionsTableTable,
          BatchSessionsTableData
        >,
      ),
      BatchSessionsTableData,
      PrefetchHooks Function()
    >;
typedef $$BatchQueueItemsTableTableCreateCompanionBuilder =
    BatchQueueItemsTableCompanion Function({
      required String id,
      required String sessionId,
      required String barcode,
      required String barcodeType,
      required String status,
      required int scannedAt,
      Value<String?> metadataJson,
      Value<String?> scanResultJson,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$BatchQueueItemsTableTableUpdateCompanionBuilder =
    BatchQueueItemsTableCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> barcode,
      Value<String> barcodeType,
      Value<String> status,
      Value<int> scannedAt,
      Value<String?> metadataJson,
      Value<String?> scanResultJson,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$BatchQueueItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BatchQueueItemsTableTable> {
  $$BatchQueueItemsTableTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanResultJson => $composableBuilder(
    column: $table.scanResultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchQueueItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchQueueItemsTableTable> {
  $$BatchQueueItemsTableTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanResultJson => $composableBuilder(
    column: $table.scanResultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchQueueItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchQueueItemsTableTable> {
  $$BatchQueueItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get barcodeType => $composableBuilder(
    column: $table.barcodeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scanResultJson => $composableBuilder(
    column: $table.scanResultJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$BatchQueueItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchQueueItemsTableTable,
          BatchQueueItemsTableData,
          $$BatchQueueItemsTableTableFilterComposer,
          $$BatchQueueItemsTableTableOrderingComposer,
          $$BatchQueueItemsTableTableAnnotationComposer,
          $$BatchQueueItemsTableTableCreateCompanionBuilder,
          $$BatchQueueItemsTableTableUpdateCompanionBuilder,
          (
            BatchQueueItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $BatchQueueItemsTableTable,
              BatchQueueItemsTableData
            >,
          ),
          BatchQueueItemsTableData,
          PrefetchHooks Function()
        > {
  $$BatchQueueItemsTableTableTableManager(
    _$AppDatabase db,
    $BatchQueueItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchQueueItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchQueueItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BatchQueueItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> barcode = const Value.absent(),
                Value<String> barcodeType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> scannedAt = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<String?> scanResultJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchQueueItemsTableCompanion(
                id: id,
                sessionId: sessionId,
                barcode: barcode,
                barcodeType: barcodeType,
                status: status,
                scannedAt: scannedAt,
                metadataJson: metadataJson,
                scanResultJson: scanResultJson,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String barcode,
                required String barcodeType,
                required String status,
                required int scannedAt,
                Value<String?> metadataJson = const Value.absent(),
                Value<String?> scanResultJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchQueueItemsTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                barcode: barcode,
                barcodeType: barcodeType,
                status: status,
                scannedAt: scannedAt,
                metadataJson: metadataJson,
                scanResultJson: scanResultJson,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchQueueItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchQueueItemsTableTable,
      BatchQueueItemsTableData,
      $$BatchQueueItemsTableTableFilterComposer,
      $$BatchQueueItemsTableTableOrderingComposer,
      $$BatchQueueItemsTableTableAnnotationComposer,
      $$BatchQueueItemsTableTableCreateCompanionBuilder,
      $$BatchQueueItemsTableTableUpdateCompanionBuilder,
      (
        BatchQueueItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $BatchQueueItemsTableTable,
          BatchQueueItemsTableData
        >,
      ),
      BatchQueueItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableTableCreateCompanionBuilder =
    PlaylistsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> coverAlbumId,
      required int createdAt,
      required int updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$PlaylistsTableTableUpdateCompanionBuilder =
    PlaylistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> coverAlbumId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

final class $$PlaylistsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData
        > {
  $$PlaylistsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlaylistTracksTableTable,
    List<PlaylistTracksTableData>
  >
  _playlistTracksTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTracksTable,
        aliasName: $_aliasNameGenerator(
          db.playlistsTable.id,
          db.playlistTracksTable.playlistId,
        ),
      );

  $$PlaylistTracksTableTableProcessedTableManager get playlistTracksTableRefs {
    final manager = $$PlaylistTracksTableTableTableManager(
      $_db,
      $_db.playlistTracksTable,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTracksTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableFilterComposer({
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

  ColumnFilters<String> get coverAlbumId => $composableBuilder(
    column: $table.coverAlbumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  Expression<bool> playlistTracksTableRefs(
    Expression<bool> Function($$PlaylistTracksTableTableFilterComposer f) f,
  ) {
    final $$PlaylistTracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracksTable,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableOrderingComposer({
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

  ColumnOrderings<String> get coverAlbumId => $composableBuilder(
    column: $table.coverAlbumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$PlaylistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get coverAlbumId => $composableBuilder(
    column: $table.coverAlbumId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> playlistTracksTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistTracksTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTracksTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTracksTable,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTracksTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTracksTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaylistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData,
          $$PlaylistsTableTableFilterComposer,
          $$PlaylistsTableTableOrderingComposer,
          $$PlaylistsTableTableAnnotationComposer,
          $$PlaylistsTableTableCreateCompanionBuilder,
          $$PlaylistsTableTableUpdateCompanionBuilder,
          (PlaylistsTableData, $$PlaylistsTableTableReferences),
          PlaylistsTableData,
          PrefetchHooks Function({bool playlistTracksTableRefs})
        > {
  $$PlaylistsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverAlbumId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion(
                id: id,
                name: name,
                description: description,
                coverAlbumId: coverAlbumId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> coverAlbumId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                coverAlbumId: coverAlbumId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistTracksTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistTracksTableRefs) db.playlistTracksTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistTracksTableRefs)
                    await $_getPrefetchedData<
                      PlaylistsTableData,
                      $PlaylistsTableTable,
                      PlaylistTracksTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableTableReferences
                          ._playlistTracksTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistTracksTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTableTable,
      PlaylistsTableData,
      $$PlaylistsTableTableFilterComposer,
      $$PlaylistsTableTableOrderingComposer,
      $$PlaylistsTableTableAnnotationComposer,
      $$PlaylistsTableTableCreateCompanionBuilder,
      $$PlaylistsTableTableUpdateCompanionBuilder,
      (PlaylistsTableData, $$PlaylistsTableTableReferences),
      PlaylistsTableData,
      PrefetchHooks Function({bool playlistTracksTableRefs})
    >;
typedef $$PlaylistTracksTableTableCreateCompanionBuilder =
    PlaylistTracksTableCompanion Function({
      required String id,
      required String playlistId,
      required String ripTrackId,
      required int sortOrder,
      required int addedAt,
      Value<int> rowid,
    });
typedef $$PlaylistTracksTableTableUpdateCompanionBuilder =
    PlaylistTracksTableCompanion Function({
      Value<String> id,
      Value<String> playlistId,
      Value<String> ripTrackId,
      Value<int> sortOrder,
      Value<int> addedAt,
      Value<int> rowid,
    });

final class $$PlaylistTracksTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistTracksTableTable,
          PlaylistTracksTableData
        > {
  $$PlaylistTracksTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTableTable _playlistIdTable(_$AppDatabase db) =>
      db.playlistsTable.createAlias(
        $_aliasNameGenerator(
          db.playlistTracksTable.playlistId,
          db.playlistsTable.id,
        ),
      );

  $$PlaylistsTableTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableTableManager(
      $_db,
      $_db.playlistsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RipTracksTableTable _ripTrackIdTable(_$AppDatabase db) =>
      db.ripTracksTable.createAlias(
        $_aliasNameGenerator(
          db.playlistTracksTable.ripTrackId,
          db.ripTracksTable.id,
        ),
      );

  $$RipTracksTableTableProcessedTableManager get ripTrackId {
    final $_column = $_itemColumn<String>('rip_track_id')!;

    final manager = $$RipTracksTableTableTableManager(
      $_db,
      $_db.ripTracksTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ripTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistTracksTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableTableFilterComposer get playlistId {
    final $$PlaylistsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RipTracksTableTableFilterComposer get ripTrackId {
    final $$RipTracksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ripTrackId,
      referencedTable: $db.ripTracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipTracksTableTableFilterComposer(
            $db: $db,
            $table: $db.ripTracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableTableOrderingComposer get playlistId {
    final $$PlaylistsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableOrderingComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RipTracksTableTableOrderingComposer get ripTrackId {
    final $$RipTracksTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ripTrackId,
      referencedTable: $db.ripTracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipTracksTableTableOrderingComposer(
            $db: $db,
            $table: $db.ripTracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PlaylistsTableTableAnnotationComposer get playlistId {
    final $$PlaylistsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RipTracksTableTableAnnotationComposer get ripTrackId {
    final $$RipTracksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ripTrackId,
      referencedTable: $db.ripTracksTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RipTracksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.ripTracksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistTracksTableTable,
          PlaylistTracksTableData,
          $$PlaylistTracksTableTableFilterComposer,
          $$PlaylistTracksTableTableOrderingComposer,
          $$PlaylistTracksTableTableAnnotationComposer,
          $$PlaylistTracksTableTableCreateCompanionBuilder,
          $$PlaylistTracksTableTableUpdateCompanionBuilder,
          (PlaylistTracksTableData, $$PlaylistTracksTableTableReferences),
          PlaylistTracksTableData,
          PrefetchHooks Function({bool playlistId, bool ripTrackId})
        > {
  $$PlaylistTracksTableTableTableManager(
    _$AppDatabase db,
    $PlaylistTracksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTracksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTracksTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaylistTracksTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> playlistId = const Value.absent(),
                Value<String> ripTrackId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTracksTableCompanion(
                id: id,
                playlistId: playlistId,
                ripTrackId: ripTrackId,
                sortOrder: sortOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String playlistId,
                required String ripTrackId,
                required int sortOrder,
                required int addedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTracksTableCompanion.insert(
                id: id,
                playlistId: playlistId,
                ripTrackId: ripTrackId,
                sortOrder: sortOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTracksTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, ripTrackId = false}) {
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
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$PlaylistTracksTableTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$PlaylistTracksTableTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (ripTrackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ripTrackId,
                                referencedTable:
                                    $$PlaylistTracksTableTableReferences
                                        ._ripTrackIdTable(db),
                                referencedColumn:
                                    $$PlaylistTracksTableTableReferences
                                        ._ripTrackIdTable(db)
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

typedef $$PlaylistTracksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistTracksTableTable,
      PlaylistTracksTableData,
      $$PlaylistTracksTableTableFilterComposer,
      $$PlaylistTracksTableTableOrderingComposer,
      $$PlaylistTracksTableTableAnnotationComposer,
      $$PlaylistTracksTableTableCreateCompanionBuilder,
      $$PlaylistTracksTableTableUpdateCompanionBuilder,
      (PlaylistTracksTableData, $$PlaylistTracksTableTableReferences),
      PlaylistTracksTableData,
      PrefetchHooks Function({bool playlistId, bool ripTrackId})
    >;
typedef $$LocationsTableTableCreateCompanionBuilder =
    LocationsTableCompanion Function({
      required String id,
      Value<String?> parentId,
      required String name,
      Value<int> sortOrder,
      required int updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$LocationsTableTableUpdateCompanionBuilder =
    LocationsTableCompanion Function({
      Value<String> id,
      Value<String?> parentId,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

class $$LocationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTableTable> {
  $$LocationsTableTableFilterComposer({
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

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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
}

class $$LocationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTableTable> {
  $$LocationsTableTableOrderingComposer({
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

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

class $$LocationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTableTable> {
  $$LocationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$LocationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTableTable,
          LocationsTableData,
          $$LocationsTableTableFilterComposer,
          $$LocationsTableTableOrderingComposer,
          $$LocationsTableTableAnnotationComposer,
          $$LocationsTableTableCreateCompanionBuilder,
          $$LocationsTableTableUpdateCompanionBuilder,
          (
            LocationsTableData,
            BaseReferences<
              _$AppDatabase,
              $LocationsTableTable,
              LocationsTableData
            >,
          ),
          LocationsTableData,
          PrefetchHooks Function()
        > {
  $$LocationsTableTableTableManager(
    _$AppDatabase db,
    $LocationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsTableCompanion(
                id: id,
                parentId: parentId,
                name: name,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> parentId = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required int updatedAt,
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsTableCompanion.insert(
                id: id,
                parentId: parentId,
                name: name,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTableTable,
      LocationsTableData,
      $$LocationsTableTableFilterComposer,
      $$LocationsTableTableOrderingComposer,
      $$LocationsTableTableAnnotationComposer,
      $$LocationsTableTableCreateCompanionBuilder,
      $$LocationsTableTableUpdateCompanionBuilder,
      (
        LocationsTableData,
        BaseReferences<_$AppDatabase, $LocationsTableTable, LocationsTableData>,
      ),
      LocationsTableData,
      PrefetchHooks Function()
    >;
typedef $$SeriesTableTableCreateCompanionBuilder =
    SeriesTableCompanion Function({
      required String id,
      required String externalId,
      required String name,
      required String mediaType,
      required String source,
      Value<int?> totalCount,
      required int updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });
typedef $$SeriesTableTableUpdateCompanionBuilder =
    SeriesTableCompanion Function({
      Value<String> id,
      Value<String> externalId,
      Value<String> name,
      Value<String> mediaType,
      Value<String> source,
      Value<int?> totalCount,
      Value<int> updatedAt,
      Value<int> deleted,
      Value<int> rowid,
    });

class $$SeriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableFilterComposer({
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

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
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
}

class $$SeriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableOrderingComposer({
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

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
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

class $$SeriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$SeriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesTableTable,
          SeriesTableData,
          $$SeriesTableTableFilterComposer,
          $$SeriesTableTableOrderingComposer,
          $$SeriesTableTableAnnotationComposer,
          $$SeriesTableTableCreateCompanionBuilder,
          $$SeriesTableTableUpdateCompanionBuilder,
          (
            SeriesTableData,
            BaseReferences<_$AppDatabase, $SeriesTableTable, SeriesTableData>,
          ),
          SeriesTableData,
          PrefetchHooks Function()
        > {
  $$SeriesTableTableTableManager(_$AppDatabase db, $SeriesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> totalCount = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesTableCompanion(
                id: id,
                externalId: externalId,
                name: name,
                mediaType: mediaType,
                source: source,
                totalCount: totalCount,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String externalId,
                required String name,
                required String mediaType,
                required String source,
                Value<int?> totalCount = const Value.absent(),
                required int updatedAt,
                Value<int> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesTableCompanion.insert(
                id: id,
                externalId: externalId,
                name: name,
                mediaType: mediaType,
                source: source,
                totalCount: totalCount,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesTableTable,
      SeriesTableData,
      $$SeriesTableTableFilterComposer,
      $$SeriesTableTableOrderingComposer,
      $$SeriesTableTableAnnotationComposer,
      $$SeriesTableTableCreateCompanionBuilder,
      $$SeriesTableTableUpdateCompanionBuilder,
      (
        SeriesTableData,
        BaseReferences<_$AppDatabase, $SeriesTableTable, SeriesTableData>,
      ),
      SeriesTableData,
      PrefetchHooks Function()
    >;
typedef $$TmdbAccountSyncItemsTableTableCreateCompanionBuilder =
    TmdbAccountSyncItemsTableCompanion Function({
      required String id,
      Value<String?> mediaItemId,
      required int tmdbId,
      required String tmdbMediaType,
      Value<String?> barcode,
      Value<String?> titleSnapshot,
      Value<String?> posterPathSnapshot,
      Value<double?> tmdbRating,
      Value<double?> localRatingSnapshot,
      Value<int> watchlist,
      Value<int> favorite,
      Value<String> listIdsJson,
      Value<String> accountStateJson,
      Value<int> localDirty,
      Value<int> remoteDirty,
      Value<int?> lastPulledAt,
      Value<int?> lastPushedAt,
      Value<String?> lastError,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TmdbAccountSyncItemsTableTableUpdateCompanionBuilder =
    TmdbAccountSyncItemsTableCompanion Function({
      Value<String> id,
      Value<String?> mediaItemId,
      Value<int> tmdbId,
      Value<String> tmdbMediaType,
      Value<String?> barcode,
      Value<String?> titleSnapshot,
      Value<String?> posterPathSnapshot,
      Value<double?> tmdbRating,
      Value<double?> localRatingSnapshot,
      Value<int> watchlist,
      Value<int> favorite,
      Value<String> listIdsJson,
      Value<String> accountStateJson,
      Value<int> localDirty,
      Value<int> remoteDirty,
      Value<int?> lastPulledAt,
      Value<int?> lastPushedAt,
      Value<String?> lastError,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$TmdbAccountSyncItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TmdbAccountSyncItemsTableTable> {
  $$TmdbAccountSyncItemsTableTableFilterComposer({
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

  ColumnFilters<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tmdbMediaType => $composableBuilder(
    column: $table.tmdbMediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPathSnapshot => $composableBuilder(
    column: $table.posterPathSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tmdbRating => $composableBuilder(
    column: $table.tmdbRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get localRatingSnapshot => $composableBuilder(
    column: $table.localRatingSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get watchlist => $composableBuilder(
    column: $table.watchlist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listIdsJson => $composableBuilder(
    column: $table.listIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountStateJson => $composableBuilder(
    column: $table.accountStateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localDirty => $composableBuilder(
    column: $table.localDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteDirty => $composableBuilder(
    column: $table.remoteDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPushedAt => $composableBuilder(
    column: $table.lastPushedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TmdbAccountSyncItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TmdbAccountSyncItemsTableTable> {
  $$TmdbAccountSyncItemsTableTableOrderingComposer({
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

  ColumnOrderings<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tmdbMediaType => $composableBuilder(
    column: $table.tmdbMediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPathSnapshot => $composableBuilder(
    column: $table.posterPathSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tmdbRating => $composableBuilder(
    column: $table.tmdbRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get localRatingSnapshot => $composableBuilder(
    column: $table.localRatingSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get watchlist => $composableBuilder(
    column: $table.watchlist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listIdsJson => $composableBuilder(
    column: $table.listIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountStateJson => $composableBuilder(
    column: $table.accountStateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localDirty => $composableBuilder(
    column: $table.localDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteDirty => $composableBuilder(
    column: $table.remoteDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPushedAt => $composableBuilder(
    column: $table.lastPushedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TmdbAccountSyncItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TmdbAccountSyncItemsTableTable> {
  $$TmdbAccountSyncItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get tmdbMediaType => $composableBuilder(
    column: $table.tmdbMediaType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get posterPathSnapshot => $composableBuilder(
    column: $table.posterPathSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tmdbRating => $composableBuilder(
    column: $table.tmdbRating,
    builder: (column) => column,
  );

  GeneratedColumn<double> get localRatingSnapshot => $composableBuilder(
    column: $table.localRatingSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get watchlist =>
      $composableBuilder(column: $table.watchlist, builder: (column) => column);

  GeneratedColumn<int> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<String> get listIdsJson => $composableBuilder(
    column: $table.listIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountStateJson => $composableBuilder(
    column: $table.accountStateJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localDirty => $composableBuilder(
    column: $table.localDirty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteDirty => $composableBuilder(
    column: $table.remoteDirty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPushedAt => $composableBuilder(
    column: $table.lastPushedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TmdbAccountSyncItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TmdbAccountSyncItemsTableTable,
          TmdbAccountSyncItemsTableData,
          $$TmdbAccountSyncItemsTableTableFilterComposer,
          $$TmdbAccountSyncItemsTableTableOrderingComposer,
          $$TmdbAccountSyncItemsTableTableAnnotationComposer,
          $$TmdbAccountSyncItemsTableTableCreateCompanionBuilder,
          $$TmdbAccountSyncItemsTableTableUpdateCompanionBuilder,
          (
            TmdbAccountSyncItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $TmdbAccountSyncItemsTableTable,
              TmdbAccountSyncItemsTableData
            >,
          ),
          TmdbAccountSyncItemsTableData,
          PrefetchHooks Function()
        > {
  $$TmdbAccountSyncItemsTableTableTableManager(
    _$AppDatabase db,
    $TmdbAccountSyncItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TmdbAccountSyncItemsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TmdbAccountSyncItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TmdbAccountSyncItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> mediaItemId = const Value.absent(),
                Value<int> tmdbId = const Value.absent(),
                Value<String> tmdbMediaType = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> titleSnapshot = const Value.absent(),
                Value<String?> posterPathSnapshot = const Value.absent(),
                Value<double?> tmdbRating = const Value.absent(),
                Value<double?> localRatingSnapshot = const Value.absent(),
                Value<int> watchlist = const Value.absent(),
                Value<int> favorite = const Value.absent(),
                Value<String> listIdsJson = const Value.absent(),
                Value<String> accountStateJson = const Value.absent(),
                Value<int> localDirty = const Value.absent(),
                Value<int> remoteDirty = const Value.absent(),
                Value<int?> lastPulledAt = const Value.absent(),
                Value<int?> lastPushedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TmdbAccountSyncItemsTableCompanion(
                id: id,
                mediaItemId: mediaItemId,
                tmdbId: tmdbId,
                tmdbMediaType: tmdbMediaType,
                barcode: barcode,
                titleSnapshot: titleSnapshot,
                posterPathSnapshot: posterPathSnapshot,
                tmdbRating: tmdbRating,
                localRatingSnapshot: localRatingSnapshot,
                watchlist: watchlist,
                favorite: favorite,
                listIdsJson: listIdsJson,
                accountStateJson: accountStateJson,
                localDirty: localDirty,
                remoteDirty: remoteDirty,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> mediaItemId = const Value.absent(),
                required int tmdbId,
                required String tmdbMediaType,
                Value<String?> barcode = const Value.absent(),
                Value<String?> titleSnapshot = const Value.absent(),
                Value<String?> posterPathSnapshot = const Value.absent(),
                Value<double?> tmdbRating = const Value.absent(),
                Value<double?> localRatingSnapshot = const Value.absent(),
                Value<int> watchlist = const Value.absent(),
                Value<int> favorite = const Value.absent(),
                Value<String> listIdsJson = const Value.absent(),
                Value<String> accountStateJson = const Value.absent(),
                Value<int> localDirty = const Value.absent(),
                Value<int> remoteDirty = const Value.absent(),
                Value<int?> lastPulledAt = const Value.absent(),
                Value<int?> lastPushedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TmdbAccountSyncItemsTableCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                tmdbId: tmdbId,
                tmdbMediaType: tmdbMediaType,
                barcode: barcode,
                titleSnapshot: titleSnapshot,
                posterPathSnapshot: posterPathSnapshot,
                tmdbRating: tmdbRating,
                localRatingSnapshot: localRatingSnapshot,
                watchlist: watchlist,
                favorite: favorite,
                listIdsJson: listIdsJson,
                accountStateJson: accountStateJson,
                localDirty: localDirty,
                remoteDirty: remoteDirty,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TmdbAccountSyncItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TmdbAccountSyncItemsTableTable,
      TmdbAccountSyncItemsTableData,
      $$TmdbAccountSyncItemsTableTableFilterComposer,
      $$TmdbAccountSyncItemsTableTableOrderingComposer,
      $$TmdbAccountSyncItemsTableTableAnnotationComposer,
      $$TmdbAccountSyncItemsTableTableCreateCompanionBuilder,
      $$TmdbAccountSyncItemsTableTableUpdateCompanionBuilder,
      (
        TmdbAccountSyncItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $TmdbAccountSyncItemsTableTable,
          TmdbAccountSyncItemsTableData
        >,
      ),
      TmdbAccountSyncItemsTableData,
      PrefetchHooks Function()
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
  $$RipAlbumsTableTableTableManager get ripAlbumsTable =>
      $$RipAlbumsTableTableTableManager(_db, _db.ripAlbumsTable);
  $$RipTracksTableTableTableManager get ripTracksTable =>
      $$RipTracksTableTableTableManager(_db, _db.ripTracksTable);
  $$BatchSessionsTableTableTableManager get batchSessionsTable =>
      $$BatchSessionsTableTableTableManager(_db, _db.batchSessionsTable);
  $$BatchQueueItemsTableTableTableManager get batchQueueItemsTable =>
      $$BatchQueueItemsTableTableTableManager(_db, _db.batchQueueItemsTable);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(_db, _db.playlistsTable);
  $$PlaylistTracksTableTableTableManager get playlistTracksTable =>
      $$PlaylistTracksTableTableTableManager(_db, _db.playlistTracksTable);
  $$LocationsTableTableTableManager get locationsTable =>
      $$LocationsTableTableTableManager(_db, _db.locationsTable);
  $$SeriesTableTableTableManager get seriesTable =>
      $$SeriesTableTableTableManager(_db, _db.seriesTable);
  $$TmdbAccountSyncItemsTableTableTableManager get tmdbAccountSyncItemsTable =>
      $$TmdbAccountSyncItemsTableTableTableManager(
        _db,
        _db.tmdbAccountSyncItemsTable,
      );
}
