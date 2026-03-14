/// Modelo de datos puro - sin dependencias de Isar
class AppSettings {
  final int id;
  final bool onboardingCompleted;
  final List<String> homeCardOrder;

  AppSettings({
    this.id = 1,
    this.onboardingCompleted = false,
    this.homeCardOrder = const ['weight', 'feeding', 'diapers'],
  });

  AppSettings copyWith({
    int? id,
    bool? onboardingCompleted,
    List<String>? homeCardOrder,
  }) =>
      AppSettings(
        id: id ?? this.id,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        homeCardOrder: homeCardOrder ?? this.homeCardOrder,
      );
}
