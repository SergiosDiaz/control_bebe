// Facade que delega al StorageService (Isar en IO, SharedPreferences en Web).
// Mantiene la API original para compatibilidad con el resto de la app.
import 'storage_interface.dart';
import 'storage_service.dart';

import '../models/baby_profile.dart';
import '../models/weight_record.dart';
import '../models/diaper_record.dart';
import '../models/feeding_record.dart';
import '../models/lactation_timer.dart';
import '../models/enums.dart';

class IsarService {
  static StorageService get _s => storage;

  static Future<void> initialize() async {
    await _s.initialize();
  }

  static Future<bool> needsOnboarding() => _s.needsOnboarding();
  static Future<void> completeOnboarding() => _s.completeOnboarding();

  static Future<BabyProfile?> getBabyProfile() => _s.getBabyProfile();
  static Future<void> saveBabyProfile(BabyProfile profile) => _s.saveBabyProfile(profile);

  static Stream<List<WeightRecord>> watchWeightRecords() => _s.watchWeightRecords();
  static Future<void> addWeightRecord(WeightRecord record) => _s.addWeightRecord(record);
  static Future<void> updateWeightRecord(WeightRecord record) => _s.updateWeightRecord(record);
  static Future<void> deleteWeightRecord(int id) => _s.deleteWeightRecord(id);

  static Stream<List<DiaperRecord>> watchDiaperRecords() => _s.watchDiaperRecords();
  static Future<void> addDiaperRecord(DiaperRecord record) => _s.addDiaperRecord(record);
  static Future<void> updateDiaperRecord(DiaperRecord record) => _s.updateDiaperRecord(record);
  static Future<void> deleteDiaperRecord(int id) => _s.deleteDiaperRecord(id);

  static Stream<List<FeedingRecord>> watchFeedingRecords() => _s.watchFeedingRecords();
  static Future<void> addFeedingRecord(FeedingRecord record) => _s.addFeedingRecord(record);
  static Future<void> updateFeedingRecord(FeedingRecord record) => _s.updateFeedingRecord(record);
  static Future<void> deleteFeedingRecord(int id) => _s.deleteFeedingRecord(id);

  static Future<LactationTimer?> getActiveLactationTimer() => _s.getActiveLactationTimer();
  static Future<void> startLactationTimer(LactationSide side) => _s.startLactationTimer(side);
  static Future<LactationTimer?> stopLactationTimer() => _s.stopLactationTimer();

  static Future<List<String>> getHomeCardOrder() => _s.getHomeCardOrder();
  static Future<void> setHomeCardOrder(List<String> order) => _s.setHomeCardOrder(order);

  static Future<List<WeightRecord>> getWeightRecords() => _s.getWeightRecords();
  static Future<List<FeedingRecord>> getFeedingRecordsToday() => _s.getFeedingRecordsToday();
  static Future<FeedingRecord?> getLastFeedingRecord() => _s.getLastFeedingRecord();
  static Future<List<DiaperRecord>> getDiaperRecordsToday() => _s.getDiaperRecordsToday();
  static Future<List<DiaperRecord>> getDiaperRecordsLast7Days() => _s.getDiaperRecordsLast7Days();
  static Future<DiaperRecord?> getLastDiaperRecord() => _s.getLastDiaperRecord();
}
