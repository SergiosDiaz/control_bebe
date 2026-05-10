import 'dart:math' as math;

/// Pesadas mostradas al abrir el historial en la pestaña Peso (luego +[kWeightHistoryPageIncrement]).
const int kWeightHistoryInitialVisible = 6;
const int kWeightHistoryPageIncrement = 6;

/// Días de calendario que se muestran al abrir la pestaña (incluye hoy).
const int kHistoryPaginationInitialDays = 3;

/// Cuántos días de calendario se añaden al llegar al final del scroll.
const int kHistoryPaginationStepDays = 3;

/// Tope de seguridad (evita bucles si hay pocos datos).
const int kHistoryPaginationMaxDays = 365 * 8;

/// Primer instante visible: 00:00 local del primer día de la ventana.
/// [calendarDaysInclusive] debe ser ≥ 1 (1 = solo hoy).
DateTime historyWindowStartForDays(int calendarDaysInclusive) {
  final capped = math.min(
    math.max(1, calendarDaysInclusive),
    kHistoryPaginationMaxDays,
  );
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  return todayStart.subtract(Duration(days: capped - 1));
}

/// Hay registros con fecha/hora estrictamente anterior al inicio de la ventana.
bool historyHasRecordsBefore<T>(
  Iterable<T> items,
  DateTime Function(T) dateOf,
  DateTime windowStart,
) {
  for (final x in items) {
    if (dateOf(x).isBefore(windowStart)) return true;
  }
  return false;
}

/// Solo registros con `dateTime >= windowStart`.
List<T> historyRecordsOnOrAfter<T>(
  Iterable<T> items,
  DateTime Function(T) dateOf,
  DateTime windowStart,
) {
  return items.where((x) => !dateOf(x).isBefore(windowStart)).toList();
}
