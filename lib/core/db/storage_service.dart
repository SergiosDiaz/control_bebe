// Punto de entrada del almacenamiento.
// Firestore remoto + cola local con reintentos (fiabilidad de escritura).
import 'storage_firebase.dart';
import 'storage_interface.dart';
import 'storage_queued.dart';

final StorageServiceFirebase _firebaseBackend = StorageServiceFirebase();
final QueuedStorageService _queuedStorage = QueuedStorageService(_firebaseBackend);

StorageService get storage => _queuedStorage;
