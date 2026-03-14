import 'package:isar/isar.dart';

import '../../models/diaper_record.dart';
import '../../models/enums.dart';

part 'diaper_record_isar.g.dart';

@collection
class DiaperRecordIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late DiaperType type;

  late DateTime dateTime;

  DiaperRecordIsar();

  DiaperRecord toModel() => DiaperRecord(
        id: id,
        type: type,
        dateTime: dateTime,
      );

  static DiaperRecordIsar fromModel(DiaperRecord m) {
    final isar = DiaperRecordIsar()
      ..type = m.type
      ..dateTime = m.dateTime;
    if (m.id != null) isar.id = m.id!;
    return isar;
  }
}
