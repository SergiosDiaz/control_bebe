/// Configuración de OAuth para Google y Apple Sign-In.
///
/// **Google Sign-In (Web):**
/// 1. Firebase Console > Authentication > Sign-in method > Google > habilitar
/// 2. Google Cloud Console > APIs & Services > Credentials
///    https://console.cloud.google.com/apis/credentials?project=baby-control-tracker
/// 3. Crear o copiar el "OAuth 2.0 Client ID" tipo "Web application"
/// 4. En "Authorized JavaScript origins" añade: http://localhost, http://127.0.0.1
/// 5. Pega el Client ID en web/index.html (meta tag) O aquí en googleWebClientId
///
/// **Apple Sign-In (Web):**
/// 1. Apple Developer > Identifiers > Service IDs > crear uno para web
/// 2. Configurar Return URLs y Domains
/// 3. Firebase Console > Authentication > Sign-in method > Apple > habilitar
class AuthConfig {
  /// Web Client ID para Google Sign-In.
  /// Null = usar meta tag de index.html
  /// Ejemplo: '933035228249-xxxxx.apps.googleusercontent.com'
  static const String? googleWebClientId = null;

  /// Client ID para Apple Sign-In en web (Service ID de Apple Developer)
  static const String? appleWebClientId = null;

  /// Redirect URI para Apple Sign-In en web
  static const String? appleWebRedirectUri = null;
}
