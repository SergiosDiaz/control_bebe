import 'package:isar/isar.dart';

import '../../models/feeding_record.dart';
import '../../models/enums.dart';

part 'feeding_record_isar.g.dart';

@collection
class FeedingRecordIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late FeedingType type;

  late DateTime dateTime;

  int? durationSeconds;

  int? amountMl;

  FeedingRecordIsar();

  FeedingRecord toModel() => FeedingRecord(
        id: id,
        type: type,
        dateTime: dateTime,
        durationSeconds: durationSeconds,
        amountMl: amountMl,
      );

  static FeedingRecordIsar fromModel(FeedingRecord m) {
    final isar = FeedingRecordIsar()
      ..type = m.type
      ..dateTime = m.dateTime
      ..durationSeconds = m.durationSeconds
      ..amountMl = m.amountMl;
    if (m.id != null) isar.id = m.id!;
    return isar;
  }
}
