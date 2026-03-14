import 'package:isar/isar.dart';

import '../../models/app_settings.dart';

part 'app_settings_isar.g.dart';

@collection
class AppSettingsIsar {
  Id id = 1;

  bool onboardingCompleted = false;

  List<String> homeCardOrder = ['weight', 'feeding', 'diapers'];

  AppSettingsIsar();

  AppSettings toModel() => AppSettings(
        id: id,
        onboardingCompleted: onboardingCompleted,
        homeCardOrder: List.from(homeCardOrder),
      );

  static AppSettingsIsar fromModel(AppSettings m) {
    final isar = AppSettingsIsar()
      ..id = m.id
      ..onboardingCompleted = m.onboardingCompleted
      ..homeCardOrder = List.from(m.homeCardOrder);
    return isar;
  }
}
