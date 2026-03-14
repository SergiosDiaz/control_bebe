import 'enums.dart';

/// Modelo de datos puro - sin dependencias de Isar
class FeedingRecord {
  final int? id;
  final FeedingType type;
  final DateTime dateTime;
  final int? durationSeconds;
  final int? amountMl;

  FeedingRecord({
    this.id,
    required this.type,
    required this.dateTime,
    this.durationSeconds,
    this.amountMl,
  });

  FeedingRecord copyWith({
    int? id,
    FeedingType? type,
    DateTime? dateTime,
    int? durationSeconds,
    int? amountMl,
  }) =>
      FeedingRecord(
        id: id ?? this.id,
        type: type ?? this.type,
        dateTime: dateTime ?? this.dateTime,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        amountMl: amountMl ?? this.amountMl,
      );
}
