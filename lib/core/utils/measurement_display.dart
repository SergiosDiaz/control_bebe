import 'package:control_bebe/l10n/app_localizations.dart';

import '../models/measurement_units.dart';

const double _mlPerUsFlOz = 29.5735295625;

/// Límite superior razonable al guardar biberón (ml en almacenamiento).
const int kMaxReasonableVolumeMl = 2000;
const double _gramsPerOz = 28.349523125;
const int _ozPerLb = 16;

/// Convierte kg a libras y onzas enteras (onza redondeada).
({int lb, int oz}) kgToLbOz(double kg) {
  final totalGrams = kg * 1000;
  final totalOz = totalGrams / _gramsPerOz;
  var lb = totalOz ~/ _ozPerLb;
  var oz = (totalOz - lb * _ozPerLb).round();
  if (oz == _ozPerLb) {
    lb++;
    oz = 0;
  }
  if (oz < 0 && lb > 0) {
    lb--;
    oz = _ozPerLb - 1;
  }
  return (lb: lb, oz: oz.clamp(0, _ozPerLb - 1));
}

double poundsDecimalToKg(double pounds) => pounds / 2.2046226218;

double mlToUsFlOzNum(int ml) => ml / _mlPerUsFlOz;

int usFlOzToMl(double flOz) => (flOz * _mlPerUsFlOz).round();

String trimFlOzDisplay(double flOz, {int decimals = 1}) {
  final s = flOz.toStringAsFixed(decimals);
  if (decimals == 0) return s;
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// Texto de peso a partir de kg guardados.
String formatWeightFromKg(
  double kg,
  MeasurementPrefs prefs,
  AppLocalizations l10n,
) {
  if (prefs.weight == WeightUnitMode.metric) {
    return l10n.formatWeightMetricKg(kg.toStringAsFixed(2));
  }
  final r = kgToLbOz(kg);
  return l10n.formatWeightLbOz(r.lb, r.oz);
}

/// Tendencia diaria (pendiente en g/día) con unidad según preferencia.
String formatWeightTrendGramsPerDay(
  double gramsPerDay,
  MeasurementPrefs prefs,
  AppLocalizations l10n,
) {
  final sign = gramsPerDay >= 0 ? '+' : '';
  final abs = gramsPerDay.abs();
  if (prefs.weight == WeightUnitMode.metric) {
    return l10n.homeWeightTrendGramsPerDay(sign, abs.toStringAsFixed(1));
  }
  final ozPerDay = abs / _gramsPerOz;
  return l10n.homeWeightTrendOuncesPerDay(sign, ozPerDay.toStringAsFixed(1));
}

/// Tendencia diaria para la tarjeta de peso (sin «/día»).
String formatWeightTrendCompact(
  double gramsPerDay,
  MeasurementPrefs prefs,
  AppLocalizations l10n,
) {
  final sign = gramsPerDay >= 0 ? '+' : '';
  final abs = gramsPerDay.abs();
  if (prefs.weight == WeightUnitMode.metric) {
    return l10n.weightTrendGramsCompact(sign, abs.toStringAsFixed(1));
  }
  final ozPerDay = abs / _gramsPerOz;
  return l10n.weightTrendOuncesCompact(sign, ozPerDay.toStringAsFixed(1));
}

/// Volumen a partir de ml guardados.
String formatVolumeFromMl(
  int ml,
  MeasurementPrefs prefs,
  AppLocalizations l10n,
) {
  if (prefs.liquid == LiquidUnitMode.milliliters) {
    return l10n.formatVolumeMlOnly(ml);
  }
  final fl = mlToUsFlOzNum(ml);
  return l10n.formatVolumeFlOzOnly(trimFlOzDisplay(fl));
}

/// Texto inicial del campo de edición de peso según unidad (kg o lb decimales).
String weightInputDisplayFromKg(double kg, MeasurementPrefs prefs) {
  if (prefs.weight == WeightUnitMode.metric) {
    return kg.toStringAsFixed(2);
  }
  final pounds = kg * 2.2046226218;
  return pounds.toStringAsFixed(2);
}

/// Etiqueta corta para resúmenes (p. ej. "120 ml" / "4 fl oz").
String formatVolumeShort(
  int ml,
  MeasurementPrefs prefs,
  AppLocalizations l10n,
) {
  if (prefs.liquid == LiquidUnitMode.milliliters) {
    return '$ml ${l10n.unitMlShort}';
  }
  return formatVolumeFromMl(ml, prefs, l10n);
}

/// Parsea entrada de peso del formulario → kg.
double? parseWeightInputToKg(String raw, MeasurementPrefs prefs) {
  final t = raw.trim().replaceAll(',', '.');
  final n = double.tryParse(t);
  if (n == null || n <= 0) return null;
  if (prefs.weight == WeightUnitMode.metric) {
    return n;
  }
  return poundsDecimalToKg(n);
}

/// Límite superior razonable en la unidad de entrada (validación).
double maxWeightInputForValidation(MeasurementPrefs prefs) {
  return prefs.weight == WeightUnitMode.metric ? 50 : 110;
}

/// Parsea volumen del formulario → ml.
int? parseVolumeInputToMl(String raw, MeasurementPrefs prefs) {
  final t = raw.trim().replaceAll(',', '.');
  final n = double.tryParse(t);
  if (n == null || n <= 0) return null;
  if (prefs.liquid == LiquidUnitMode.milliliters) {
    return n.round();
  }
  return usFlOzToMl(n);
}

/// Hint numérico para biberón según unidad.
String bottleVolumeHint(MeasurementPrefs prefs, AppLocalizations l10n) {
  return prefs.liquid == LiquidUnitMode.milliliters
      ? l10n.hintExampleMl
      : l10n.hintExampleFlOz;
}

/// Hint para registro de peso.
String weightEntryHint(MeasurementPrefs prefs, AppLocalizations l10n) {
  return prefs.weight == WeightUnitMode.metric
      ? l10n.hintExampleWeight
      : l10n.hintExampleWeightLb;
}

/// Etiqueta del campo de peso en formularios.
String weightFieldLabelForPrefs(
  MeasurementPrefs prefs,
  AppLocalizations l10n,
) {
  return prefs.weight == WeightUnitMode.metric
      ? l10n.weightFieldLabelMetric
      : l10n.weightFieldLabelImperial;
}

/// Texto del control deslizante de peso (segmentos).
String weightSegmentLabel(WeightUnitMode m, AppLocalizations l10n) =>
    m == WeightUnitMode.metric ? l10n.unitSegmentKg : l10n.unitSegmentLbOz;

String liquidSegmentLabel(LiquidUnitMode m, AppLocalizations l10n) =>
    m == LiquidUnitMode.milliliters ? l10n.unitSegmentMl : l10n.unitSegmentFlOz;
