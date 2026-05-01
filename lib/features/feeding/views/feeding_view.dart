import 'dart:async';

import 'package:control_bebe/l10n/app_date_locale.dart';
import 'package:control_bebe/l10n/app_localizations.dart';
import 'package:control_bebe/l10n/app_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_app_title_bar.dart';
import '../../../core/theme/edit_dialog_theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/providers/record_stream_providers.dart';
import '../../../core/widgets/edit_dialog_fields.dart';
import '../../../core/widgets/edit_bottom_sheet.dart';
import '../../../core/services/next_feeding_notification_service.dart';
import '../../../core/services/lactation_live_activity_service.dart';
import '../../../core/widgets/stream_record_load_error.dart';
import '../../../core/widgets/confirm_delete_record_dialog.dart';
import '../../../core/models/measurement_units.dart';
import '../../../core/providers/measurement_prefs_provider.dart';
import '../../../core/utils/measurement_display.dart';
import '../../../core/models/feeding_record.dart';
import '../../../core/models/lactation_timer.dart';
import '../../../core/models/enums.dart';
import 'bottle_view.dart';
import 'solid_food_view.dart';
import '../widgets/breast_side_picker_sheet.dart';
import '../../../core/utils/solid_food_display.dart';
import '../../../core/utils/history_calendar_window.dart';

class FeedingView extends ConsumerStatefulWidget {
  final VoidCallback? onTitleTap;
  final VoidCallback onSettingsTap;
  final ScrollController? scrollController;
  final bool isActiveTab;

  const FeedingView({
    super.key,
    this.onTitleTap,
    required this.onSettingsTap,
    this.scrollController,
    this.isActiveTab = true,
  });

  @override
  ConsumerState<FeedingView> createState() => _FeedingViewState();
}

