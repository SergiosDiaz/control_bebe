import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:control_bebe/l10n/app_date_locale.dart';
import 'package:control_bebe/l10n/app_localizations.dart';
import 'package:control_bebe/l10n/app_time_format.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_app_title_bar.dart';
import '../../../core/utils/feeding_interval_labels.dart';
import '../../../core/utils/photo_picker.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/models/baby_profile.dart';
import '../../../core/models/diaper_record.dart';
import '../../../core/models/feeding_record.dart';
import '../../../core/models/weight_record.dart';
import '../../settings/views/settings_page.dart';
import '../../../core/models/enums.dart';
import '../../../core/utils/baby_age_calendar.dart';
import '../../../core/utils/weight_daily_trend.dart';
import '../../../core/services/monthiversary_confetti_service.dart';
import '../../../core/services/sabias_que_service.dart';
import '../../../core/providers/baby_profile_provider.dart';
import '../../../core/providers/measurement_prefs_provider.dart';
import '../../../core/providers/record_stream_providers.dart';
import '../../../core/models/measurement_units.dart';
import '../../../core/utils/measurement_display.dart';
import '../../../core/utils/solid_food_display.dart';
import '../../../core/services/next_feeding_notification_service.dart';

class HomeView extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final void Function(int index)? onNavigateToTab;
  final VoidCallback? onTitleTap;
  /// Cuando es true, la pestaña Inicio está visible (para recargar datos al volver de otras pestañas).
  final bool isActiveTab;

  const HomeView({
    super.key,
    required this.scrollController,
    this.onNavigateToTab,
    this.onTitleTap,
    this.isActiveTab = true,
  });

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  BabyProfile? _cachedBaby;
  /// Perfil mostrado en la cabecera tras cambiar solo la foto (sin recargar todo el home).
  BabyProfile? _babyProfileOverride;
  late Future<Map<String, dynamic>> _homeDataFuture;
  final _sabiasQueService = SabiasQueServiceDefault();

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
    unawaited(_scheduleAutoMilestoneConfetti(_homeDataFuture));
  }

  @override
  void didUpdateWidget(HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActiveTab && !oldWidget.isActiveTab) {
      setState(() {
        _homeDataFuture = _loadHomeData();
      });
      unawaited(_scheduleAutoMilestoneConfetti(_homeDataFuture));
    }
  }

  Future<void> _scheduleAutoMilestoneConfetti(
    Future<Map<String, dynamic>> future,
  ) async {
    final data = await future;
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final baby = data['baby'] as BabyProfile?;
      MonthiversaryConfettiService.tryPlayAutomatic(context, baby?.birthDate);
    });
  }

  Future<void> _handlePhotoTap(BabyProfile? baby) async {
    if (baby == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.homeConfigureProfileFirst),
          ),
        );
      }
      return;
    }

    final hasPhoto = baby.photoUrl != null && baby.photoUrl!.isNotEmpty;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: AppTheme.safeBottomPadding(sheetCtx),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(AppLocalizations.of(sheetCtx)!.homePickPhoto),
                  onTap: () => Navigator.pop(sheetCtx, 'pick'),
                ),
                if (hasPhoto)
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: Theme.of(sheetCtx).colorScheme.error),
                    title: Text(
                      AppLocalizations.of(sheetCtx)!.homeRemovePhoto,
                      style: TextStyle(color: Theme.of(sheetCtx).colorScheme.error),
                    ),
                    onTap: () => Navigator.pop(sheetCtx, 'remove'),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || choice == null) return;

    if (choice == 'remove') {
      try {
        final updated = baby.copyWith(setPhotoUrl: true, photoUrl: null);
        await IsarService.saveBabyProfile(updated);
        if (mounted) {
          ref.invalidate(babyProfileProvider);
          setState(() {
            _babyProfileOverride = updated;
            _cachedBaby = updated;
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.homePhotoRemoved),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.homePhotoRemoveError(e.toString()),
              ),
            ),
          );
        }
      }
      return;
    }

    if (choice != 'pick') return;

    try {
      final photoUrl = await pickAndProcessBabyPhoto();
      if (photoUrl == null || !mounted) return;
      final updated = baby.copyWith(photoUrl: photoUrl);
      await IsarService.saveBabyProfile(updated);
      if (mounted) {
        ref.invalidate(babyProfileProvider);
        setState(() {
          _babyProfileOverride = updated;
          _cachedBaby = updated;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.homePhotoUpdated),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.homePhotoUploadError(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _navigateTo(String screen) {
    if (widget.onNavigateToTab != null) {
      switch (screen) {
        case 'weight':
          widget.onNavigateToTab!(3);
          break;
        case 'feeding':
          widget.onNavigateToTab!(2);
          break;
        case 'diapers':
          widget.onNavigateToTab!(1);
          break;
      }
    }
  }

  Future<void> _openSettings(
    BuildContext context, {
    BabyProfile? currentBaby,
  }) async {
    BabyProfile? initial = currentBaby ?? _cachedBaby;
    initial ??= await ref.read(babyProfileProvider.future);
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          initialBaby: initial,
          onProfileSaved: (profile) {
            if (!mounted) return;
            ref.invalidate(babyProfileProvider);
            setState(() {
              _cachedBaby = profile;
              _babyProfileOverride = null;
              _homeDataFuture = _loadHomeData();
            });
          },
        ),
      ),
    );
    if (mounted) {
      resetRecordHistoryFirestoreDays(ref);
      ref.invalidate(weightRecordsForChartStreamProvider);
      ref.invalidate(diaperRecordsStreamProvider);
      ref.invalidate(feedingRecordsStreamProvider);
      await NextFeedingNotificationService.syncFromStorage();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _homeDataFuture,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final babyFromFuture =
                      data != null ? data['baby'] as BabyProfile? : null;
                  final baby = _babyProfileOverride ?? babyFromFuture;
                  return CustomScrollView(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          AppTheme.screenEdgePadding +
                              AppTheme.cardOuterMargin,
                          MainAppTitleBar.totalHeight +
                              AppTheme.contentPaddingTopAfterTitleBar +
                              AppTheme.cardOuterMargin,
                          AppTheme.screenEdgePadding +
                              AppTheme.cardOuterMargin,
                          100 + AppTheme.extraBottomSpacing,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (!snapshot.hasData) ...[
                              const _HomeCardsSkeleton(),
                            ] else ...[
                              _StaggeredFadeSlideIn(
                                delay: Duration.zero,
                                child: _ProfileSummaryCard(
                                  baby: baby,
                                  weightKg: (data!['weight'] as _WeightData)
                                      .currentKg,
                                  onPhotoTap: () => _handlePhotoTap(baby),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _StaggeredFadeSlideIn(
                                delay: const Duration(milliseconds: 60),
                                child: _ResumenDeHoyBlock(
                                  weight: data['weight'] as _WeightData,
                                  feeding: data['feeding'] as _FeedingData,
                                  diapers: data['diapers'] as _DiapersData,
                                  onTapWeight: () => _navigateTo('weight'),
                                  onTapFeeding: () => _navigateTo('feeding'),
                                  onTapDiapers: () => _navigateTo('diapers'),
                                  liveFeedingClock: widget.isActiveTab,
                                  dateFormatCode:
                                      data['dateFmtCode'] as String? ?? 'es',
                                ),
                              ),
                              const SizedBox(height: 12),
                              _StaggeredFadeSlideIn(
                                delay: const Duration(milliseconds: 120),
                                child: _ConsejoDelDiaCard(
                                  factText: data['sabiasQue'] as String?,
                                  missingBirthDate:
                                      data['sabiasQueMissingBirth'] as bool? ??
                                          false,
                                ),
                              ),
                            ],
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MainAppTitleBar(
                onTitleTap: widget.onTitleTap,
                onSettingsTap: () => _openSettings(context,
                    currentBaby: _babyProfileOverride),
              ),
            ),
            const TitleBarScrollFade(),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadHomeData() async {
    final locale = Localizations.localeOf(context);
    final l10n = lookupAppLocalizations(locale);
    final dateFmtCode = dateFormatLanguageCode(context);

    final cachedBaby = _cachedBaby;
    _cachedBaby = null;
    final baby =
        cachedBaby ?? await ref.read(babyProfileProvider.future);
    final birth = baby?.birthDate;
    final sabiasFuture = birth == null
        ? Future<String?>.value(null)
        : _sabiasQueService.getFact(
            birthDate: birth,
            languageCode: locale.languageCode,
          );
    final results = await Future.wait([
      waitForWeightChartRecords(ref),
      IsarService.getLastFeedingRecord(),
      IsarService.getDiaperRecordsToday(),
      IsarService.getLastDiaperRecord(),
      sabiasFuture,
    ]);
    final weightRecords = results[0] as List<WeightRecord>;
    final lastFeeding = results[1] as FeedingRecord?;
    final diapersToday = results[2] as List<DiaperRecord>;
    final lastDiaperRecord = results[3] as DiaperRecord?;
    final sabiasQue = results[4] as String?;

    final lastWeight = weightRecords.isNotEmpty ? weightRecords.first : null;

    final dailyTrendGPerDay =
        dailyWeightTrendLinearRegressionGramsPerDay(weightRecords);

    String? lastFeedingDetail;
    int? lastBottleMl;
    DateTime? lastFeedingAt;
    if (lastFeeding != null) {
      lastFeedingAt = lastFeeding.dateTime;
      switch (lastFeeding.type) {
        case FeedingType.leftBreast:
          final sec = lastFeeding.durationSeconds ?? 0;
          final min = (sec / 60).round();
          lastFeedingDetail = sec > 0
              ? l10n.lastFeedDetailLeftMinutes(min)
              : l10n.lastFeedDetailLeft;
          break;
        case FeedingType.rightBreast:
          final sec = lastFeeding.durationSeconds ?? 0;
          final min = (sec / 60).round();
          lastFeedingDetail = sec > 0
              ? l10n.lastFeedDetailRightMinutes(min)
              : l10n.lastFeedDetailRight;
          break;
        case FeedingType.bottle:
          lastBottleMl = lastFeeding.amountMl ?? 0;
          break;
        case FeedingType.solidFood:
          final sq = lastFeeding.solidQuantity;
          final su = lastFeeding.solidUnit;
          final sn = lastFeeding.solidName?.trim();
          if (sq != null && su != null) {
            final amt = solidFoodQuantityLabel(
              l10n,
              sq,
              su,
              dateFmtCode,
            );
            if (amt != null) {
              lastFeedingDetail =
                  sn != null && sn.isNotEmpty ? '$sn · $amt' : amt;
            } else {
              lastFeedingDetail = l10n.lastFeedDetailSolid;
            }
          } else {
            lastFeedingDetail = l10n.lastFeedDetailSolid;
          }
          break;
      }
    }

    var wetCount = 0;
    var dirtyCount = 0;
    for (final d in diapersToday) {
      switch (d.type) {
        case DiaperType.wet:
          wetCount++;
          break;
        case DiaperType.dirty:
          dirtyCount++;
          break;
        case DiaperType.both:
          wetCount++;
          dirtyCount++;
          break;
      }
    }

    // Un "cambio" = un registro desde 00:00 local (como el bloque "Hoy" en pañales).
    // No sumar moj+suc: un tipo "ambos" es un solo cambio.
    final totalToday = diapersToday.length;

    return {
      'baby': baby,
      'sabiasQue': sabiasQue,
      'sabiasQueMissingBirth': birth == null,
      'dateFmtCode': dateFmtCode,
      'weight': _WeightData(
        currentKg: lastWeight?.weightKg,
        dailyTrendGramsPerDay: dailyTrendGPerDay,
        lastRecordedAt: lastWeight?.dateTime,
      ),
      'feeding': _FeedingData(
        lastFeedingDetail: lastFeedingDetail,
        lastBottleMl: lastBottleMl,
        lastFeedingAt: lastFeedingAt,
        expectedFeedingIntervalMinutes:
            baby?.expectedFeedingIntervalMinutes ?? kDefaultFeedingIntervalMinutes,
      ),
      'diapers': _DiapersData(
        wetCount: wetCount,
        dirtyCount: dirtyCount,
        totalToday: totalToday,
        lastRecordedAt: lastDiaperRecord?.dateTime,
      ),
    };
  }
}

// --- Animación de entrada escalonada (fade + slide) ---

/// Envuelve un hijo con una entrada *fade-in* + *slide* hacia arriba.
/// El parámetro [delay] permite escalonar la animación entre tarjetas.
/// Mantiene el hijo "fuera de pantalla" (opacity 0 + translación) durante
/// el delay y luego lo trae hasta su posición con [Curves.easeOutCubic].
class _StaggeredFadeSlideIn extends StatelessWidget {
  static const Duration _animDuration = Duration(milliseconds: 420);
  static const double _translateY = 18;

  final Widget child;
  final Duration delay;

  const _StaggeredFadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final totalMs = delay.inMilliseconds + _animDuration.inMilliseconds;
    final intervalStart =
        totalMs == 0 ? 0.0 : delay.inMilliseconds / totalMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(intervalStart, 1.0, curve: Curves.easeOutCubic),
      builder: (context, t, c) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * _translateY),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

// --- Tarjeta perfil central ---

class _MonthiversaryBanner extends StatelessWidget {
  final int months;

  const _MonthiversaryBanner({required this.months});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final msg = months == 1
        ? l10n.monthiversaryOne
        : l10n.monthiversaryN(months);
    return Semantics(
      button: true,
      label: msg,
      hint: l10n.monthiversarySemanticsHint,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => unawaited(
                MonthiversaryConfettiService.playManual(context),
              ),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Color.lerp(AppTheme.paletteTertiary, Colors.white, 0.72)!,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Color.lerp(
                  AppTheme.paletteTertiary,
                  AppTheme.paletteSecondary,
                  0.5,
                )!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.paletteTertiary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 20,
                  color: AppTheme.palettePrimary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textHeading,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          height: 1.2,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar con anillo degradado (azul o rosa según sexo), halo blanco y sombra.
class _ProfileGradientAvatarRing extends StatelessWidget {
  /// Diámetro exterior del anillo (degradado + halo).
  static const double outerDiameter = 108;
  static const double _ringThickness = 4;
  static const double _whiteInset = 2;

  final bool isMale;
  final Widget child;

  const _ProfileGradientAvatarRing({
    required this.isMale,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        isMale ? AppTheme.palettePrimary : AppTheme.genderFemalePink;
    final topTint = Color.lerp(Colors.white, accent, 0.42)!;
    return SizedBox(
      width: outerDiameter,
      height: outerDiameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topTint, accent],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.28),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(_ringThickness),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(_whiteInset),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    child,
                    // Sombra interior suave en la parte superior del recorte
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withValues(alpha: 0.07),
                              Colors.black.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Interior del avatar vacío (solo fondo + cara Material).
class _BabyPhotoPlaceholderInner extends StatelessWidget {
  final bool isMale;

  const _BabyPhotoPlaceholderInner({required this.isMale});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F4F5),
      child: Center(
        child: Icon(
          isMale ? Icons.face : Icons.face_3,
          size: 40,
          color: isMale ? AppTheme.palettePrimary : AppTheme.genderFemalePink,
        ),
      ),
    );
  }
}

/// Botón “+” que sobresale del círculo, en esquina inferior derecha.
class _AddPhotoBadgeOutside extends StatelessWidget {
  final Color accentColor;

  const _AddPhotoBadgeOutside({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: accentColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.add, size: 15, color: Colors.white),
    );
  }
}

/// Placeholder completo: anillo + cara; el “+” va fuera del recorte oval (sobrepuesto al redondel).
class _AvatarPlaceholderWithOutsideBadge extends StatelessWidget {
  final bool isMale;

  const _AvatarPlaceholderWithOutsideBadge({required this.isMale});

  @override
  Widget build(BuildContext context) {
    final accent =
        isMale ? AppTheme.palettePrimary : AppTheme.genderFemalePink;
    return SizedBox(
      width: _ProfileGradientAvatarRing.outerDiameter,
      height: _ProfileGradientAvatarRing.outerDiameter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _ProfileGradientAvatarRing(
            isMale: isMale,
            child: _BabyPhotoPlaceholderInner(isMale: isMale),
          ),
          // Esquina inferior derecha del avatar, más pegado al anillo que sobresaliendo.
          Positioned(
            right: 4,
            bottom: 4,
            child: _AddPhotoBadgeOutside(accentColor: accent),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends ConsumerWidget {
  final BabyProfile? baby;
  final double? weightKg;
  final VoidCallback onPhotoTap;

  const _ProfileSummaryCard({
    required this.baby,
    required this.weightKg,
    required this.onPhotoTap,
  });

  static String _formatAgeLine(
    BuildContext context,
    ({int months, int days}) age,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (age.months == 1 && age.days == 1) {
      return l10n.babyAgeMonthsOneDaysOne;
    }
    if (age.months == 1) {
      return l10n.babyAgeMonthsOneDaysN(age.days);
    }
    if (age.days == 1) {
      return l10n.babyAgeMonthsNDaysOne(age.months);
    }
    return l10n.babyAgeMonthsNDaysN(age.days, age.months);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.watch(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final isMale = baby?.isMale ?? true;
    final name = baby?.name ?? l10n.profileDefaultBabyName;
    final now = DateTime.now();
    final ({int months, int days})? age = baby != null
        ? BabyAgeCalendar.monthsAndDaysAt(baby!.birthDate, now)
        : null;
    final monthiversary = age != null && age.months >= 1 && age.days == 0;

    return Material(
      color: AppTheme.cardBackground,
      elevation: AppTheme.cardElevation,
      shadowColor: Colors.black12,
      shape: AppTheme.homeCardShapeRounded,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          children: [
            GestureDetector(
              onTap: onPhotoTap,
              child: baby?.photoUrl != null && baby!.photoUrl!.isNotEmpty
                  ? _ProfileGradientAvatarRing(
                      isMale: isMale,
                      child: _LargeAvatarImage(
                        photoUrl: baby!.photoUrl!,
                        isMale: isMale,
                      ),
                    )
                  : _AvatarPlaceholderWithOutsideBadge(isMale: isMale),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Misma anchura que gap + icono: el nombre queda centrado en la tarjeta sin contar el símbolo.
                const SizedBox(width: 20),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    height: 1.15,
                  ),
                ),
                const SizedBox(width: 2),
                Transform.translate(
                  offset: const Offset(0, -3),
                  child: Icon(
                    isMale ? Icons.male : Icons.female,
                    color: isMale
                        ? AppTheme.genderMaleBabyBlue
                        : AppTheme.genderFemalePink,
                    size: 19,
                  ),
                ),
              ],
            ),
            if (age != null) ...[
              const SizedBox(height: 4),
              if (monthiversary)
                Center(child: _MonthiversaryBanner(months: age.months))
              else
                Text(
                  _formatAgeLine(context, age),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textLight,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
            const SizedBox(height: 12),
            Center(
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weightKg != null
                              ? formatWeightFromKg(
                                  weightKg!,
                                  prefs,
                                  l10n,
                                )
                              : '—',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.palettePrimary,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.profileWeightLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.textLight,
                                letterSpacing: 1.25,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppTheme.fieldBorder,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          baby?.heightCm != null
                              ? '${baby!.heightCm == baby!.heightCm!.roundToDouble() ? baby!.heightCm!.round() : baby!.heightCm} cm'
                              : '—',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.palettePrimary,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.profileHeightLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.textLight,
                                letterSpacing: 1.25,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LargeAvatarImage extends StatelessWidget {
  final String photoUrl;
  final bool isMale;

  const _LargeAvatarImage({required this.photoUrl, required this.isMale});

  @override
  Widget build(BuildContext context) {
    final placeholderColor =
        isMale ? AppTheme.textLight : AppTheme.genderFemalePink;
    if (photoUrl.startsWith('data:')) {
      try {
        final base64 = photoUrl.split(',').last;
        final bytes = base64Decode(base64);
        return Image.memory(
          bytes,
          key: ValueKey(photoUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => Icon(
            isMale ? Icons.face : Icons.face_3,
            color: placeholderColor,
            size: 40,
          ),
        );
      } catch (_) {
        return Icon(
          isMale ? Icons.face : Icons.face_3,
          color: placeholderColor,
          size: 40,
        );
      }
    }
    return Image.network(
      photoUrl,
      key: ValueKey(photoUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => Icon(
        isMale ? Icons.face : Icons.face_3,
        color: placeholderColor,
        size: 40,
      ),
    );
  }
}

// --- Resumen ---

class _ResumenDeHoyBlock extends StatelessWidget {
  final _WeightData weight;
  final _FeedingData feeding;
  final _DiapersData diapers;
  final VoidCallback onTapWeight;
  final VoidCallback onTapFeeding;
  final VoidCallback onTapDiapers;
  final bool liveFeedingClock;
  final String dateFormatCode;

  const _ResumenDeHoyBlock({
    required this.weight,
    required this.feeding,
    required this.diapers,
    required this.onTapWeight,
    required this.onTapFeeding,
    required this.onTapDiapers,
    this.liveFeedingClock = true,
    required this.dateFormatCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateLabel =
        DateFormat('d MMM', dateFormatCode).format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              l10n.homeSummaryTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.softPrimaryFill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                dateLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.palettePrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _UltimaTomaCard(
          data: feeding,
          onTap: onTapFeeding,
          liveClockActive: liveFeedingClock,
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _PesoResumenCard(
                  data: weight,
                  onTap: onTapWeight,
                  dateFormatCode: dateFormatCode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PanalesResumenCard(
                  data: diapers,
                  onTap: onTapDiapers,
                  dateFormatCode: dateFormatCode,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UltimaTomaCard extends ConsumerStatefulWidget {
  final _FeedingData data;
  final VoidCallback onTap;
  final bool liveClockActive;

  const _UltimaTomaCard({
    required this.data,
    required this.onTap,
    this.liveClockActive = true,
  });

  @override
  ConsumerState<_UltimaTomaCard> createState() => _UltimaTomaCardState();
}

class _UltimaTomaCardState extends ConsumerState<_UltimaTomaCard>
    with WidgetsBindingObserver {
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _UltimaTomaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liveClockActive != widget.liveClockActive ||
        oldWidget.data.lastFeedingAt != widget.data.lastFeedingAt ||
        oldWidget.data.lastBottleMl != widget.data.lastBottleMl ||
        oldWidget.data.expectedFeedingIntervalMinutes !=
            widget.data.expectedFeedingIntervalMinutes) {
      _syncTimer();
      if (mounted) setState(() {});
    }
  }

  void _syncTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
    if (!widget.liveClockActive) return;
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  String _nextFeedingHint(
    AppLocalizations l10n,
    DateTime? lastAt,
    int intervalMinutes,
  ) {
    if (lastAt == null) return '';
    final next = lastAt.add(Duration(minutes: intervalMinutes));
    final diff = next.difference(DateTime.now());
    if (diff.inMinutes <= 0) return l10n.homeNextFeedSoon;
    return l10n.homeNextFeedIn(
      formatMinutesLocalized(l10n, diff.inMinutes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.data;
    final prefs = ref.watch(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final hasLast = data.lastFeedingAt != null &&
        (data.lastFeedingDetail != null || data.lastBottleMl != null);
    final detailLine = data.lastBottleMl != null
        ? l10n.lastFeedDetailBottleVolume(
            formatVolumeFromMl(data.lastBottleMl!, prefs, l10n),
          )
        : data.lastFeedingDetail;
    final minutesAgo = data.lastFeedingAt != null
        ? DateTime.now().difference(data.lastFeedingAt!).inMinutes
        : null;
    final subHint = _nextFeedingHint(
      l10n,
      data.lastFeedingAt,
      data.expectedFeedingIntervalMinutes,
    );

    return Material(
      color: AppTheme.palettePrimary,
      elevation: AppTheme.cardElevation,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: hasLast
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeLastFeedLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.homeLastFeedAgo(
                              formatMinutesLocalized(l10n, minutesAgo!),
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detailLine!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          if (subHint.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subHint,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ],
                      )
                    : Text(
                        l10n.homeNoFeedingsYet,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.schedule_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PesoResumenCard extends ConsumerWidget {
  final _WeightData data;
  final VoidCallback onTap;
  final String dateFormatCode;

  const _PesoResumenCard({
    required this.data,
    required this.onTap,
    required this.dateFormatCode,
  });

  String? _formatLastRecorded(DateTime? dt) {
    if (dt == null) return null;
    return DateFormat('d MMM', dateFormatCode).format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.watch(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final trend = data.dailyTrendGramsPerDay;
    final lastLabel = _formatLastRecorded(data.lastRecordedAt);
    return Material(
      color: AppTheme.cardBackground,
      elevation: AppTheme.cardElevation,
      shadowColor: Colors.black12,
      shape: AppTheme.homeCardShapeRounded,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -12,
                child: Icon(
                  Icons.monitor_weight_rounded,
                  size: 72,
                  color: AppTheme.navWeightSelectedFg.withValues(alpha: 0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileWeightLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textDark,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.currentKg != null
                          ? formatWeightFromKg(
                              data.currentKg!,
                              prefs,
                              l10n,
                            )
                          : '—',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (data.currentKg == null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.homeWeightNoRecords,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (trend != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            trend >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 18,
                            color: trend >= 0
                                ? AppTheme.trendPositiveGreen
                                : AppTheme.trendNegativeRed,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatWeightTrendGramsPerDay(
                              trend,
                              prefs,
                              l10n,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: trend >= 0
                                      ? AppTheme.trendPositiveGreen
                                      : AppTheme.trendNegativeRed,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                          ),
                        ],
                      ),
                    ],
                    if (lastLabel != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.homeWeightLast(lastLabel),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanalesResumenCard extends StatelessWidget {
  final _DiapersData data;
  final VoidCallback onTap;
  final String dateFormatCode;

  const _PanalesResumenCard({
    required this.data,
    required this.onTap,
    required this.dateFormatCode,
  });

  String? _formatLastRecorded(DateTime? dt) {
    if (dt == null) return null;
    return DateFormat('d MMM · HH:mm', dateFormatCode).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lastLabel = _formatLastRecorded(data.lastRecordedAt);
    return Material(
      color: AppTheme.cardBackground,
      elevation: AppTheme.cardElevation,
      shadowColor: Colors.black12,
      shape: AppTheme.homeCardShapeRounded,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
          child: Stack(
            children: [
              Positioned(
                right: -6,
                bottom: -10,
                child: Icon(
                  MdiIcons.humanBabyChangingTable,
                  size: 70,
                  color: AppTheme.navDiapersSelectedFg.withValues(alpha: 0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.navDiapers,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textDark,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.lastRecordedAt == null && data.totalToday == 0
                          ? '—'
                          : (data.totalToday == 1
                              ? l10n.homeDiaperChangesOne
                              : l10n.homeDiaperChangesN(data.totalToday)),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (data.lastRecordedAt == null && data.totalToday == 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.homeDiapersNoRecords,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.homeDiapersWetDirty(data.dirtyCount, data.wetCount),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (lastLabel != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.homeWeightLast(lastLabel),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsejoDelDiaCard extends StatelessWidget {
  final String? factText;
  final bool missingBirthDate;

  const _ConsejoDelDiaCard({
    this.factText,
    required this.missingBirthDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final raw = missingBirthDate
        ? l10n.sabiasQueNoBirthDate
        : (factText ?? l10n.homeTipFallback);

    final cardColor = Color.lerp(AppTheme.paletteTertiary, Colors.white, 0.62)!;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
        border: Border.all(color: AppTheme.cardOutline),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -8,
            bottom: -6,
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 84,
              color: AppTheme.tipText.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeTipTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.tipText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  raw,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.tipText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Franja luminosa animada encima de cada ficha (skeleton).
class _ShimmerWrap extends StatelessWidget {
  final Animation<double> animation;
  final BorderRadius borderRadius;
  final Widget child;

  const _ShimmerWrap({
    required this.animation,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  return LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      if (w <= 0) return const SizedBox.shrink();
                      final dx = (animation.value * 2 - 1) * w * 0.95;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: Container(
                          width: w * 0.42,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.5),
                                Colors.white.withValues(alpha: 0),
                              ],
                              stops: const [0.32, 0.5, 0.68],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Esqueleto del home: mismas fichas que con datos, con shimmer individual.
class _HomeCardsSkeleton extends StatefulWidget {
  const _HomeCardsSkeleton();

  @override
  State<_HomeCardsSkeleton> createState() => _HomeCardsSkeletonState();
}

class _HomeCardsSkeletonState extends State<_HomeCardsSkeleton>
    with SingleTickerProviderStateMixin {
  static const _bar = Color(0xFFE4E6EA);

  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rr = BorderRadius.circular(AppTheme.homeCardRadius);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _profileCard(rr),
        const SizedBox(height: 20),
        _resumenBlock(rr),
        const SizedBox(height: 12),
        _consejoCard(rr),
      ],
    );
  }

  Widget _profileCard(BorderRadius rr) {
    return Material(
      color: AppTheme.cardBackground,
      elevation: AppTheme.cardElevation,
      shadowColor: Colors.black12,
      shape: AppTheme.homeCardShapeRounded,
      child: _ShimmerWrap(
        animation: _shimmer,
        borderRadius: rr,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            children: [
              Container(
                width: _ProfileGradientAvatarRing.outerDiameter,
                height: _ProfileGradientAvatarRing.outerDiameter,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _bar,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 24,
                width: 148,
                decoration: BoxDecoration(
                  color: _bar,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 118,
                decoration: BoxDecoration(
                  color: _bar,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _statColumn(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: AppTheme.fieldBorder,
                        ),
                      ),
                      _statColumn(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 20,
          width: 64,
          decoration: BoxDecoration(
            color: _bar,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          width: 38,
          decoration: BoxDecoration(
            color: _bar,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _resumenBlock(BorderRadius rr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 22,
                decoration: BoxDecoration(
                  color: _bar,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 26,
              width: 88,
              decoration: BoxDecoration(
                color: AppTheme.softPrimaryFill,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Material(
          color: Color.lerp(AppTheme.palettePrimary, Colors.white, 0.62)!,
          elevation: AppTheme.cardElevation,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: rr,
            side: AppTheme.cardOutlineSide,
          ),
          child: _ShimmerWrap(
            animation: _shimmer,
            borderRadius: rr,
            child: const SizedBox(
              height: 80,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _metricSkeleton(rr)),
              const SizedBox(width: 10),
              Expanded(child: _metricSkeleton(rr)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricSkeleton(BorderRadius rr) {
    return Material(
      color: AppTheme.cardBackground,
      elevation: AppTheme.cardElevation,
      shadowColor: Colors.black12,
      shape: AppTheme.homeCardShapeRounded,
      child: _ShimmerWrap(
        animation: _shimmer,
        borderRadius: rr,
        child: const SizedBox(
          height: 108,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _consejoCard(BorderRadius rr) {
    final cardColor = Color.lerp(AppTheme.paletteTertiary, Colors.white, 0.62)!;
    return Material(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: rr,
        side: AppTheme.cardOutlineSide,
      ),
      child: _ShimmerWrap(
        animation: _shimmer,
        borderRadius: rr,
        child: ClipRRect(
          borderRadius: rr,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -8,
                bottom: -6,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 152,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 15,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 15,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 15,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightData {
  final double? currentKg;
  /// Pendiente de regresión lineal (g/día) con pesadas de los últimos 7 días.
  final double? dailyTrendGramsPerDay;
  final DateTime? lastRecordedAt;

  _WeightData({
    this.currentKg,
    this.dailyTrendGramsPerDay,
    this.lastRecordedAt,
  });
}

class _FeedingData {
  final String? lastFeedingDetail;
  final int? lastBottleMl;
  final DateTime? lastFeedingAt;
  final int expectedFeedingIntervalMinutes;

  _FeedingData({
    this.lastFeedingDetail,
    this.lastBottleMl,
    this.lastFeedingAt,
    this.expectedFeedingIntervalMinutes = kDefaultFeedingIntervalMinutes,
  });
}

class _DiapersData {
  final int wetCount;
  final int dirtyCount;
  final int totalToday;
  final DateTime? lastRecordedAt;

  _DiapersData({
    required this.wetCount,
    required this.dirtyCount,
    required this.totalToday,
    this.lastRecordedAt,
  });
}
