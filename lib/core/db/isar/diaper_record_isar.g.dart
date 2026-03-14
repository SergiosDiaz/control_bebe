// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diaper_record_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDiaperRecordIsarCollection on Isar {
  IsarCollection<DiaperRecordIsar> get diaperRecordIsars => this.collection();
}

const DiaperRecordIsarSchema = CollectionSchema(
  name: r'DiaperRecordIsar',
  id: 6932500667706298936,
  properties: {
    r'dateTime': PropertySchema(
      id: 0,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 1,
      name: r'type',
      type: IsarType.byte,
      enumMap: _DiaperRecordIsartypeEnumValueMap,
    )
  },
  estimateSize: _diaperRecordIsarEstimateSize,
  serialize: _diaperRecordIsarSerialize,
  deserialize: _diaperRecordIsarDeserialize,
  deserializeProp: _diaperRecordIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _diaperRecordIsarGetId,
  getLinks: _diaperRecordIsarGetLinks,
  attach: _diaperRecordIsarAttach,
  version: '3.1.0+1',
);

int _diaperRecordIsarEstimateSize(
  DiaperRecordIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _diaperRecordIsarSerialize(
  DiaperRecordIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateTime);
  writer.writeByte(offsets[1], object.type.index);
}

DiaperRecordIsar _diaperRecordIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DiaperRecordIsar();
  object.dateTime = reader.readDateTime(offsets[0]);
  object.id = id;
  object.type =
      _DiaperRecordIsartypeValueEnumMap[reader.readByteOrNull(offsets[1])] ??
          DiaperType.wet;
  return object;
}

P _diaperRecordIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (_DiaperRecordIsartypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          DiaperType.wet) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DiaperRecordIsartypeEnumValueMap = {
  'wet': 0,
  'dirty': 1,
  'both': 2,
};
const _DiaperRecordIsartypeValueEnumMap = {
  0: DiaperType.wet,
  1: DiaperType.dirty,
  2: DiaperType.both,
};

Id _diaperRecordIsarGetId(DiaperRecordIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _diaperRecordIsarGetLinks(DiaperRecordIsar object) {
  return [];
}

void _diaperRecordIsarAttach(
    IsarCollection<dynamic> col, Id id, DiaperRecordIsar object) {
  object.id = id;
}

extension DiaperRecordIsarQueryWhereSort
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QWhere> {
  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DiaperRecordIsarQueryWhere
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QWhereClause> {
  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterWhereClause>
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterWhereClause> idBetween(
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

extension DiaperRecordIsarQueryFilter
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QFilterCondition> {
  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
      typeEqualTo(DiaperType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
      typeGreaterThan(
    DiaperType value, {
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
      typeLessThan(
    DiaperType value, {
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

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterFilterCondition>
      typeBetween(
    DiaperType lower,
    DiaperType upper, {
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

extension DiaperRecordIsarQueryObject
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QFilterCondition> {}

extension DiaperRecordIsarQueryLinks
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QFilterCondition> {}

extension DiaperRecordIsarQuerySortBy
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QSortBy> {
  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy>
      sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension DiaperRecordIsarQuerySortThenBy
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QSortThenBy> {
  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy>
      thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension DiaperRecordIsarQueryWhereDistinct
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QDistinct> {
  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension DiaperRecordIsarQueryProperty
    on QueryBuilder<DiaperRecordIsar, DiaperRecordIsar, QQueryProperty> {
  QueryBuilder<DiaperRecordIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DiaperRecordIsar, DateTime, QQueryOperations>
      dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<DiaperRecordIsar, DiaperType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
