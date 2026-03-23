import 'dart:async';
import 'dart:math' show pi;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../utils/baby_age_calendar.dart';

/// Confeti de cumplemes / cumpleaños: overlay compartido, límite de pulsaciones
/// manuales mientras sigue activo, y auto la primera vez que se abre la app ese día.
class MonthiversaryConfettiService {
  MonthiversaryConfettiService._();

  static const _prefKey = 'milestone_confetti_shown_calendar_date';

  static const List<Color> _colors = [
    AppTheme.palettePrimary,
    AppTheme.paletteSecondary,
    AppTheme.paletteTertiary,
    AppTheme.genderFemalePink,
    AppTheme.genderMaleBabyBlue,
  ];

  static OverlayEntry? _entry;
  static ConfettiController? _left;
  static ConfettiController? _right;
  /// Ráfagas disparadas por el usuario mientras el overlay sigue montado (máx. 2).
  static int _manualBurstsWhileActive = 0;

  static bool get _sessionAlive => _entry != null && _entry!.mounted;

  static String _dayKey(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
  }

  static bool _isMonthiversary(DateTime birth, DateTime now) {
    final age = BabyAgeCalendar.monthsAndDaysAt(birth, now);
    return age.months >= 1 && age.days == 0;
  }

  /// Mismo día y mes que el nacimiento, excluyendo el día del parto.
  static bool _isAnnualBirthday(DateTime birth, DateTime now) {
    final n = DateTime(now.year, now.month, now.day);
    final bd = DateTime(birth.year, birth.month, birth.day);
    if (n.month != bd.month || n.day != bd.day) return false;
    return n.isAfter(bd);
  }

  static bool isMilestoneDay(DateTime birthDate, DateTime at) =>
      _isMonthiversary(birthDate, at) || _isAnnualBirthday(birthDate, at);

  /// Primera apertura de la app en un día de hito (cumplemes o cumpleaños).
  static Future<void> tryPlayAutomatic(
    BuildContext context,
    DateTime? birthDate,
  ) async {
    if (birthDate == null || !context.mounted) return;
    final now = DateTime.now();
    if (!isMilestoneDay(birthDate, now)) return;
    if (_sessionAlive) return;
    if (Overlay.maybeOf(context, rootOverlay: true) == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _dayKey(now);
    if (prefs.getString(_prefKey) == key) return;

    await prefs.setString(_prefKey, key);
    if (!context.mounted) return;
    if (_sessionAlive) return;

    _manualBurstsWhileActive = 0;
    _launchSession(context);
  }

  /// Pulsación en la cinta (máx. 2 ráfagas manuales hasta que termine la sesión).
  static Future<void> playManual(BuildContext context) async {
    if (!context.mounted) return;

    if (_sessionAlive) {
      if (_manualBurstsWhileActive >= 2) return;
      _manualBurstsWhileActive++;
      _left!.play();
      _right!.play();
      HapticFeedback.lightImpact();
      return;
    }

    if (Overlay.maybeOf(context, rootOverlay: true) == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _dayKey(DateTime.now()));
    if (!context.mounted) return;
    if (_sessionAlive) return;

    HapticFeedback.lightImpact();
    _manualBurstsWhileActive = 1;
    _launchSession(context);
  }

  static void _launchSession(BuildContext context) {
    if (_entry != null && !_entry!.mounted) {
      _entry = null;
      _left = null;
      _right = null;
      _manualBurstsWhileActive = 0;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    const duration = Duration(milliseconds: 2600);
    var burstSeen = false;
    var leftActive = 0;
    var rightActive = 0;
    var removed = false;
    Timer? doneDebounce;
    Timer? safetyTimer;

    late final OverlayEntry entry;
    late final ConfettiController leftCtrl;
    late final ConfettiController rightCtrl;

    void removeOverlay() {
      if (removed) return;
      removed = true;
      doneDebounce?.cancel();
      safetyTimer?.cancel();
      if (entry.mounted) {
        entry.remove();
      }
      leftCtrl.dispose();
      rightCtrl.dispose();
      _entry = null;
      _left = null;
      _right = null;
      _manualBurstsWhileActive = 0;
    }

    void scheduleDoneCheck() {
      if (removed || !burstSeen) return;
      if (leftActive > 0 || rightActive > 0) return;
      doneDebounce?.cancel();
      doneDebounce = Timer(const Duration(milliseconds: 280), removeOverlay);
    }

    leftCtrl = ConfettiController(
      duration: duration,
      particleStatsCallback: (stats) {
        leftActive = stats.activeNumberOfParticles;
        if (stats.activeNumberOfParticles > 0) burstSeen = true;
        scheduleDoneCheck();
      },
    );
    rightCtrl = ConfettiController(
      duration: duration,
      particleStatsCallback: (stats) {
        rightActive = stats.activeNumberOfParticles;
        if (stats.activeNumberOfParticles > 0) burstSeen = true;
        scheduleDoneCheck();
      },
    );

    entry = OverlayEntry(
      builder: (ctx) {
        final screen = MediaQuery.sizeOf(ctx);
        final w = screen.width;
        final h = screen.height;
        final sideTop = h * 0.195;

        Widget layer({
          required ConfettiController controller,
          required double blastDirection,
          required Widget child,
        }) {
          return ConfettiWidget(
            confettiController: controller,
            canvas: screen,
            blastDirectionality: BlastDirectionality.directional,
            blastDirection: blastDirection,
            emissionFrequency: 0.09,
            numberOfParticles: 14,
            maxBlastForce: 32,
            minBlastForce: 14,
            gravity: 0.24,
            shouldLoop: false,
            colors: _colors,
            minimumSize: const Size(7, 5),
            maximumSize: const Size(13, 10),
            child: child,
          );
        }

        return IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: sideTop,
                    width: 44,
                    height: h * 0.52,
                    child: layer(
                      controller: leftCtrl,
                      blastDirection: -pi / 4,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: sideTop,
                    width: 44,
                    height: h * 0.52,
                    child: layer(
                      controller: rightCtrl,
                      blastDirection: 5 * pi / 4,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _entry = entry;
    _left = leftCtrl;
    _right = rightCtrl;

    overlay.insert(entry);
    safetyTimer = Timer(const Duration(seconds: 16), removeOverlay);
    leftCtrl.play();
    rightCtrl.play();
  }
}
