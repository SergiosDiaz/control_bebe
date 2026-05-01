import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/isar_service.dart';
import '../models/baby_profile.dart';

/// Perfil del bebé; invalidar tras guardar en ajustes, onboarding o cambios de foto.
final babyProfileProvider = FutureProvider<BabyProfile?>((ref) {
  return IsarService.getBabyProfile();
});
