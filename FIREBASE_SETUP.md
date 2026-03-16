# Configuración de Firebase

Para que el login funcione, debes configurar Firebase en el proyecto.

## 1. Crear proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un proyecto o selecciona uno existente
3. Añade apps **Android** e **iOS** (y Web si usas web)

## 2. Configurar con FlutterFire CLI

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase (genera firebase_options.dart y añade archivos de config)
flutterfire configure
```

Esto creará:
- `lib/firebase_options.dart` (opciones de Firebase)
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## 3. Habilitar métodos de autenticación

En Firebase Console → Authentication → Sign-in method, habilita:

- **Correo electrónico/contraseña**
- **Google**
- **Apple** (requiere configuración en Apple Developer para iOS)

## 4. Configuración adicional para Apple Sign In

- En [Apple Developer](https://developer.apple.com/): crea un identificador de "Sign in with Apple"
- En Firebase Console → Authentication → Apple: añade el Service ID y la clave

## 5. Inicialización de Firebase

Si usas `flutterfire configure`, actualiza `main.dart` para usar las opciones:

```dart
import 'firebase_options.dart';

// En FirebaseService.initialize():
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Si no usas FlutterFire, `Firebase.initializeApp()` leerá la configuración de los archivos nativos (google-services.json, GoogleService-Info.plist).
