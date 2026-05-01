import '../../l10n/app_localizations.dart';

/// Intervalos sugeridos entre tomas (minutos).
const List<int> kFeedingIntervalPresetMinutes = [
  60,
  90,
  120,
  150,
  180,
  210,
  240,
  300,
  360,
];

/// Valor por defecto si no hay dato guardado (3 h).
const int kDefaultFeedingIntervalMinutes = 180;

String feedingIntervalOptionLabel(AppLocalizations l10n, int minutes) {
  if (minutes < 60) {
    return '$minutes ${l10n.timeSuffixMinute}';
  }
  if (minutes % 60 == 0) {
    final h = minutes ~/ 60;
    return h == 1 ? l10n.feedingIntervalHoursOne : l10n.feedingIntervalHoursN(h);
  }
  final h = minutes ~/ 60;
  final min = minutes % 60;
  return l10n.feedingIntervalHoursMinutes(h, min);
}
