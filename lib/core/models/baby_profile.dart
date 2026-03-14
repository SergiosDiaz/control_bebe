/// Modelo de datos puro - sin dependencias de Isar
class BabyProfile {
  final int? id;
  final String name;
  final bool isMale;
  final DateTime birthDate;
  final DateTime? createdAt;

  BabyProfile({
    this.id,
    required this.name,
    required this.isMale,
    required this.birthDate,
    this.createdAt,
  });

  BabyProfile copyWith({
    int? id,
    String? name,
    bool? isMale,
    DateTime? birthDate,
    DateTime? createdAt,
  }) =>
      BabyProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        isMale: isMale ?? this.isMale,
        birthDate: birthDate ?? this.birthDate,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Edad en meses decimales desde el nacimiento
  double get ageInMonths {
    final now = DateTime.now();
    final diff = now.difference(birthDate);
    return diff.inDays / 30.44;
  }
}
