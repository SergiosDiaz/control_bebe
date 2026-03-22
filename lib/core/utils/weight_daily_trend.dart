import '../models/weight_record.dart';

/// Gramos ganados o perdidos por día entre dos pesadas consecutivas.
/// [newer] es la más reciente; [older] la anterior.
double? dailyWeightTrendGramsPerDay(WeightRecord newer, WeightRecord older) {
  final deltaMs = newer.dateTime.difference(older.dateTime).inMilliseconds;
  if (deltaMs <= 0) return null;
  final days = deltaMs / Duration.millisecondsPerDay;
  final deltaG = (newer.weightKg - older.weightKg) * 1000.0;
  return deltaG / days;
}
