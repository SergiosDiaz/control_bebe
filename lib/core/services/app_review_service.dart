import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:in_app_review/in_app_review.dart';

/// Valoración in-app (iOS: `AppStore.requestReview` / Android: Play In-App Review).
class AppReviewService {
  AppReviewService._();

  static final InAppReview _inAppReview = InAppReview.instance;

  static bool get _isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get _isMacos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Plataformas donde tiene sentido pedir reseña in-app.
  static bool get canRequestInAppReview =>
      _isIos || _isAndroid || _isMacos;

  /// Diálogo nativo de estrellas (cuota limitada por Apple / Google).
  static Future<void> requestReview() async {
    if (!canRequestInAppReview) return;
    await _inAppReview.requestReview();
  }
}
