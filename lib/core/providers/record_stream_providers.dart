import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/isar_service.dart';
import '../models/diaper_record.dart';
import '../models/feeding_record.dart';
import '../models/weight_record.dart';
import '../utils/history_calendar_window.dart';
import 'baby_profile_provider.dart';

// --- Ventana de días consultada en Firestore (ampliable al hacer scroll) ---

final feedingHistoryFirestoreDaysProvider = StateProvider<int>(
  (_) => kHistoryPaginationInitialDays,
);

final diaperHistoryFirestoreDaysProvider = StateProvider<int>(
  (_) => kHistoryPaginationInitialDays,
);

/// Cuántas pesadas recientes se muestran en el historial de Peso (ampliable al hacer scroll).
final weightHistoryVisibleLimitProvider = StateProvider<int>(
  (_) => kWeightHistoryInitialVisible,
);

/// Vuelve a 3 días de ventana (alimentación/pañales), reinicia el historial de peso a
/// [kWeightHistoryInitialVisible] pesadas, e invalida streams (p. ej. tras logout).
void resetRecordHistoryFirestoreDays(WidgetRef ref) {
  ref.read(feedingHistoryFirestoreDaysProvider.notifier).state =
      kHistoryPaginationInitialDays;
  ref.read(diaperHistoryFirestoreDaysProvider.notifier).state =
      kHistoryPaginationInitialDays;
  ref.read(weightHistoryVisibleLimitProvider.notifier).state =
      kWeightHistoryInitialVisible;
  ref.invalidate(hasOlderFeedingRecordsProvider);
  ref.invalidate(hasOlderDiaperRecordsProvider);
  ref.invalidate(weightRecordsForChartStreamProvider);
  ref.invalidate(babyProfileProvider);
}

/// Primer snapshot del stream de peso (misma fuente que la pestaña Peso / gráfica).
Future<List<WeightRecord>> waitForWeightChartRecords(WidgetRef ref) {
  return ref.read(weightRecordsForChartStreamProvider.future);
}

// --- Streams acotados por fecha (menos lecturas que la colección completa) ---

/// Serie completa: gráfica, resumen (último peso / tendencia) y percentiles.
final weightRecordsForChartStreamProvider = StreamProvider<List<WeightRecord>>((
  ref,
) {
  return IsarService.watchAllWeightRecords();
});

final diaperRecordsStreamProvider = StreamProvider<List<DiaperRecord>>((ref) {
  final days = ref.watch(diaperHistoryFirestoreDaysProvider);
  final start = historyWindowStartForDays(days);
  return IsarService.watchDiaperRecordsSince(start);
});

final feedingRecordsStreamProvider = StreamProvider<List<FeedingRecord>>((ref) {
  final days = ref.watch(feedingHistoryFirestoreDaysProvider);
  final start = historyWindowStartForDays(days);
  return IsarService.watchFeedingRecordsSince(start);
});

// --- ¿Hay datos anteriores a la ventana? (consulta barata limit 1) ---

final hasOlderFeedingRecordsProvider = FutureProvider<bool>((ref) async {
  final days = ref.watch(feedingHistoryFirestoreDaysProvider);
  final start = historyWindowStartForDays(days);
  return IsarService.hasFeedingRecordStrictlyBefore(start);
});

final hasOlderDiaperRecordsProvider = FutureProvider<bool>((ref) async {
  final days = ref.watch(diaperHistoryFirestoreDaysProvider);
  final start = historyWindowStartForDays(days);
  return IsarService.hasDiaperRecordStrictlyBefore(start);
});