class _FeedingViewState extends ConsumerState<FeedingView> {
  Timer? _timer;
  LactationTimer? _activeTimer;
  final Set<int> _deletedFeedingIds = {};
  DateTime _lastHistoryScrollExpand = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _loadActiveTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveTimer() async {
    final timer = await IsarService.getActiveLactationTimer();
    if (mounted) {
      setState(() => _activeTimer = timer);
      if (timer != null) {
        _startTick();
        unawaited(LactationLiveActivityService.syncForActiveTimer());
      }
    }
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _startBreast(LactationSide side) async {
    final now = DateTime.now();
    // Actualizar UI inmediatamente sin esperar confirmación de red
    if (mounted) {
      setState(() {
        _activeTimer = LactationTimer(side: side, startedAt: now);
      });
      _startTick();
    }
    await IsarService.startLactationTimer(side);
    unawaited(NextFeedingNotificationService.cancelScheduled());
    unawaited(LactationLiveActivityService.syncForActiveTimer());
  }

  Future<void> _stopBreast() async {
    final timer = _activeTimer;
    if (timer == null) return;
    unawaited(LactationLiveActivityService.stop());
    _timer?.cancel();
    if (mounted) setState(() => _activeTimer = null);
    // Cronómetro en disco local; al parar se encola la toma como el resto de registros.
    unawaited((() async {
      final stopped = await IsarService.stopLactationTimer();
      if (stopped == null) return;
      final durationSeconds =
          DateTime.now().difference(stopped.startedAt).inSeconds;
      await IsarService.addFeedingRecord(
        FeedingRecord(
          type: stopped.side == LactationSide.left
              ? FeedingType.leftBreast
              : FeedingType.rightBreast,
          dateTime: stopped.startedAt,
          durationSeconds: durationSeconds,
        ),
      );
      await NextFeedingNotificationService.syncFromStorage();
    })());
  }

  Future<void> _openBottle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BottleView()),
    );
  }

  Future<void> _onBreastTypeTap() async {
    if (_activeTimer != null) {
      await _stopBreast();
      return;
    }
    final side = await showBreastSidePickerSheet(context);
    if (!mounted || side == null) return;
    await _startBreast(side);
  }

  Future<void> _openSolidFood() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const SolidFoodView()),
    );
  }

  void _deleteFeedingRecord(int id) {
    setState(() => _deletedFeedingIds.add(id));
    unawaited(IsarService.deleteFeedingRecord(id).then((_) {
      if (mounted) setState(() => _deletedFeedingIds.remove(id));
    }));
  }

  List<FeedingRecord> _feedingRecordsWithoutDeleted(List<FeedingRecord> raw) {
    final out = List<FeedingRecord>.from(raw)
      ..removeWhere((r) => r.id != null && _deletedFeedingIds.contains(r.id));
    return out;
  }

  bool _onFeedingHistoryScrollNotification(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is! ScrollUpdateNotification &&
        n is! ScrollEndNotification &&
        n is! OverscrollNotification) {
      return false;
    }
    final m = n.metrics;
    if (!m.hasPixels) return false;
    final nearEnd =
        m.maxScrollExtent <= 0 || m.pixels >= m.maxScrollExtent - 100;
    if (!nearEnd) return false;
    final now = DateTime.now();
    if (now.difference(_lastHistoryScrollExpand) <
        const Duration(milliseconds: 500)) {
      return false;
    }
    final days = ref.read(feedingHistoryFirestoreDaysProvider);
    if (days >= kHistoryPaginationMaxDays) {
      return false;
    }
    _lastHistoryScrollExpand = now;
    unawaited(_maybeExpandFeedingHistoryWindow());
    return false;
  }

  Future<void> _maybeExpandFeedingHistoryWindow() async {
    final hasOlder = await ref.read(hasOlderFeedingRecordsProvider.future);
    if (!mounted || !hasOlder) return;
    final days = ref.read(feedingHistoryFirestoreDaysProvider);
    if (days >= kHistoryPaginationMaxDays) return;
    ref.read(feedingHistoryFirestoreDaysProvider.notifier).state =
        days + kHistoryPaginationStepDays;
  }

  Widget _feedingHistoryColumn(
    BuildContext context,
    List<FeedingRecord> records, {
    required bool hasOlderOutsideWindow,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final dateCode = dateFormatLanguageCode(context);
    final sorted = List<FeedingRecord>.from(records)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    // Ocultar registros borrados optimistamente
    sorted.removeWhere((r) => r.id != null && _deletedFeedingIds.contains(r.id));
    final grouped = <String, List<FeedingRecord>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    for (final r in sorted) {
      final d = r.dateTime;
      final day = DateTime(d.year, d.month, d.day);
      String key;
      if (day == today) {
        key = l10n.today;
      } else if (day == yesterday) {
        key = l10n.yesterday;
      } else {
        key = DateFormat('d/M', dateCode).format(d);
      }
      grouped.putIfAbsent(key, () => []).add(r);
    }
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    if (sorted.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.historyTitle, style: titleStyle),
          const SizedBox(height: 12),
          Text(
            hasOlderOutsideWindow
                ? l10n.historyScrollLoadMore
                : l10n.feedingHistoryEmpty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
              height: 1.4,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.historyTitle, style: titleStyle),
        const SizedBox(height: 16),
        ...grouped.entries.expand(
          (e) => [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.key,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                  ),
                ),
                Text(
                  e.value.length == 1
                      ? l10n.feedingSessionCountOne
                      : l10n.feedingSessionCountN(e.value.length),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...e.value.map((r) => _FeedingRecordTile(
              record: r,
              onDelete: r.id != null
                  ? () async {
                      final ok = await confirmDeleteRecord(context);
                      if (!context.mounted || !ok) return;
                      _deleteFeedingRecord(r.id!);
                    }
                  : null,
            )),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feedingRecordsAsync = widget.isActiveTab
        ? ref.watch(feedingRecordsStreamProvider)
        : ref.read(feedingRecordsStreamProvider);
    final hasOlderAsync = widget.isActiveTab
        ? ref.watch(hasOlderFeedingRecordsProvider)
        : ref.read(hasOlderFeedingRecordsProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onFeedingHistoryScrollNotification,
                child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: EdgeInsets.fromLTRB(
                  AppTheme.screenEdgePadding,
                  MainAppTitleBar.totalHeight +
                      AppTheme.contentPaddingTopAfterTitleBar,
                  AppTheme.screenEdgePadding,
                  20 + AppTheme.safeBottomPadding(context),
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.utensils,
                              color: AppTheme.pageTitleIconFeeding,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.feedingTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 360),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          child: _activeTimer == null
                              ? const SizedBox.shrink()
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 340),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (child, animation) {
                                        final slide =
                                            Tween<Offset>(
                                          begin: const Offset(0, -0.12),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        );
                                        return SizedBox(
                                          width: double.infinity,
                                          child: ClipRect(
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: slide,
                                                child: child,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: KeyedSubtree(
                                        key: ObjectKey(_activeTimer!),
                                        child: _ActiveTimerBanner(
                                          timer: _activeTimer!,
                                          onStop: _stopBreast,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                        ),
                        Text(
                          l10n.feedingSessionType,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _TomaTypeButton(
                                label: l10n.feedingBreast,
                                isActive: _activeTimer != null,
                                onTap: _onBreastTypeTap,
                                iconBuilder: (c) => FaIcon(
                                  FontAwesomeIcons.personBreastfeeding,
                                  size: 28,
                                  color: c,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TomaTypeButton(
                                label: l10n.feedingBottle,
                                isActive: false,
                                onTap: _openBottle,
                                iconBuilder: (c) => Icon(
                                  MdiIcons.babyBottle,
                                  size: 28,
                                  color: c,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TomaTypeButton(
                                label: l10n.feedingSolidFood,
                                isActive: false,
                                onTap: _openSolidFood,
                                iconBuilder: (c) => Icon(
                                  MdiIcons.silverwareForkKnife,
                                  size: 28,
                                  color: c,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        feedingRecordsAsync.when(
                          skipLoadingOnReload: true,
                          data: (records) {
                            final merged =
                                _feedingRecordsWithoutDeleted(records);
                            final hasOlder = hasOlderAsync.maybeWhen(
                              data: (v) => v,
                              orElse: () => false,
                            );
                            return _feedingHistoryColumn(
                              context,
                              merged,
                              hasOlderOutsideWindow: hasOlder,
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => StreamRecordLoadError(
                            message: l10n.feedingStreamError,
                            onRetry: () =>
                                ref.invalidate(feedingRecordsStreamProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MainAppTitleBar(
                onTitleTap: widget.onTitleTap,
                onSettingsTap: widget.onSettingsTap,
              ),
            ),
            const TitleBarScrollFade(),
          ],
        ),
      ),
    );
  }
}

class _ActiveTimerBanner extends StatelessWidget {
  final LactationTimer timer;
  final VoidCallback onStop;

  const _ActiveTimerBanner({required this.timer, required this.onStop});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalSeconds = timer.elapsed.inSeconds;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.softPrimaryFill,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          timer.side == LactationSide.left
              ? const FaIcon(
                  FontAwesomeIcons.personBreastfeeding,
                  color: AppTheme.palettePrimary,
                  size: 32,
                )
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1, 1, 1),
                  child: const FaIcon(
                    FontAwesomeIcons.personBreastfeeding,
                    color: AppTheme.palettePrimary,
                    size: 32,
                  ),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.feedingActiveTimer(
                    timer.side == LactationSide.left
                        ? l10n.feedingSideLeft
                        : l10n.feedingSideRight,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  formatDurationSecondsLocalized(l10n, totalSeconds),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.palettePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onStop,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.palettePrimary,
            ),
            child: Text(l10n.feedingStop),
          ),
        ],
      ),
    );
  }
}

typedef _TomaIconBuilder = Widget Function(Color iconColor);

/// Pecho / Biberón / Sólidos: misma tarjeta; el cronómetro marca `isActive` en pecho.
class _TomaTypeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final _TomaIconBuilder iconBuilder;

  const _TomaTypeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? AppTheme.palettePrimary : AppTheme.textLight;
    final surface = isActive ? const Color(0xFFF5F5F5) : Colors.white;
    final borderColor = isActive
        ? AppTheme.palettePrimary.withValues(alpha: 0.55)
        : AppTheme.fieldBorder;
    final borderWidth = isActive ? 2.0 : 1.5;

    return Material(
      color: surface,
      elevation: isActive ? 2 : 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        splashColor: AppTheme.palettePrimary.withValues(alpha: 0.12),
        highlightColor: AppTheme.palettePrimary.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
          child: Column(
            children: [
              iconBuilder(iconColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppTheme.textDark : AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedingRecordTile extends ConsumerWidget {
  final FeedingRecord record;
  final VoidCallback? onDelete;

  const _FeedingRecordTile({required this.record, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.watch(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final dateCode = dateFormatLanguageCode(context);
    final (icon, label, accentColor, mirrored) = switch (record.type) {
      FeedingType.leftBreast => (
        FontAwesomeIcons.personBreastfeeding,
        l10n.feedingLeft,
        AppTheme.feedingHistoryLeftAccent,
        false,
      ),
      FeedingType.rightBreast => (
        FontAwesomeIcons.personBreastfeeding,
        l10n.feedingRight,
        AppTheme.feedingHistoryRightAccent,
        true,
      ),
      FeedingType.bottle => (
        MdiIcons.babyBottle,
        l10n.feedingBottle,
        AppTheme.feedingHistoryBottleAccent,
        false,
      ),
      FeedingType.solidFood => (
        MdiIcons.silverwareForkKnife,
        '',
        AppTheme.feedingHistorySolidAccent,
        false,
      ),
    };
    final duration = record.type != FeedingType.solidFood &&
            record.durationSeconds != null
        ? formatDurationSecondsLocalized(l10n, record.durationSeconds!)
        : null;
    final amount = record.type == FeedingType.bottle &&
            record.amountMl != null
        ? formatVolumeFromMl(record.amountMl!, prefs, l10n)
        : null;
    final secondaryDetail = record.type == FeedingType.solidFood
        ? null
        : [?duration, ?amount].nonNulls.join(' ').isEmpty
            ? null
            : [?duration, ?amount].nonNulls.join(' ');
    final solidNameLine = record.type == FeedingType.solidFood
        ? record.solidName?.trim()
        : null;
    final solidQtyLine = record.type == FeedingType.solidFood
        ? solidFoodQuantityLabel(
            l10n,
            record.solidQuantity,
            record.solidUnit,
            dateFormatLanguageCode(context),
          )
        : null;
    final hasSolidLines = record.type == FeedingType.solidFood &&
        ((solidNameLine != null && solidNameLine.isNotEmpty) ||
            solidQtyLine != null);
    final borderRadius = BorderRadius.circular(AppTheme.homeCardRadius);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: AppTheme.historyRecordStripeWidth,
                decoration:
                    AppTheme.historyRecordStripeDecoration(accentColor),
              ),
              Padding(
                padding: AppTheme.historyRecordLeadingPadding,
                child: Center(
                  child: CircleAvatar(
                    radius: AppTheme.historyRecordAvatarRadius,
                    backgroundColor: accentColor.withValues(
                      alpha: AppTheme.historyRecordAvatarAccentOpacity,
                    ),
                    child: record.type == FeedingType.bottle ||
                            record.type == FeedingType.solidFood
                        ? Icon(icon, color: accentColor, size: 22)
                        : (mirrored
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.diagonal3Values(-1, 1, 1),
                                  child: FaIcon(
                                    icon,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                )
                              : FaIcon(icon, color: accentColor, size: 20)),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: AppTheme.historyRecordContentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (record.type == FeedingType.solidFood) ...[
                        if (solidNameLine != null &&
                            solidNameLine.isNotEmpty) ...[
                          Text(
                            solidNameLine,
                            style: AppTheme.historyRecordTypeTitleStyle(
                              accentColor,
                            ),
                          ),
                        ],
                        if (solidQtyLine != null) ...[
                          if (solidNameLine != null &&
                              solidNameLine.isNotEmpty)
                            SizedBox(
                              height: AppTheme.historyRecordAfterTitleGap,
                            ),
                          Text(
                            solidQtyLine,
                            style:
                                AppTheme.historyRecordPrimaryValueStyle(
                              accentColor,
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          label,
                          style: AppTheme.historyRecordTypeTitleStyle(
                            accentColor,
                          ),
                        ),
                        if (secondaryDetail != null) ...[
                          SizedBox(
                            height: AppTheme.historyRecordAfterTitleGap,
                          ),
                          Text(
                            secondaryDetail,
                            style:
                                AppTheme.historyRecordPrimaryValueStyle(
                              accentColor,
                            ),
                          ),
                        ],
                      ],
                      SizedBox(
                        height: (secondaryDetail != null || hasSolidLines)
                            ? AppTheme.historyRecordDetailToDateGap
                            : AppTheme.historyRecordAfterTitleGap,
                      ),
                      Text(
                        DateFormat('d MMM, HH:mm', dateCode).format(record.dateTime),
                        style: AppTheme.historyRecordDateTimeStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: AppTheme.historyRecordTrailingOuterPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditDialog(context, ref, record),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: onDelete,
                        ),
                      ],
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

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    FeedingRecord record,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (record.type == FeedingType.solidFood) {
      final localeCode = dateFormatLanguageCode(context);
      final nameController = TextEditingController(text: record.solidName ?? '');
      final initialUnit = record.solidUnit ?? SolidQuantityUnit.grams;
      final qtyController = TextEditingController(
        text: formatSolidQuantityForField(
          record.solidQuantity,
          initialUnit,
          localeCode,
        ),
      );
      var solidUnit = initialUnit;
      var selectedDate = DateTime(
        record.dateTime.year,
        record.dateTime.month,
        record.dateTime.day,
      );
      var selectedTime = TimeOfDay.fromDateTime(record.dateTime);
      final fieldDeco = InputDecoration(
        filled: true,
        fillColor: AppTheme.fieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
          borderSide: const BorderSide(color: AppTheme.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
          borderSide: const BorderSide(color: AppTheme.fieldBorder),
        ),
      );
      final solidEditFormKey = GlobalKey<FormState>();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => StatefulBuilder(
          builder: (modalContext, setState) {
            final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                );
            return EditBottomSheet(
              title: l10n.feedingEditSolid,
              child: Form(
                key: solidEditFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Text(l10n.solidFoodNameLabel, style: labelStyle),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: fieldDeco.copyWith(
                        hintText: l10n.solidFoodNameHint,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.solidFoodValidatorNameEmpty;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: EditDialogTheme.spacingBetweenSections),
                    Text(l10n.solidFoodQuantityLabel, style: labelStyle),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: qtyController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: solidUnit == SolidQuantityUnit.grams,
                        signed: false,
                      ),
                      inputFormatters: [
                        if (solidUnit == SolidQuantityUnit.grams)
                          SolidGramsQuantityInputFormatter()
                        else
                          SolidUnitsQuantityInputFormatter(),
                      ],
                      decoration: fieldDeco.copyWith(
                        hintText: solidUnit == SolidQuantityUnit.grams
                            ? l10n.solidFoodQuantityHintGrams
                            : l10n.solidFoodQuantityHintUnits,
                      ),
                      validator: (v) =>
                          validateSolidQuantityInput(v, solidUnit, l10n),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<SolidQuantityUnit>(
                      segments: [
                        ButtonSegment(
                          value: SolidQuantityUnit.grams,
                          label: Text(l10n.solidFoodUnitGrams),
                        ),
                        ButtonSegment(
                          value: SolidQuantityUnit.units,
                          label: Text(l10n.solidFoodUnitUnits),
                        ),
                      ],
                      selected: {solidUnit},
                      onSelectionChanged: (s) {
                        final nu = s.first;
                        setState(() {
                          solidUnit = nu;
                          if (nu == SolidQuantityUnit.units) {
                            final raw = qtyController.text.trim();
                            if (raw.contains(',') || raw.contains('.')) {
                              final g = tryParseSolidQuantity(
                                raw,
                                SolidQuantityUnit.grams,
                              );
                              if (g != null) {
                                qtyController.text = g.round().toString();
                              } else {
                                qtyController.clear();
                              }
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(height: EditDialogTheme.spacingBetweenSections),
                    DatePickerField(
                      value: selectedDate,
                      onChanged: (d) => setState(() => selectedDate = d),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    ),
                    SizedBox(height: EditDialogTheme.spacingBetweenFields),
                    TimePickerField(
                      value: selectedTime,
                      onChanged: (t) => setState(() => selectedTime = t),
                    ),
                  ],
                ),
                ),
              ),
              onCancel: () => Navigator.pop(ctx),
              onSave: () async {
                if (solidEditFormKey.currentState?.validate() != true) return;
                final name = nameController.text.trim();
                final q = tryParseSolidQuantity(qtyController.text, solidUnit);
                if (q == null || !q.isFinite) return;
                final dt = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                await IsarService.updateFeedingRecord(
                  record.copyWith(
                    dateTime: dt,
                    solidName: name,
                    solidQuantity: q,
                    solidUnit: solidUnit,
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
            );
          },
        ),
      );
    } else if (record.type == FeedingType.bottle) {
      final prefs = ref.read(measurementPrefsProvider).valueOrNull ??
          MeasurementPrefs.defaultsForDispatcher();
      final ml0 = record.amountMl ?? 0;
      final initialVolumeText = prefs.liquid == LiquidUnitMode.milliliters
          ? '$ml0'
          : trimFlOzDisplay(mlToUsFlOzNum(ml0));
      final controller = TextEditingController(text: initialVolumeText);
      final liquidLabel = prefs.liquid == LiquidUnitMode.milliliters
          ? l10n.feedingAmountMl
          : l10n.liquidFieldLabelFlOz;
      var selectedDate = DateTime(
        record.dateTime.year,
        record.dateTime.month,
        record.dateTime.day,
      );
      var selectedTime = TimeOfDay.fromDateTime(record.dateTime);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => StatefulBuilder(
          builder: (modalContext, setState) => EditBottomSheet(
            title: l10n.feedingEditBottle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  liquidLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: bottleVolumeHint(prefs, l10n),
                    filled: true,
                    fillColor: AppTheme.fieldBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                      borderSide: const BorderSide(color: AppTheme.fieldBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                      borderSide: const BorderSide(color: AppTheme.fieldBorder),
                    ),
                  ),
                ),
                SizedBox(height: EditDialogTheme.spacingBetweenSections),
                DatePickerField(
                  value: selectedDate,
                  onChanged: (d) => setState(() => selectedDate = d),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                ),
                SizedBox(height: EditDialogTheme.spacingBetweenFields),
                TimePickerField(
                  value: selectedTime,
                  onChanged: (t) => setState(() => selectedTime = t),
                ),
              ],
            ),
            onCancel: () => Navigator.pop(ctx),
            onSave: () async {
              final ml = parseVolumeInputToMl(controller.text, prefs);
              if (ml != null &&
                  ml > 0 &&
                  ml <= kMaxReasonableVolumeMl) {
                final dt = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                await IsarService.updateFeedingRecord(
                  record.copyWith(amountMl: ml, dateTime: dt),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
          ),
        ),
      );
    } else {
      final startDt = record.dateTime;
      final endDt = startDt.add(Duration(seconds: record.durationSeconds ?? 0));
      var selectedDate = DateTime(startDt.year, startDt.month, startDt.day);
      var selectedStartTime = TimeOfDay.fromDateTime(startDt);
      var selectedEndTime = TimeOfDay.fromDateTime(endDt);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setState) => EditBottomSheet(
            title: l10n.feedingEditSession,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DatePickerField(
                  value: selectedDate,
                  onChanged: (d) => setState(() => selectedDate = d),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                ),
                SizedBox(height: EditDialogTheme.spacingBetweenFields),
                TimePickerField(
                  value: selectedStartTime,
                  label: l10n.commonTimeStart,
                  onChanged: (t) => setState(() => selectedStartTime = t),
                ),
                SizedBox(height: EditDialogTheme.spacingBetweenFields),
                TimePickerField(
                  value: selectedEndTime,
                  label: l10n.commonTimeEnd,
                  onChanged: (t) => setState(() => selectedEndTime = t),
                ),
              ],
            ),
            onCancel: () => Navigator.pop(ctx),
            onSave: () async {
              final start = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedStartTime.hour,
                selectedStartTime.minute,
              );
              final end = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedEndTime.hour,
                selectedEndTime.minute,
              );
              var durationSec = end.difference(start).inSeconds;
              if (durationSec < 0) durationSec += 86400;
              await IsarService.updateFeedingRecord(
                record.copyWith(dateTime: start, durationSeconds: durationSec),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ),
      );
    }
  }
}
