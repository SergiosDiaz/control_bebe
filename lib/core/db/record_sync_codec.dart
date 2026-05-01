import '../models/diaper_record.dart';
import '../models/enums.dart';
import '../models/feeding_record.dart';
import '../models/weight_record.dart';

/// Serialización JSON para la cola de sincronización (SharedPreferences).
class RecordSyncCodec {
  RecordSyncCodec._();

  static Map<String, dynamic> weightToJson(WeightRecord r) => {
        'id': r.id,
        'weightKg': r.weightKg,
        'dateTime': r.dateTime.toIso8601String(),
      };

  static WeightRecord weightFromJson(Map<String, dynamic> m) => WeightRecord(
        id: (m['id'] as num?)?.toInt(),
        weightKg: (m['weightKg'] as num).toDouble(),
        dateTime: DateTime.parse(m['dateTime'] as String),
        pendingRemoteSync: false,
      );

  static Map<String, dynamic> diaperToJson(DiaperRecord r) => {
        'id': r.id,
        'type': r.type.index,
        'dateTime': r.dateTime.toIso8601String(),
      };

  static DiaperRecord diaperFromJson(Map<String, dynamic> m) => DiaperRecord(
        id: (m['id'] as num?)?.toInt(),
        type: DiaperType.values[(m['type'] as num).toInt()],
        dateTime: DateTime.parse(m['dateTime'] as String),
        pendingRemoteSync: false,
      );

  static Map<String, dynamic> feedingToJson(FeedingRecord r) => {
        'id': r.id,
        'type': r.type.index,
        'dateTime': r.dateTime.toIso8601String(),
        'durationSeconds': r.durationSeconds,
        'amountMl': r.amountMl,
        'solidName': r.solidName,
        'solidQuantity': r.solidQuantity,
        'solidUnit': r.solidUnit?.index,
      };

  static FeedingRecord feedingFromJson(Map<String, dynamic> m) {
    final typeIdx = (m['type'] as num?)?.toInt() ?? 0;
    final type = typeIdx >= 0 && typeIdx < FeedingType.values.length
        ? FeedingType.values[typeIdx]
        : FeedingType.bottle;
    final suRaw = (m['solidUnit'] as num?)?.toInt();
    SolidQuantityUnit? solidUnit;
    if (suRaw != null &&
        suRaw >= 0 &&
        suRaw < SolidQuantityUnit.values.length) {
      solidUnit = SolidQuantityUnit.values[suRaw];
    }
    return FeedingRecord(
      id: (m['id'] as num?)?.toInt(),
      type: type,
      dateTime: DateTime.parse(m['dateTime'] as String),
      durationSeconds: (m['durationSeconds'] as num?)?.toInt(),
      amountMl: (m['amountMl'] as num?)?.toInt(),
      solidName: m['solidName'] as String?,
      solidQuantity: (m['solidQuantity'] as num?)?.toDouble(),
      solidUnit: solidUnit,
      pendingRemoteSync: false,
    );
  }
}
