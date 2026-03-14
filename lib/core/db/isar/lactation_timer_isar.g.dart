// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lactation_timer_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLactationTimerIsarCollection on Isar {
  IsarCollection<LactationTimerIsar> get lactationTimerIsars =>
      this.collection();
}

const LactationTimerIsarSchema = CollectionSchema(
  name: r'LactationTimerIsar',
  id: 8632437419610655486,
  properties: {
    r'side': PropertySchema(
      id: 0,
      name: r'side',
      type: IsarType.byte,
      enumMap: _LactationTimerIsarsideEnumValueMap,
    ),
    r'startedAt': PropertySchema(
      id: 1,
      name: r'startedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _lactationTimerIsarEstimateSize,
  serialize: _lactationTimerIsarSerialize,
  deserialize: _lactationTimerIsarDeserialize,
  deserializeProp: _lactationTimerIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _lactationTimerIsarGetId,
  getLinks: _lactationTimerIsarGetLinks,
  attach: _lactationTimerIsarAttach,
  version: '3.1.0+1',
);

int _lactationTimerIsarEstimateSize(
  LactationTimerIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _lactationTimerIsarSerialize(
  LactationTimerIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.side.index);
  writer.writeDateTime(offsets[1], object.startedAt);
}

LactationTimerIsar _lactationTimerIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LactationTimerIsar();
  object.id = id;
  object.side =
      _LactationTimerIsarsideValueEnumMap[reader.readByteOrNull(offsets[0])] ??
          LactationSide.left;
  object.startedAt = reader.readDateTime(offsets[1]);
  return object;
}

P _lactationTimerIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_LactationTimerIsarsideValueEnumMap[
              reader.readByteOrNull(offset)] ??
          LactationSide.left) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LactationTimerIsarsideEnumValueMap = {
  'left': 0,
  'right': 1,
};
const _LactationTimerIsarsideValueEnumMap = {
  0: LactationSide.left,
  1: LactationSide.right,
};

Id _lactationTimerIsarGetId(LactationTimerIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lactationTimerIsarGetLinks(
    LactationTimerIsar object) {
  return [];
}

void _lactationTimerIsarAttach(
    IsarCollection<dynamic> col, Id id, LactationTimerIsar object) {
  object.id = id;
}

extension LactationTimerIsarQueryWhereSort
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QWhere> {
  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LactationTimerIsarQueryWhere
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QWhereClause> {
  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterWhereClause>
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

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterWhereClause>
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

extension LactationTimerIsarQueryFilter
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QFilterCondition> {
  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
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

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
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

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
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

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      sideEqualTo(LactationSide value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'side',
        value: value,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      sideGreaterThan(
    LactationSide value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'side',
        value: value,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      sideLessThan(
    LactationSide value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'side',
        value: value,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      sideBetween(
    LactationSide lower,
    LactationSide upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'side',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterFilterCondition>
      startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LactationTimerIsarQueryObject
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QFilterCondition> {}

extension LactationTimerIsarQueryLinks
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QFilterCondition> {}

extension LactationTimerIsarQuerySortBy
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QSortBy> {
  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      sortBySide() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'side', Sort.asc);
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      sortBySideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'side', Sort.desc);
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }
}

extension LactationTimerIsarQuerySortThenBy
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QSortThenBy> {
  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      thenBySide() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'side', Sort.asc);
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      thenBySideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'side', Sort.desc);
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QAfterSortBy>
      thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }
}

extension LactationTimerIsarQueryWhereDistinct
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QDistinct> {
  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QDistinct>
      distinctBySide() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'side');
    });
  }

  QueryBuilder<LactationTimerIsar, LactationTimerIsar, QDistinct>
      distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }
}

extension LactationTimerIsarQueryProperty
    on QueryBuilder<LactationTimerIsar, LactationTimerIsar, QQueryProperty> {
  QueryBuilder<LactationTimerIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LactationTimerIsar, LactationSide, QQueryOperations>
      sideProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'side');
    });
  }

  QueryBuilder<LactationTimerIsar, DateTime, QQueryOperations>
      startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }
}
