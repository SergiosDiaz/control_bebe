import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_review_service.dart';

/// Primera valoración a los 3 días y segunda a los 15, contados desde la
/// primera apertura de la app **con esta lógica** (p. ej. tras actualizar).
/// Se invoca tras guardar un registro nuevo (peso, pañal o alimentación) vía `IsarService`.
/// Como mucho se intenta una petición por llamada a `maybePrompt`.
class AppReviewScheduler {
  AppReviewScheduler._();

  static const _kAnchorMs = 'app_review_anchor_ms';
  static const _kDay3Shown = 'app_review_day3_shown';
  static const _kDay15Shown = 'app_review_day15_shown';

  static int _calendarDaysSinceAnchor(int anchorMs) {
    final anchor = DateTime.fromMillisecondsSinceEpoch(anchorMs);
    final start = DateTime(anchor.year, anchor.month, anchor.day);
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    return end.difference(start).inDays;
  }

  static Future<void> maybePrompt() async {
    if (kIsWeb || !AppReviewService.canRequestInAppReview) return;

    final sp = await SharedPreferences.getInstance();
    final anchorMs = sp.getInt(_kAnchorMs);
    if (anchorMs == null) {
      await sp.setInt(_kAnchorMs, DateTime.now().millisecondsSinceEpoch);
      return;
    }

    final days = _calendarDaysSinceAnchor(anchorMs);
    final day3Shown = sp.getBool(_kDay3Shown) ?? false;
    final day15Shown = sp.getBool(_kDay15Shown) ?? false;

    if (!day3Shown && days >= 3) {
      await AppReviewService.requestReview();
      await sp.setBool(_kDay3Shown, true);
      return;
    }
    if (!day15Shown && days >= 15) {
      await AppReviewService.requestReview();
      await sp.setBool(_kDay15Shown, true);
    }
  }
}
