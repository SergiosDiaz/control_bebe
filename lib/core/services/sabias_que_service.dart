import 'sabias_que_tips_en.dart';
import 'sabias_que_tips_es.dart';

/// Servicio para el texto de "Consejo del día" según la edad del bebé.
/// Preparado para futuras fuentes (API, Firebase, etc.).
abstract class SabiasQueService {
  /// Consejo acorde a la edad del bebé. Devuelve null si no hay fecha de nacimiento.
  Future<String?> getFact({
    DateTime? birthDate,
    String languageCode = 'es',
  });
}

/// Un consejo distinto por cada día de vida (730 días = 2 años).
/// A partir del día 730 se rota desde el principio.
class SabiasQueServiceDefault implements SabiasQueService {
  static int _daysSinceBirth(DateTime birthDate) {
    final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day)
        .difference(birth)
        .inDays;
    return d < 0 ? 0 : d;
  }

  @override
  Future<String?> getFact({
    DateTime? birthDate,
    String languageCode = 'es',
  }) async {
    if (birthDate == null) return null;
    final day = _daysSinceBirth(birthDate);
    if (languageCode.toLowerCase().startsWith('en')) {
      return kSabiasQueTipsEn[day % kSabiasQueTipsEn.length];
    }
    return kSabiasQueTipsEs[day % kSabiasQueTipsEs.length];
  }
}
