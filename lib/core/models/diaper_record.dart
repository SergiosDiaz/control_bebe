import 'enums.dart';

/// Modelo de datos puro - sin dependencias de Isar
class DiaperRecord {
  final int? id;
  final DiaperType type;
  final DateTime dateTime;

  DiaperRecord({
    this.id,
    required this.type,
    required this.dateTime,
  });

  DiaperRecord copyWith({
    int? id,
    DiaperType? type,
    DateTime? dateTime,
  }) =>
      DiaperRecord(
        id: id ?? this.id,
        type: type ?? this.type,
        dateTime: dateTime ?? this.dateTime,
      );
}
