import 'package:isar/isar.dart';

import '../../models/lactation_timer.dart';
import '../../models/enums.dart';

part 'lactation_timer_isar.g.dart';

@collection
class LactationTimerIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late LactationSide side;

  late DateTime startedAt;

  LactationTimerIsar();

  LactationTimer toModel() => LactationTimer(
        id: id,
        side: side,
        startedAt: startedAt,
      );

  static LactationTimerIsar fromModel(LactationTimer m) {
    final isar = LactationTimerIsar()
      ..side = m.side
      ..startedAt = m.startedAt;
    if (m.id != null) isar.id = m.id!;
    return isar;
  }
}
