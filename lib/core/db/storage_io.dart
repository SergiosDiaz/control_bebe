// ignore: avoid_web_libraries_in_flutter
// Este archivo SOLO se importa cuando dart.library.io existe (iOS, Android, Desktop)
// Nunca se compila para Web, evitando errores de Isar con JavaScript

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/baby_profile.dart';
import '../models/weight_record.dart';
import '../models/diaper_record.dart';
import '../models/feeding_record.dart';
import '../models/lactation_timer.dart';
import '../models/enums.dart';

import 'isar/baby_profile_isar.dart';
import 'isar/weight_record_isar.dart';
import 'isar/diaper_record_isar.dart';
import 'isar/feeding_record_isar.dart';
import 'isar/lactation_timer_isar.dart';
import 'isar/app_settings_isar.dart';

import 'storage_interface.dart';

class StorageServiceIo implements StorageService {
  Isar? _isar;

  Future<Isar> get _instance async {
    if (_isar != null) return _isar!;
    throw StateError('Storage no inicializado. Llama a initialize() primero.');
  }

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        BabyProfileIsarSchema,
        WeightRecordIsarSchema,
        DiaperRecordIsarSchema,
        FeedingRecordIsarSchema,
        LactationTimerIsarSchema,
        AppSettingsIsarSchema,
      ],
      directory: dir.path,
    );

    final settings = await _isar!.appSettingsIsars.get(1);
    if (settings == null) {
      await _isar!.writeTxn(() async {
        await _isar!.appSettingsIsars.put(AppSettingsIsar()..id = 1);
      });
    }
  }

  @override
  Future<bool> needsOnboarding() async {
    final isar = await _instance;
    final settings = await isar.appSettingsIsars.get(1);
    return settings == null || !settings.onboardingCompleted;
  }

  @override
  Future<void> completeOnboarding() async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      final settings = await isar.appSettingsIsars.get(1) ?? AppSettingsIsar();
      settings.onboardingCompleted = true;
      await isar.appSettingsIsars.put(settings);
    });
  }

  @override
  Future<BabyProfile?> getBabyProfile() async {
    final isar = await _instance;
    final p = await isar.babyProfileIsars.where().findFirst();
    return p?.toModel();
  }

  @override
  Future<void> saveBabyProfile(BabyProfile profile) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.babyProfileIsars.put(BabyProfileIsar.fromModel(profile));
    });
  }

  @override
  Stream<List<WeightRecord>> watchWeightRecords() {
    return _isar!.weightRecordIsars
        .where()
        .sortByDateTimeDesc()
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => e.toModel()).toList());
  }

  @override
  Future<void> addWeightRecord(WeightRecord record) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.weightRecordIsars.put(WeightRecordIsar.fromModel(record));
    });
  }

  @override
  Future<void> updateWeightRecord(WeightRecord record) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.weightRecordIsars.put(WeightRecordIsar.fromModel(record));
    });
  }

  @override
  Future<void> deleteWeightRecord(int id) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.weightRecordIsars.delete(id);
    });
  }

  @override
  Future<List<WeightRecord>> getWeightRecords() async {
    final isar = await _instance;
    final list = await isar.weightRecordIsars.where().sortByDateTimeDesc().findAll();
    return list.map((e) => e.toModel()).toList();
  }

  @override
  Stream<List<DiaperRecord>> watchDiaperRecords() {
    return _isar!.diaperRecordIsars
        .where()
        .sortByDateTimeDesc()
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => e.toModel()).toList());
  }

  @override
  Future<void> addDiaperRecord(DiaperRecord record) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.diaperRecordIsars.put(DiaperRecordIsar.fromModel(record));
    });
  }

  @override
  Future<void> updateDiaperRecord(DiaperRecord record) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.diaperRecordIsars.put(DiaperRecordIsar.fromModel(record));
    });
  }

  @override
  Future<void> deleteDiaperRecord(int id) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.diaperRecordIsars.delete(id);
    });
  }

  @override
  Future<List<DiaperRecord>> getDiaperRecordsToday() async {
    final isar = await _instance;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final list = await isar.diaperRecordIsars
        .filter()
        .dateTimeBetween(startOfDay, endOfDay)
        .sortByDateTimeDesc()
        .findAll();
    return list.map((e) => e.toModel()).toList();
  }

  @override
  Future<List<DiaperRecord>> getDiaperRecordsLast7Days() async {
    final isar = await _instance;
    final now = DateTime.now();
    final startOf7DaysAgo = now.subtract(const Duration(days: 7));
    final list = await isar.diaperRecordIsars
        .filter()
        .dateTimeGreaterThan(startOf7DaysAgo)
        .sortByDateTimeDesc()
        .findAll();
    return list.map((e) => e.toModel()).toList();
  }

  @override
  Future<DiaperRecord?> getLastDiaperRecord() async {
    final isar = await _instance;
    final r = await isar.diaperRecordIsars.where().sortByDateTimeDesc().findFirst();
    return r?.toModel();
  }

  @override
  Stream<List<FeedingRecord>> watchFeedingRecords() {
    return _isar!.feedingRecordIsars
        .where()
        .sortByDateTimeDesc()
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => e.toModel()).toList());
  }

  @override
  Future<void> addFeedingRecord(FeedingRecord record) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.feedingRecordIsars.put(FeedingRecordIsar.fromModel(record));
    });
  }

  @override
  Future<void> updateFeedingRecord(FeedingRecord record) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.feedingRecordIsars.put(FeedingRecordIsar.fromModel(record));
    });
  }

  @override
  Future<void> deleteFeedingRecord(int id) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.feedingRecordIsars.delete(id);
    });
  }

  @override
  Future<List<FeedingRecord>> getFeedingRecordsToday() async {
    final isar = await _instance;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final list = await isar.feedingRecordIsars
        .filter()
        .dateTimeBetween(startOfDay, endOfDay)
        .sortByDateTimeDesc()
        .findAll();
    return list.map((e) => e.toModel()).toList();
  }

  @override
  Future<FeedingRecord?> getLastFeedingRecord() async {
    final isar = await _instance;
    final r = await isar.feedingRecordIsars.where().sortByDateTimeDesc().findFirst();
    return r?.toModel();
  }

  @override
  Future<LactationTimer?> getActiveLactationTimer() async {
    final isar = await _instance;
    final t = await isar.lactationTimerIsars.where().findFirst();
    return t?.toModel();
  }

  @override
  Future<void> startLactationTimer(LactationSide side) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      await isar.lactationTimerIsars.clear();
      await isar.lactationTimerIsars.put(
        LactationTimerIsar.fromModel(LactationTimer(side: side, startedAt: DateTime.now())),
      );
    });
  }

  @override
  Future<LactationTimer?> stopLactationTimer() async {
    final isar = await _instance;
    LactationTimer? timer;
    await isar.writeTxn(() async {
      final t = await isar.lactationTimerIsars.where().findFirst();
      if (t != null) {
        timer = t.toModel();
        await isar.lactationTimerIsars.delete(t.id);
      }
    });
    return timer;
  }

  @override
  Future<List<String>> getHomeCardOrder() async {
    final isar = await _instance;
    final settings = await isar.appSettingsIsars.get(1);
    return settings?.homeCardOrder ?? ['weight', 'feeding', 'diapers'];
  }

  @override
  Future<void> setHomeCardOrder(List<String> order) async {
    final isar = await _instance;
    await isar.writeTxn(() async {
      final settings = await isar.appSettingsIsars.get(1) ?? AppSettingsIsar();
      settings.homeCardOrder = order;
      await isar.appSettingsIsars.put(settings);
    });
  }
}

/// Factory para import condicional
StorageService createStorageService() => StorageServiceIo();
