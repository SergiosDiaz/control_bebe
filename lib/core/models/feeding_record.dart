import 'enums.dart';

/// Modelo de datos puro - sin dependencias de Isar
class FeedingRecord {
  final int? id;
  final FeedingType type;
  final DateTime dateTime;
  final int? durationSeconds;
  final int? amountMl;

  /// Solo [FeedingType.solidFood]: descripción (p. ej. «Puré de verduras»).
  final String? solidName;

  /// Solo sólidos: gramos (puede ser decimal) o número de unidades (entero).
  final double? solidQuantity;

  /// Solo sólidos: interpretación de [solidQuantity].
  final SolidQuantityUnit? solidUnit;

  /// true si el cambio está en cola local y aún no se ha confirmado en el servidor.
  final bool pendingRemoteSync;

  FeedingRecord({
    this.id,
    required this.type,
    required this.dateTime,
    this.durationSeconds,
    this.amountMl,
    this.solidName,
    this.solidQuantity,
    this.solidUnit,
    this.pendingRemoteSync = false,
  });

  FeedingRecord copyWith({
    int? id,
    FeedingType? type,
    DateTime? dateTime,
    int? durationSeconds,
    int? amountMl,
    String? solidName,
    double? solidQuantity,
    SolidQuantityUnit? solidUnit,
    bool? pendingRemoteSync,
  }) =>
      FeedingRecord(
        id: id ?? this.id,
        type: type ?? this.type,
        dateTime: dateTime ?? this.dateTime,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        amountMl: amountMl ?? this.amountMl,
        solidName: solidName ?? this.solidName,
        solidQuantity: solidQuantity ?? this.solidQuantity,
        solidUnit: solidUnit ?? this.solidUnit,
        pendingRemoteSync: pendingRemoteSync ?? this.pendingRemoteSync,
      );
}
