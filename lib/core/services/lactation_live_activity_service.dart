import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:live_activities/live_activities.dart';

import '../../l10n/app_localizations.dart';
import '../db/isar_service.dart';
import '../models/enums.dart';
import '../models/lactation_timer.dart';

/// Live Activity (iOS: Dynamic Island / pantalla de bloqueo) y notificación
/// persistente en Android con [Chronometer] nativo (segundo a segundo sin Dart).
class LactationLiveActivityService {
  LactationLiveActivityService._();

  static const String activityId = 'lactation_timer';

  /// Registrar el mismo App Group en Xcode (Runner + extensión) y en el portal Apple.
  static const String appGroupId = 'group.com.controlbebe.controlBebe.liveactivity';

  static final LiveActivities _plugin = LiveActivities();
  static bool _inited = false;

  static Future<void> init() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (_inited) return;
    try {
      await _plugin.init(
        appGroupId: appGroupId,
        urlScheme: 'mibebe',
        requestAndroidNotificationPermission: false,
      );
      _inited = true;
    } catch (e, st) {
      debugPrint('LactationLiveActivityService.init: $e\n$st');
    }
  }

  /// Reconcilia con el estado guardado (arranque en frío o pestaña lactancia).
  static Future<void> syncForActiveTimer() async {
    if (!_inited) return;
    try {
      final t = await IsarService.getActiveLactationTimer();
      if (t == null) {
        await stop();
        return;
      }
      final loc = WidgetsBinding.instance.platformDispatcher.locale;
      final l10n = lookupAppLocalizations(
        loc.languageCode == 'en' ? const Locale('en') : const Locale('es'),
      );
      final sideLabel =
          t.side == LactationSide.left ? l10n.feedingSideLeft : l10n.feedingSideRight;
      await _createOrUpdate(t, sideLabel: sideLabel, title: l10n.feedingBreast);
    } catch (e, st) {
      debugPrint('LactationLiveActivityService.syncForActiveTimer: $e\n$st');
    }
  }

  static Future<void> stop() async {
    if (!_inited) return;
    try {
      await _plugin.endActivity(activityId);
    } catch (e, st) {
      debugPrint('LactationLiveActivityService.stop: $e\n$st');
    }
  }

  static Future<void> _createOrUpdate(
    LactationTimer timer, {
    required String sideLabel,
    required String title,
  }) async {
    final supported = await _plugin.areActivitiesSupported();
    if (!supported) return;
    final enabled = await _plugin.areActivitiesEnabled();
    if (!enabled) return;

    final data = <String, dynamic>{
      'startedAtMs': timer.startedAt.millisecondsSinceEpoch.toDouble(),
      'sideLabel': sideLabel,
      'title': title,
    };

    // Cambia cada actualización: algunos caminos del plugin solo refrescan si el payload difiere.
    if (Platform.isIOS) {
      data['iosPresentationTick'] = DateTime.now().millisecondsSinceEpoch;
      data['sideIsLeft'] = timer.side == LactationSide.left;
    }

    if (Platform.isAndroid) {
      data['liveActivityChannelName'] = title;
      data['liveActivityChannelDescription'] = sideLabel;
    }

    await _plugin.createOrUpdateActivity(
      activityId,
      data,
      removeWhenAppIsKilled: false,
      iOSEnableRemoteUpdates: false,
    );
  }
}
