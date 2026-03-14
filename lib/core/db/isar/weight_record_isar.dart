import 'package:isar/isar.dart';

import '../../models/weight_record.dart';

part 'weight_record_isar.g.dart';

@collection
class WeightRecordIsar {
  Id id = Isar.autoIncrement;

  late double weightKg;

  late DateTime dateTime;

  WeightRecordIsar();

  WeightRecord toModel() => WeightRecord(
        id: id,
        weightKg: weightKg,
        dateTime: dateTime,
      );

  static WeightRecordIsar fromModel(WeightRecord m) {
    final isar = WeightRecordIsar()
      ..weightKg = m.weightKg
      ..dateTime = m.dateTime;
    if (m.id != null) isar.id = m.id!;
    return isar;
  }
}
