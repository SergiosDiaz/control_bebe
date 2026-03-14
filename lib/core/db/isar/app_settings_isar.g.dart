// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsIsarCollection on Isar {
  IsarCollection<AppSettingsIsar> get appSettingsIsars => this.collection();
}

const AppSettingsIsarSchema = CollectionSchema(
  name: r'AppSettingsIsar',
  id: 977423823482933500,
  properties: {
    r'homeCardOrder': PropertySchema(
      id: 0,
      name: r'homeCardOrder',
      type: IsarType.stringList,
    ),
    r'onboardingCompleted': PropertySchema(
      id: 1,
      name: r'onboardingCompleted',
      type: IsarType.bool,
    )
  },
  estimateSize: _appSettingsIsarEstimateSize,
  serialize: _appSettingsIsarSerialize,
  deserialize: _appSettingsIsarDeserialize,
  deserializeProp: _appSettingsIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsIsarGetId,
  getLinks: _appSettingsIsarGetLinks,
  attach: _appSettingsIsarAttach,
  version: '3.1.0+1',
);

int _appSettingsIsarEstimateSize(
  AppSettingsIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.homeCardOrder.length * 3;
  {
    for (var i = 0; i < object.homeCardOrder.length; i++) {
      final value = object.homeCardOrder[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _appSettingsIsarSerialize(
  AppSettingsIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.homeCardOrder);
  writer.writeBool(offsets[1], object.onboardingCompleted);
}

AppSettingsIsar _appSettingsIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsIsar();
  object.homeCardOrder = reader.readStringList(offsets[0]) ?? [];
  object.id = id;
  object.onboardingCompleted = reader.readBool(offsets[1]);
  return object;
}

P _appSettingsIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsIsarGetId(AppSettingsIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsIsarGetLinks(AppSettingsIsar object) {
  return [];
}

void _appSettingsIsarAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsIsar object) {
  object.id = id;
}

extension AppSettingsIsarQueryWhereSort
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QWhere> {
  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsIsarQueryWhere
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QWhereClause> {
  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterWhereClause>
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

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterWhereClause> idBetween(
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

extension AppSettingsIsarQueryFilter
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QFilterCondition> {
  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeCardOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'homeCardOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'homeCardOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'homeCardOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'homeCardOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'homeCardOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'homeCardOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'homeCardOrder',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeCardOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'homeCardOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeCardOrder',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeCardOrder',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeCardOrder',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeCardOrder',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeCardOrder',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      homeCardOrderLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'homeCardOrder',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterFilterCondition>
      onboardingCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboardingCompleted',
        value: value,
      ));
    });
  }
}

extension AppSettingsIsarQueryObject
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QFilterCondition> {}

extension AppSettingsIsarQueryLinks
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QFilterCondition> {}

extension AppSettingsIsarQuerySortBy
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QSortBy> {
  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterSortBy>
      sortByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterSortBy>
      sortByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }
}

extension AppSettingsIsarQuerySortThenBy
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QSortThenBy> {
  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterSortBy>
      thenByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QAfterSortBy>
      thenByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }
}

extension AppSettingsIsarQueryWhereDistinct
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QDistinct> {
  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QDistinct>
      distinctByHomeCardOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'homeCardOrder');
    });
  }

  QueryBuilder<AppSettingsIsar, AppSettingsIsar, QDistinct>
      distinctByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingCompleted');
    });
  }
}

extension AppSettingsIsarQueryProperty
    on QueryBuilder<AppSettingsIsar, AppSettingsIsar, QQueryProperty> {
  QueryBuilder<AppSettingsIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsIsar, List<String>, QQueryOperations>
      homeCardOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'homeCardOrder');
    });
  }

  QueryBuilder<AppSettingsIsar, bool, QQueryOperations>
      onboardingCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingCompleted');
    });
  }
}
