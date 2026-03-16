import '../models/baby_profile.dart';
import '../models/weight_record.dart';
import '../models/diaper_record.dart';
import '../models/feeding_record.dart';
import '../models/lactation_timer.dart';
import '../models/enums.dart';

/// Interfaz de almacenamiento - implementada por storage_firebase (Firestore) y storage_web (SharedPreferences como fallback)
abstract class StorageService {
  Future<void> initialize();

  Future<bool> needsOnboarding();
  Future<void> completeOnboarding();

  Future<BabyProfile?> getBabyProfile();
  Future<void> saveBabyProfile(BabyProfile profile);

  Stream<List<WeightRecord>> watchWeightRecords();
  Future<List<WeightRecord>> getWeightRecords();
  Future<void> addWeightRecord(WeightRecord record);
  Future<void> updateWeightRecord(WeightRecord record);
  Future<void> deleteWeightRecord(int id);

  Stream<List<DiaperRecord>> watchDiaperRecords();
  Future<List<DiaperRecord>> getDiaperRecordsToday();
  Future<List<DiaperRecord>> getDiaperRecordsLast7Days();
  Future<DiaperRecord?> getLastDiaperRecord();
  Future<void> addDiaperRecord(DiaperRecord record);
  Future<void> updateDiaperRecord(DiaperRecord record);
  Future<void> deleteDiaperRecord(int id);

  Stream<List<FeedingRecord>> watchFeedingRecords();
  Future<List<FeedingRecord>> getFeedingRecordsToday();
  Future<FeedingRecord?> getLastFeedingRecord();
  Future<void> addFeedingRecord(FeedingRecord record);
  Future<void> updateFeedingRecord(FeedingRecord record);
  Future<void> deleteFeedingRecord(int id);

  Future<LactationTimer?> getActiveLactationTimer();
  Future<void> startLactationTimer(LactationSide side);
  Future<LactationTimer?> stopLactationTimer();

  Future<List<String>> getHomeCardOrder();
  Future<void> setHomeCardOrder(List<String> order);

  /// ID de familia para compartir acceso (Firebase). Null si no aplica.
  Future<String?> getFamilyId();

  /// Une al usuario actual a una familia existente (escaneo QR). Firebase solo.
  Future<void> joinFamily(String familyId);
}
