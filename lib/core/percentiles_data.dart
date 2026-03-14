/// Percentil 50 (mediana) de peso por edad según estándares OMS (Weight-for-age).
/// Valores en kg para niños y niñas de 0 a 12 meses.
/// Fuente: WHO Child Growth Standards (2006)
class PercentilesData {
  /// P50 para niños (boys) - edad en meses completos -> peso en kg
  static const Map<int, double> boysP50 = {
    0: 3.3,
    1: 4.5,
    2: 5.6,
    3: 6.4,
    4: 7.0,
    5: 7.5,
    6: 7.9,
    7: 8.3,
    8: 8.6,
    9: 8.9,
    10: 9.2,
    11: 9.4,
    12: 9.6,
  };

  /// P50 para niñas (girls) - edad en meses completos -> peso en kg
  static const Map<int, double> girlsP50 = {
    0: 3.2,
    1: 4.2,
    2: 5.1,
    3: 5.8,
    4: 6.4,
    5: 6.9,
    6: 7.3,
    7: 7.6,
    8: 7.9,
    9: 8.2,
    10: 8.5,
    11: 8.7,
    12: 8.9,
  };

  /// Obtiene el peso P50 para una edad dada (en meses decimales).
  /// Interpola linealmente entre los valores de meses completos.
  static double getP50Weight(bool isMale, double ageInMonths) {
    final data = isMale ? boysP50 : girlsP50;
    if (ageInMonths <= 0) return data[0]!;
    if (ageInMonths >= 12) return data[12]!;

    final monthFloor = ageInMonths.floor();
    final monthCeil = (ageInMonths.ceil()).clamp(0, 12);
    final lower = data[monthFloor] ?? data[0]!;
    final upper = data[monthCeil] ?? data[12]!;
    final t = ageInMonths - monthFloor;

    return lower + (upper - lower) * t;
  }

  /// Genera puntos para dibujar la línea de referencia en el gráfico.
  /// [minMonth] y [maxMonth] definen el rango de edad a mostrar.
  /// [minWeight] y [maxWeight] son los límites del eje Y del gráfico.
  static List<({double month, double weight})> getReferenceLinePoints({
    required bool isMale,
    required double minMonth,
    required double maxMonth,
    required double minWeight,
    required double maxWeight,
    int pointsCount = 20,
  }) {
    final result = <({double month, double weight})>[];
    final step = (maxMonth - minMonth) / (pointsCount - 1);

    for (var i = 0; i < pointsCount; i++) {
      final month = minMonth + step * i;
      final weight = getP50Weight(isMale, month);
      if (weight >= minWeight && weight <= maxWeight) {
        result.add((month: month, weight: weight));
      }
    }
    return result;
  }
}
