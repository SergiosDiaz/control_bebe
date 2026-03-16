import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Inicializa Firebase y configura Firestore con persistencia offline.
/// La persistencia permite que la app funcione sin cobertura (ej. en la consulta del pediatra).
class FirebaseService {
  static bool _initialized = false;
  static bool _available = false;

  /// true si Firebase se inicializó correctamente (auth funcionará)
  static bool get isAvailable => _available;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _configureFirestorePersistence();
      _available = true;
    } catch (e) {
      _available = false;
      // Sin config válida (ej. placeholders), la app arranca sin auth para desarrollo.
    }
    _initialized = true;
  }

  static void _configureFirestorePersistence() {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      // En Web la persistencia puede fallar; se ignora
    }
  }
}
