/// Modelo de datos puro - sin dependencias de Isar
class BabyProfile {
  final int? id;
  final String name;
  final bool isMale;
  final DateTime birthDate;
  final DateTime? createdAt;
  /// Foto en base64 (data:image/jpeg;base64,...) o URL de Firebase Storage
  final String? photoUrl;

  BabyProfile({
    this.id,
    required this.name,
    required this.isMale,
    required this.birthDate,
    this.createdAt,
    this.photoUrl,
  });

  BabyProfile copyWith({
    int? id,
    String? name,
    bool? isMale,
    DateTime? birthDate,
    DateTime? createdAt,
    String? photoUrl,
  }) =>
      BabyProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        isMale: isMale ?? this.isMale,
        birthDate: birthDate ?? this.birthDate,
        createdAt: createdAt ?? this.createdAt,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  /// Edad en meses decimales desde el nacimiento
  double get ageInMonths {
    final now = DateTime.now();
    final diff = now.difference(birthDate);
    return diff.inDays / 30.44;
  }
}
