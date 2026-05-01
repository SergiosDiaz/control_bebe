import 'enums.dart';

/// Modelo de datos puro - sin dependencias de Isar
class DiaperRecord {
  final int? id;
  final DiaperType type;
  final DateTime dateTime;

  /// true si el cambio está en cola local y aún no se ha confirmado en el servidor.
  final bool pendingRemoteSync;

  DiaperRecord({
    this.id,
    required this.type,
    required this.dateTime,
    this.pendingRemoteSync = false,
  });

  DiaperRecord copyWith({
    int? id,
    DiaperType? type,
    DateTime? dateTime,
    bool? pendingRemoteSync,
  }) =>
      DiaperRecord(
        id: id ?? this.id,
        type: type ?? this.type,
        dateTime: dateTime ?? this.dateTime,
        pendingRemoteSync: pendingRemoteSync ?? this.pendingRemoteSync,
      );
}
