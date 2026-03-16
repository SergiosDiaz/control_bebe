/// Servicio para obtener datos de "Sabías que...".
/// Preparado para futuras fuentes (API, Firebase, etc.).
abstract class SabiasQueService {
  /// Obtiene el texto del dato curioso a mostrar.
  /// Retorna null si no hay dato disponible.
  Future<String?> getFact();
}

/// Implementación por defecto con datos locales.
/// Sustituir por implementación que consuma API/Firebase cuando esté disponible.
class SabiasQueServiceDefault implements SabiasQueService {
  static const _defaultFacts = [
    'Nació con 300 huesos, que luego se fusionarán a 206.',
    'Los bebés pueden reconocer la voz de su madre desde el útero.',
    'Un recién nacido duerme entre 16 y 17 horas al día.',
    'Los bebés nacen sin rótulas; se desarrollan entre los 2 y 6 años.',
    'El llanto de cada bebé tiene un patrón único.',
  ];

  @override
  Future<String?> getFact() async {
    // Por ahora retorna un dato fijo. En el futuro: llamar a API, Firestore, etc.
    return _defaultFacts[DateTime.now().day % _defaultFacts.length];
  }
}
