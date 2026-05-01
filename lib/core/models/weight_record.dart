/// Modelo de datos puro - sin dependencias de Isar
class WeightRecord {
  final int? id;
  final double weightKg;
  final DateTime dateTime;

  /// true si el cambio está en cola local y aún no se ha confirmado en el servidor.
  final bool pendingRemoteSync;

  WeightRecord({
    this.id,
    required this.weightKg,
    required this.dateTime,
    this.pendingRemoteSync = false,
  });

  WeightRecord copyWith({
    int? id,
    double? weightKg,
    DateTime? dateTime,
    bool? pendingRemoteSync,
  }) =>
      WeightRecord(
        id: id ?? this.id,
        weightKg: weightKg ?? this.weightKg,
        dateTime: dateTime ?? this.dateTime,
        pendingRemoteSync: pendingRemoteSync ?? this.pendingRemoteSync,
      );
}
