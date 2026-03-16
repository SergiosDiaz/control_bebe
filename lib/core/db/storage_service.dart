// Punto de entrada del almacenamiento.
// Usa Firestore para todas las plataformas.
import 'storage_firebase.dart';
import 'storage_interface.dart';

StorageService _storage = StorageServiceFirebase();

StorageService get storage => _storage;
