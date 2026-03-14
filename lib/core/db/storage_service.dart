// Punto de entrada del almacenamiento.
// Importa storage_io (Isar) en iOS/Android/Desktop, storage_web (SharedPreferences) en Web.
// Así evitamos compilar Isar para Web y los errores de "Integer literal can't be represented in JavaScript".
import 'storage_io.dart' if (dart.library.html) 'storage_web.dart' as storage_impl;

import 'storage_interface.dart';

StorageService _storage = storage_impl.createStorageService();

StorageService get storage => _storage;
