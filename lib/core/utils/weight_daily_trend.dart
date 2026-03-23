import '../models/weight_record.dart';

/// Pendiente de una regresión lineal simple peso (kg) vs tiempo (días),
/// con los registros cuya fecha cae en la ventana de [window] hasta [now].
///
/// Devuelve gramos por día, o `null` si hay menos de 2 puntos o el tiempo no varía.
double? dailyWeightTrendLinearRegressionGramsPerDay(
  List<WeightRecord> records, {
  DateTime? now,
  Duration window = const Duration(days: 7),
}) {
  final clock = now ?? DateTime.now();
  final cutoff = clock.subtract(window);
  final inWindow = records.where((r) => !r.dateTime.isBefore(cutoff)).toList();
  if (inWindow.length < 2) return null;

  inWindow.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  final origin = inWindow.first.dateTime;
  final xs = <double>[];
  final ys = <double>[];
  for (final r in inWindow) {
    final days = r.dateTime.difference(origin).inMilliseconds /
        Duration.millisecondsPerDay.toDouble();
    xs.add(days);
    ys.add(r.weightKg);
  }

  final n = xs.length;
  var sumX = 0.0;
  var sumY = 0.0;
  for (var i = 0; i < n; i++) {
    sumX += xs[i];
    sumY += ys[i];
  }
  final meanX = sumX / n;
  final meanY = sumY / n;

  var sxx = 0.0;
  var sxy = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = xs[i] - meanX;
    final dy = ys[i] - meanY;
    sxx += dx * dx;
    sxy += dx * dy;
  }
  if (sxx <= 1e-18) return null;

  final slopeKgPerDay = sxy / sxx;
  return slopeKgPerDay * 1000.0;
}
