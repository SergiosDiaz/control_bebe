import 'package:control_bebe/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/enums.dart';

/// Gramos: máximo almacenado; admite decimales (p. ej. 0,47).
const double kMaxSolidFoodGrams = 2500;

/// Unidades: solo enteros 1…[kMaxSolidFoodUnits].
const int kMaxSolidFoodUnits = 99;

/// Formato al escribir en el campo según unidad e idioma (coma decimal en `es`).
String formatSolidQuantityForField(
  double? quantity,
  SolidQuantityUnit unit,
  String localeCode,
) {
  if (quantity == null || quantity.isNaN || !quantity.isFinite) return '';
  if (unit == SolidQuantityUnit.units) {
    return quantity.round().toString();
  }
  if ((quantity - quantity.round()).abs() < 1e-9) {
    return quantity.round().toString();
  }
  return NumberFormat.decimalPattern(localeCode).format(quantity);
}

/// Interpreta el texto del campo: en gramos acepta `,` o `.` como separador decimal (no ambos).
double? tryParseSolidQuantity(String raw, SolidQuantityUnit unit) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (unit == SolidQuantityUnit.units) {
    if (t.contains(',') || t.contains('.')) return null;
    final i = int.tryParse(t);
    if (i == null) return null;
    return i.toDouble();
  }
  final hasComma = t.contains(',');
  final hasDot = t.contains('.');
  if (hasComma && hasDot) return null;
  final normalized = hasComma ? t.replaceAll(',', '.') : t;
  return double.tryParse(normalized);
}

/// `null` si el valor es válido; si no, mensaje de error.
String? validateSolidQuantityInput(
  String? raw,
  SolidQuantityUnit unit,
  AppLocalizations l10n,
) {
  final t = raw?.trim() ?? '';
  if (t.isEmpty) return l10n.solidFoodValidatorQuantityEmpty;
  final v = tryParseSolidQuantity(t, unit);
  if (v == null || !v.isFinite) {
    return unit == SolidQuantityUnit.units
        ? l10n.solidFoodValidatorUnitsNoDecimals
        : l10n.solidFoodValidatorQuantityParse;
  }
  if (unit == SolidQuantityUnit.units) {
    if ((v - v.round()).abs() > 1e-9) {
      return l10n.solidFoodValidatorUnitsNoDecimals;
    }
    final n = v.round();
    if (n < 1 || n > kMaxSolidFoodUnits) {
      return l10n.solidFoodValidatorQuantityInvalid(kMaxSolidFoodUnits);
    }
    return null;
  }
  if (v <= 0) {
    return l10n.solidFoodValidatorGramsPositive;
  }
  if (v > kMaxSolidFoodGrams) {
    return l10n.solidFoodValidatorGramsRange(kMaxSolidFoodGrams);
  }
  return null;
}

/// Texto para historial / tarjetas (respeta locale en gramos).
String? solidFoodQuantityLabel(
  AppLocalizations l10n,
  double? quantity,
  SolidQuantityUnit? unit,
  String localeCode,
) {
  if (quantity == null || unit == null) return null;
  if (!quantity.isFinite) return null;
  if (unit == SolidQuantityUnit.units) {
    return '${quantity.round()} ${l10n.solidFoodUnitUnitsShort}';
  }
  final fmt = NumberFormat.decimalPattern(localeCode);
  return '${fmt.format(quantity)} ${l10n.solidFoodUnitGramShort}';
}

/// Solo dígitos y un separador decimal (`,` o `.`).
class SolidGramsQuantityInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final t = newValue.text;
    if (t.isEmpty) return newValue;
    if (RegExp(r'^[0-9]*[.,]?[0-9]*$').hasMatch(t)) return newValue;
    return oldValue;
  }
}

/// Solo dígitos (entero); sin vacío forzado aquí.
class SolidUnitsQuantityInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final t = newValue.text;
    if (t.isEmpty) return newValue;
    if (RegExp(r'^[0-9]+$').hasMatch(t)) return newValue;
    return oldValue;
  }
}
