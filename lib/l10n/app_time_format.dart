import 'app_localizations.dart';

/// Formatea minutos usando textos localizados (p. ej. "45 min", "1h 40 min").
String formatMinutesLocalized(AppLocalizations l10n, int totalMinutes) {
  if (totalMinutes < 60) {
    return l10n.timeMinutesOnly(totalMinutes);
  }
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  if (m == 0) return l10n.timeHoursOnly(h);
  return l10n.timeHoursMinutes(h, m);
}

/// Formatea segundos con sufijos localizados.
String formatDurationSecondsLocalized(AppLocalizations l10n, int totalSeconds) {
  if (totalSeconds < 3600) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return l10n.durationMinutesSeconds(m, s);
  }
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  if (s == 0 && m == 0) return l10n.durationHoursOnly(h);
  if (s == 0) return l10n.durationHoursMinutes(h, m);
  return l10n.durationHoursMinutesSeconds(h, m, s);
}
