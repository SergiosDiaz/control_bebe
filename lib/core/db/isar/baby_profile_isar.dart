import 'package:isar/isar.dart';

import '../../models/baby_profile.dart';

part 'baby_profile_isar.g.dart';

@collection
class BabyProfileIsar {
  Id id = Isar.autoIncrement;

  late String name;

  late bool isMale;

  late DateTime birthDate;

  DateTime? createdAt;

  BabyProfileIsar();

  BabyProfile toModel() => BabyProfile(
        id: id,
        name: name,
        isMale: isMale,
        birthDate: birthDate,
        createdAt: createdAt,
      );

  static BabyProfileIsar fromModel(BabyProfile m) {
    final isar = BabyProfileIsar()
      ..name = m.name
      ..isMale = m.isMale
      ..birthDate = m.birthDate
      ..createdAt = m.createdAt ?? DateTime.now();
    if (m.id != null) isar.id = m.id!;
    return isar;
  }
}
