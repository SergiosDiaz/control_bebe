/// Percentiles de peso por edad según estándares OMS (Weight-for-age).
/// Valores en kg para niños y niñas de 0 a 12 meses.
/// Fuente: WHO Child Growth Standards (2006).
enum WeightPercentile {
  p3,
  p15,
  p50,
  p85,
  p97;

  /// Texto compacto para etiquetas y selectores (e.g. "P3").
  String get shortLabel => switch (this) {
        WeightPercentile.p3 => 'P3',
        WeightPercentile.p15 => 'P15',
        WeightPercentile.p50 => 'P50',
        WeightPercentile.p85 => 'P85',
        WeightPercentile.p97 => 'P97',
      };

  /// Valores ofrecidos al usuario en el selector.
  static const List<WeightPercentile> pickerValues = [
    WeightPercentile.p3,
    WeightPercentile.p15,
    WeightPercentile.p50,
    WeightPercentile.p85,
    WeightPercentile.p97,
  ];
}

class PercentilesData {
  /// Niños — peso (kg) por edad (meses completos) y percentil.
  /// Aproximaciones a partir de WHO Child Growth Standards.
  static const Map<WeightPercentile, Map<int, double>> _boys = {
    WeightPercentile.p3: {
      0: 2.5,
      1: 3.4,
      2: 4.4,
      3: 5.1,
      4: 5.6,
      5: 6.1,
      6: 6.4,
      7: 6.7,
      8: 7.0,
      9: 7.2,
      10: 7.5,
      11: 7.7,
      12: 7.8,
    },
    WeightPercentile.p15: {
      0: 2.9,
      1: 3.9,
      2: 4.9,
      3: 5.7,
      4: 6.2,
      5: 6.7,
      6: 7.1,
      7: 7.4,
      8: 7.7,
      9: 7.9,
      10: 8.2,
      11: 8.4,
      12: 8.6,
    },
    WeightPercentile.p50: {
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
    },
    WeightPercentile.p85: {
      0: 3.9,
      1: 5.1,
      2: 6.3,
      3: 7.2,
      4: 7.8,
      5: 8.4,
      6: 8.8,
      7: 9.2,
      8: 9.6,
      9: 9.9,
      10: 10.2,
      11: 10.5,
      12: 10.8,
    },
    WeightPercentile.p97: {
      0: 4.3,
      1: 5.7,
      2: 7.0,
      3: 7.9,
      4: 8.6,
      5: 9.2,
      6: 9.7,
      7: 10.2,
      8: 10.5,
      9: 10.9,
      10: 11.2,
      11: 11.5,
      12: 11.8,
    },
  };

  /// Niñas — peso (kg) por edad (meses completos) y percentil.
  /// Aproximaciones a partir de WHO Child Growth Standards.
  static const Map<WeightPercentile, Map<int, double>> _girls = {
    WeightPercentile.p3: {
      0: 2.4,
      1: 3.2,
      2: 3.9,
      3: 4.5,
      4: 5.0,
      5: 5.4,
      6: 5.7,
      7: 6.0,
      8: 6.3,
      9: 6.5,
      10: 6.7,
      11: 6.9,
      12: 7.0,
    },
    WeightPercentile.p15: {
      0: 2.8,
      1: 3.6,
      2: 4.5,
      3: 5.1,
      4: 5.6,
      5: 6.1,
      6: 6.4,
      7: 6.7,
      8: 7.0,
      9: 7.3,
      10: 7.5,
      11: 7.7,
      12: 7.9,
    },
    WeightPercentile.p50: {
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
    },
    WeightPercentile.p85: {
      0: 3.7,
      1: 4.8,
      2: 5.8,
      3: 6.6,
      4: 7.3,
      5: 7.8,
      6: 8.2,
      7: 8.6,
      8: 9.0,
      9: 9.3,
      10: 9.6,
      11: 9.9,
      12: 10.1,
    },
    WeightPercentile.p97: {
      0: 4.2,
      1: 5.4,
      2: 6.5,
      3: 7.4,
      4: 8.1,
      5: 8.7,
      6: 9.2,
      7: 9.6,
      8: 10.0,
      9: 10.4,
      10: 10.7,
      11: 11.0,
      12: 11.3,
    },
  };

  /// Devuelve el peso del percentil indicado para una edad en meses (0-12),
  /// interpolando linealmente entre meses completos.
  static double getPercentileWeight(
    bool isMale,
    WeightPercentile percentile,
    double ageInMonths,
  ) {
    final table = isMale ? _boys[percentile]! : _girls[percentile]!;
    if (ageInMonths <= 0) return table[0]!;
    if (ageInMonths >= 12) return table[12]!;

    final monthFloor = ageInMonths.floor();
    final monthCeil = (ageInMonths.ceil()).clamp(0, 12);
    final lower = table[monthFloor] ?? table[0]!;
    final upper = table[monthCeil] ?? table[12]!;
    final t = ageInMonths - monthFloor;

    return lower + (upper - lower) * t;
  }

  /// Atajo histórico para el percentil 50 (mediana).
  static double getP50Weight(bool isMale, double ageInMonths) =>
      getPercentileWeight(isMale, WeightPercentile.p50, ageInMonths);
}
