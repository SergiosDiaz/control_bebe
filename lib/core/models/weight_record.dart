/// Modelo de datos puro - sin dependencias de Isar
class WeightRecord {
  final int? id;
  final double weightKg;
  final DateTime dateTime;

  WeightRecord({
    this.id,
    required this.weightKg,
    required this.dateTime,
  });

  WeightRecord copyWith({
    int? id,
    double? weightKg,
    DateTime? dateTime,
  }) =>
      WeightRecord(
        id: id ?? this.id,
        weightKg: weightKg ?? this.weightKg,
        dateTime: dateTime ?? this.dateTime,
      );
}
