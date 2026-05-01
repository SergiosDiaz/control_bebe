// Facade que delega al StorageService (Firestore vía cola + prefs en disco).
// Mantiene la API original para compatibilidad con el resto de la app.
import 'dart:async';

import 'storage_interface.dart';
import 'storage_service.dart';

import '../services/app_review_scheduler.dart';

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

  static Stream<List<WeightRecord>> watchWeightRecordsSince(DateTime from) =>
      _s.watchWeightRecordsSince(from);

  static Stream<List<WeightRecord>> watchAllWeightRecords() =>
      _s.watchAllWeightRecords();

  static Future<bool> hasWeightRecordStrictlyBefore(DateTime exclusiveUpper) =>
      _s.hasWeightRecordStrictlyBefore(exclusiveUpper);
  static Future<void> addWeightRecord(WeightRecord record) async {
    await _s.addWeightRecord(record);
    unawaited(AppReviewScheduler.maybePrompt());
  }
  static Future<void> updateWeightRecord(WeightRecord record) => _s.updateWeightRecord(record);
  static Future<void> deleteWeightRecord(int id) => _s.deleteWeightRecord(id);

  static Stream<List<DiaperRecord>> watchDiaperRecordsSince(DateTime from) =>
      _s.watchDiaperRecordsSince(from);

  static Future<bool> hasDiaperRecordStrictlyBefore(DateTime exclusiveUpper) =>
      _s.hasDiaperRecordStrictlyBefore(exclusiveUpper);
  static Future<void> addDiaperRecord(DiaperRecord record) async {
    await _s.addDiaperRecord(record);
    unawaited(AppReviewScheduler.maybePrompt());
  }
  static Future<void> updateDiaperRecord(DiaperRecord record) => _s.updateDiaperRecord(record);
  static Future<void> deleteDiaperRecord(int id) => _s.deleteDiaperRecord(id);

  static Stream<List<FeedingRecord>> watchFeedingRecordsSince(DateTime from) =>
      _s.watchFeedingRecordsSince(from);

  static Future<bool> hasFeedingRecordStrictlyBefore(DateTime exclusiveUpper) =>
      _s.hasFeedingRecordStrictlyBefore(exclusiveUpper);
  static Future<void> addFeedingRecord(FeedingRecord record) async {
    await _s.addFeedingRecord(record);
    unawaited(AppReviewScheduler.maybePrompt());
  }
  static Future<void> updateFeedingRecord(FeedingRecord record) => _s.updateFeedingRecord(record);
  static Future<void> deleteFeedingRecord(int id) => _s.deleteFeedingRecord(id);

  static Future<LactationTimer?> getActiveLactationTimer() => _s.getActiveLactationTimer();
  static Future<void> startLactationTimer(LactationSide side) => _s.startLactationTimer(side);
  static Future<LactationTimer?> stopLactationTimer() => _s.stopLactationTimer();

  static Future<String?> getFamilyId() => _s.getFamilyId();
  static Future<void> joinFamily(String familyId) => _s.joinFamily(familyId);

  static Future<List<WeightRecord>> getWeightRecords() => _s.getWeightRecords();
  static Future<List<FeedingRecord>> getFeedingRecordsToday() => _s.getFeedingRecordsToday();
  static Future<FeedingRecord?> getLastFeedingRecord() => _s.getLastFeedingRecord();
  static Future<List<DiaperRecord>> getDiaperRecordsToday() => _s.getDiaperRecordsToday();
  static Future<List<DiaperRecord>> getDiaperRecordsLast7Days() => _s.getDiaperRecordsLast7Days();
  static Future<DiaperRecord?> getLastDiaperRecord() => _s.getLastDiaperRecord();
}
