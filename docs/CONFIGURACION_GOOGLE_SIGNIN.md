# Configuración de Google Sign-In por plataforma

## Resumen

| Plataforma | Estado | Requisitos |
|------------|--------|------------|
| **Web** | ❌ Requiere configuración | Meta tag con Web Client ID en index.html |
| **Android** | ✅ Suele funcionar | google-services.json + SHA-1 en Firebase |
| **iOS** | ⚠️ Requiere configuración | GoogleService-Info.plist + Info.plist |

---

## Web (Chrome, navegadores)

**Problema:** En web se necesita el Web Client ID explícitamente.

**Pasos:**
1. [Google Cloud Console](https://console.cloud.google.com/apis/credentials?project=baby-control-tracker) > Credentials
2. Crear o copiar el "OAuth 2.0 Client ID" tipo **Web application**
3. En "Authorized JavaScript origins" añadir: `http://localhost`, `http://127.0.0.1`
4. Copiar el Client ID (ej: `933035228249-xxxxx.apps.googleusercontent.com`)
5. En `web/index.html`, reemplazar el valor del meta tag `google-signin-client_id`

---

## Android

**Suele funcionar** si tienes Firebase configurado correctamente.

**Requisitos:**
1. Archivo `android/app/google-services.json` (descargar de Firebase Console)
2. En Firebase Console > Project Settings > Your apps > Android:
   - Añadir el SHA-1 de tu keystore (debug y release)
   - Para debug: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`

Si no tienes `google-services.json`, ejecuta:
```bash
flutterfire configure
```

---

## iOS

**Requiere configuración manual.**

**Opción A - FlutterFire (recomendado):**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Esto descarga `GoogleService-Info.plist` y `google-services.json`.

**Opción B - Manual:**
1. Firebase Console > Project Settings > Your apps > iOS
2. Descargar `GoogleService-Info.plist` y colocarlo en `ios/Runner/`
3. En `ios/Runner/Info.plist` reemplazar los placeholders:
   - `GIDClientID`: valor de `CLIENT_ID` en GoogleService-Info.plist
   - `CFBundleURLSchemes`: valor de `REVERSED_CLIENT_ID` (ej: `com.googleusercontent.apps.933035228249-xxxxx`)
