import 'dart:ui' show PlatformDispatcher;

import 'package:shared_preferences/shared_preferences.dart';

/// Unidad de visualización e introducción de peso (almacenamiento siempre en kg).
enum WeightUnitMode {
  /// Kilogramos (p. ej. 4,52 kg).
  metric,

  /// Libras y onzas (p. ej. 9 lb 5 oz).
  imperial,
}

/// Unidad para biberón / volumen (almacenamiento siempre en ml).
enum LiquidUnitMode {
  milliliters,
  fluidOuncesUs,
}

/// Preferencias de unidades persistidas localmente.
class MeasurementPrefs {
  static const _kWeight = 'measurement_weight_unit';
  static const _kLiquid = 'measurement_liquid_unit';

  final WeightUnitMode weight;
  final LiquidUnitMode liquid;

  const MeasurementPrefs({
    required this.weight,
    required this.liquid,
  });

  static MeasurementPrefs defaultsForLanguage(String languageCode) {
    final en = languageCode == 'en';
    return MeasurementPrefs(
      weight: en ? WeightUnitMode.imperial : WeightUnitMode.metric,
      liquid: en ? LiquidUnitMode.fluidOuncesUs : LiquidUnitMode.milliliters,
    );
  }

  static MeasurementPrefs defaultsForDispatcher() {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return defaultsForLanguage(code);
  }

  static Future<MeasurementPrefs> load() async {
    final sp = await SharedPreferences.getInstance();
    final def = defaultsForDispatcher();
    final wName = sp.getString(_kWeight);
    final lName = sp.getString(_kLiquid);
    WeightUnitMode w;
    LiquidUnitMode l;
    try {
      w = wName != null ? WeightUnitMode.values.byName(wName) : def.weight;
    } catch (_) {
      w = def.weight;
    }
    try {
      l = lName != null ? LiquidUnitMode.values.byName(lName) : def.liquid;
    } catch (_) {
      l = def.liquid;
    }
    return MeasurementPrefs(weight: w, liquid: l);
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kWeight, weight.name);
    await sp.setString(_kLiquid, liquid.name);
  }

  MeasurementPrefs copyWith({
    WeightUnitMode? weight,
    LiquidUnitMode? liquid,
  }) =>
      MeasurementPrefs(
        weight: weight ?? this.weight,
        liquid: liquid ?? this.liquid,
      );
}
