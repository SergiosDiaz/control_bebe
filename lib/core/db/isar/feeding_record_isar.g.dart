// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_record_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFeedingRecordIsarCollection on Isar {
  IsarCollection<FeedingRecordIsar> get feedingRecordIsars => this.collection();
}

const FeedingRecordIsarSchema = CollectionSchema(
  name: r'FeedingRecordIsar',
  id: 6317814239820309822,
  properties: {
    r'amountMl': PropertySchema(
      id: 0,
      name: r'amountMl',
      type: IsarType.long,
    ),
    r'dateTime': PropertySchema(
      id: 1,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'durationSeconds': PropertySchema(
      id: 2,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.byte,
      enumMap: _FeedingRecordIsartypeEnumValueMap,
    )
  },
  estimateSize: _feedingRecordIsarEstimateSize,
  serialize: _feedingRecordIsarSerialize,
  deserialize: _feedingRecordIsarDeserialize,
  deserializeProp: _feedingRecordIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _feedingRecordIsarGetId,
  getLinks: _feedingRecordIsarGetLinks,
  attach: _feedingRecordIsarAttach,
  version: '3.1.0+1',
);

int _feedingRecordIsarEstimateSize(
  FeedingRecordIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _feedingRecordIsarSerialize(
  FeedingRecordIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amountMl);
  writer.writeDateTime(offsets[1], object.dateTime);
  writer.writeLong(offsets[2], object.durationSeconds);
  writer.writeByte(offsets[3], object.type.index);
}

FeedingRecordIsar _feedingRecordIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FeedingRecordIsar();
  object.amountMl = reader.readLongOrNull(offsets[0]);
  object.dateTime = reader.readDateTime(offsets[1]);
  object.durationSeconds = reader.readLongOrNull(offsets[2]);
  object.id = id;
  object.type =
      _FeedingRecordIsartypeValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          FeedingType.leftBreast;
  return object;
}

P _feedingRecordIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (_FeedingRecordIsartypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          FeedingType.leftBreast) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FeedingRecordIsartypeEnumValueMap = {
  'leftBreast': 0,
  'rightBreast': 1,
  'bottle': 2,
};
const _FeedingRecordIsartypeValueEnumMap = {
  0: FeedingType.leftBreast,
  1: FeedingType.rightBreast,
  2: FeedingType.bottle,
};

Id _feedingRecordIsarGetId(FeedingRecordIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _feedingRecordIsarGetLinks(
    FeedingRecordIsar object) {
  return [];
}

void _feedingRecordIsarAttach(
    IsarCollection<dynamic> col, Id id, FeedingRecordIsar object) {
  object.id = id;
}

extension FeedingRecordIsarQueryWhereSort
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QWhere> {
  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FeedingRecordIsarQueryWhere
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QWhereClause> {
  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FeedingRecordIsarQueryFilter
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QFilterCondition> {
  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      amountMlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'amountMl',
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      amountMlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'amountMl',
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      amountMlEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountMl',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      amountMlGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amountMl',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      amountMlLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amountMl',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      amountMlBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amountMl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      dateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      dateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      dateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      durationSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationSeconds',
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      durationSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationSeconds',
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      durationSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      durationSecondsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      durationSecondsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      durationSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      typeEqualTo(FeedingType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      typeGreaterThan(
    FeedingType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      typeLessThan(
    FeedingType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterFilterCondition>
      typeBetween(
    FeedingType lower,
    FeedingType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FeedingRecordIsarQueryObject
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QFilterCondition> {}

extension FeedingRecordIsarQueryLinks
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QFilterCondition> {}

extension FeedingRecordIsarQuerySortBy
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QSortBy> {
  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      sortByAmountMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMl', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      sortByAmountMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMl', Sort.desc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension FeedingRecordIsarQuerySortThenBy
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QSortThenBy> {
  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByAmountMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMl', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByAmountMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMl', Sort.desc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension FeedingRecordIsarQueryWhereDistinct
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QDistinct> {
  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QDistinct>
      distinctByAmountMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountMl');
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension FeedingRecordIsarQueryProperty
    on QueryBuilder<FeedingRecordIsar, FeedingRecordIsar, QQueryProperty> {
  QueryBuilder<FeedingRecordIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FeedingRecordIsar, int?, QQueryOperations> amountMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountMl');
    });
  }

  QueryBuilder<FeedingRecordIsar, DateTime, QQueryOperations>
      dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<FeedingRecordIsar, int?, QQueryOperations>
      durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<FeedingRecordIsar, FeedingType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
