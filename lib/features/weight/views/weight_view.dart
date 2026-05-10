import 'dart:async';
import 'dart:math' as math;

import 'package:control_bebe/l10n/app_date_locale.dart';
import 'package:control_bebe/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_app_title_bar.dart';
import '../../../core/theme/edit_dialog_theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/providers/record_stream_providers.dart';
import '../../../core/widgets/edit_dialog_fields.dart';
import '../../../core/widgets/stream_record_load_error.dart';
import '../../../core/widgets/edit_bottom_sheet.dart';
import '../../../core/widgets/confirm_delete_record_dialog.dart';
import '../../../core/models/weight_record.dart';
import '../../../core/utils/baby_age_calendar.dart';
import '../../../core/percentiles_data.dart';
import '../../../core/utils/weight_daily_trend.dart';
import '../../../core/models/measurement_units.dart';
import '../../../core/providers/measurement_prefs_provider.dart';
import '../../../core/providers/baby_profile_provider.dart';
import '../../../core/providers/weight_chart_prefs_provider.dart';
import '../../../core/utils/measurement_display.dart';
import '../../../core/utils/history_calendar_window.dart';
import '../models/weight_chart_prefs.dart';

List<WeightRecord> _weightRecordsInChartRange(
  List<WeightRecord> records,
  WeightChartTimeRange range,
) {
  final days = range.trailingDays;
  if (days == null) return records;
  final cutoff = DateTime.now().subtract(Duration(days: days));
  return records.where((r) => !r.dateTime.isBefore(cutoff)).toList();
}

class WeightView extends ConsumerStatefulWidget {
  final VoidCallback? onTitleTap;
  final VoidCallback onSettingsTap;
  final ScrollController? scrollController;

  /// Si es false, no se suscribe a Firestore hasta que la pestaña sea visible.
  final bool isActiveTab;

  const WeightView({
    super.key,
    this.onTitleTap,
    required this.onSettingsTap,
    this.scrollController,
    this.isActiveTab = true,
  });

  @override
  ConsumerState<WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends ConsumerState<WeightView> {
  final _weightController = TextEditingController();
  final _weightFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final Set<int> _deletedWeightIds = {};
  DateTime _lastHistoryScrollExpand = DateTime.fromMillisecondsSinceEpoch(0);

  /// Misma altura visual que [ElevatedButton] de esta fila.
  static const double _weightControlHeight = 56;

  @override
  void dispose() {
    _weightFocusNode.dispose();
    _weightController.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _weightKeyboardConfig(AppLocalizations l10n) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: AppTheme.softPrimaryFill,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _weightFocusNode,
          displayArrows: false,
          toolbarButtons: [
            (node) => IconButton(
              icon: const Icon(Icons.check_rounded),
              color: AppTheme.palettePrimary,
              tooltip: l10n.commonDone,
              onPressed: () => node.unfocus(),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _registerWeight() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs =
        ref.read(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final weightKg = parseWeightInputToKg(_weightController.text, prefs);
    if (weightKg == null || weightKg <= 0) return;

    // Limpiar el campo inmediatamente sin esperar confirmación de red
    _weightController.clear();
    unawaited(
      IsarService.addWeightRecord(
        WeightRecord(weightKg: weightKg, dateTime: DateTime.now()),
      ),
    );
  }

  void _deleteWeightRecord(int id) {
    setState(() => _deletedWeightIds.add(id));
    unawaited(
      IsarService.deleteWeightRecord(id).then((_) {
        if (mounted) setState(() => _deletedWeightIds.remove(id));
      }),
    );
  }

  bool _onWeightHistoryScrollNotification(ScrollNotification n) {
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
    final all = ref.read(weightRecordsForChartStreamProvider).valueOrNull;
    if (all == null) return false;
    final total = all
        .where((r) => r.id == null || !_deletedWeightIds.contains(r.id))
        .length;
    final limit = ref.read(weightHistoryVisibleLimitProvider);
    if (limit >= total) return false;
    _lastHistoryScrollExpand = now;
    unawaited(_maybeExpandWeightHistoryWindow());
    return false;
  }

  Future<void> _maybeExpandWeightHistoryWindow() async {
    final data = ref.read(weightRecordsForChartStreamProvider).valueOrNull;
    if (!mounted || data == null) return;
    final total = data
        .where((r) => r.id == null || !_deletedWeightIds.contains(r.id))
        .length;
    final limit = ref.read(weightHistoryVisibleLimitProvider);
    if (limit >= total) return;
    ref.read(weightHistoryVisibleLimitProvider.notifier).state = math.min(
      limit + kWeightHistoryPageIncrement,
      total,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs =
        ref.watch(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final chartRecordsAsync = widget.isActiveTab
        ? ref.watch(weightRecordsForChartStreamProvider)
        : ref.read(weightRecordsForChartStreamProvider);
    final historyVisibleLimit = ref.watch(weightHistoryVisibleLimitProvider);
    final chartPrefs =
        ref.watch(weightChartPrefsProvider).valueOrNull ??
        WeightChartPrefs.defaults;
    final chartTimeRange = chartPrefs.timeRange;
    final chartPercentile = chartPrefs.percentile;

    List<WeightRecord> chartVisibleRecords(List<WeightRecord> raw) => raw
        .where((r) => r.id == null || !_deletedWeightIds.contains(r.id))
        .toList();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: ref
                  .watch(babyProfileProvider)
                  .when(
                    data: (baby) {
                      final isMale = baby?.isMale ?? true;

                      return GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        behavior: HitTestBehavior.opaque,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: _onWeightHistoryScrollNotification,
                          child: SingleChildScrollView(
                            controller: widget.scrollController,
                            padding: EdgeInsets.fromLTRB(
                              AppTheme.screenEdgePadding,
                              MainAppTitleBar.totalHeight +
                                  AppTheme.contentPaddingTopAfterTitleBar,
                              AppTheme.screenEdgePadding,
                              20 + AppTheme.safeBottomPadding(context),
                            ),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.monitor_weight,
                                              color:
                                                  AppTheme.pageTitleIconWeight,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              l10n.weightTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textDark,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        KeyboardActions(
                                          config: _weightKeyboardConfig(l10n),
                                          // Sin esto, BottomAreaAvoider mete LayoutBuilder +
                                          // SingleChildScrollView con minHeight = maxHeight del padre;
                                          // dentro del Column del card eso puede ser ∞ y rompe el layout.
                                          disableScroll: true,
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Text(
                                                  weightFieldLabelForPrefs(
                                                    prefs,
                                                    l10n,
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        color:
                                                            AppTheme.textLight,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: SizedBox(
                                                        height:
                                                            _weightControlHeight,
                                                        child: TextFormField(
                                                          controller:
                                                              _weightController,
                                                          focusNode:
                                                              _weightFocusNode,
                                                          keyboardType:
                                                              const TextInputType.numberWithOptions(
                                                                decimal: true,
                                                              ),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .done,
                                                          onFieldSubmitted: (_) =>
                                                              _weightFocusNode
                                                                  .unfocus(),
                                                          onTapOutside: (_) =>
                                                              _weightFocusNode
                                                                  .unfocus(),
                                                          expands: true,
                                                          maxLines: null,
                                                          minLines: null,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          decoration: InputDecoration(
                                                            hintText:
                                                                weightEntryHint(
                                                                  prefs,
                                                                  l10n,
                                                                ),
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      20,
                                                                ),
                                                            isDense: false,
                                                          ),
                                                          validator: (v) {
                                                            if (v == null ||
                                                                v
                                                                    .trim()
                                                                    .isEmpty) {
                                                              return l10n
                                                                  .weightValidatorEmpty;
                                                            }
                                                            final kg =
                                                                parseWeightInputToKg(
                                                                  v,
                                                                  prefs,
                                                                );
                                                            if (kg == null ||
                                                                kg <= 0 ||
                                                                kg > 50) {
                                                              return l10n
                                                                  .weightValidatorInvalid;
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: SizedBox(
                                                        height:
                                                            _weightControlHeight,
                                                        child: ElevatedButton(
                                                          onPressed:
                                                              _registerWeight,
                                                          style: ElevatedButton.styleFrom(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                ),
                                                            minimumSize: const Size(
                                                              0,
                                                              _weightControlHeight,
                                                            ),
                                                            maximumSize: const Size(
                                                              double.infinity,
                                                              _weightControlHeight,
                                                            ),
                                                            fixedSize: const Size(
                                                              double.infinity,
                                                              _weightControlHeight,
                                                            ),
                                                            tapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                          ),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              l10n.weightRegister,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        chartRecordsAsync.when(
                                          skipLoadingOnReload: true,
                                          data: (records) => _summaryRow(
                                            context,
                                            chartVisibleRecords(records),
                                            prefs,
                                          ),
                                          loading: () => const SizedBox(
                                            height: 80,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          error: (e, _) => StreamRecordLoadError(
                                            message: l10n.weightStreamError,
                                            onRetry: () {
                                              ref.invalidate(
                                                weightRecordsForChartStreamProvider,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                chartRecordsAsync.when(
                                  skipLoadingOnReload: true,
                                  data: (records) {
                                    final visible = chartVisibleRecords(
                                      records,
                                    );
                                    final chartRecords =
                                        _weightRecordsInChartRange(
                                          visible,
                                          chartTimeRange,
                                        );
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    l10n.weightEvolution,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  flex: 0,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        _ChartFilterPill<
                                                          WeightPercentile
                                                        >(
                                                          value:
                                                              chartPercentile,
                                                          values:
                                                              WeightPercentile
                                                                  .pickerValues,
                                                          labelOf: (p) =>
                                                              p.shortLabel,
                                                          onChanged: (p) => ref
                                                              .read(
                                                                weightChartPrefsProvider
                                                                    .notifier,
                                                              )
                                                              .setPercentile(p),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        _ChartFilterPill<
                                                          WeightChartTimeRange
                                                        >(
                                                          value: chartTimeRange,
                                                          values:
                                                              WeightChartTimeRange
                                                                  .pickerValues,
                                                          labelOf: (r) =>
                                                              r.label(l10n),
                                                          onChanged: (r) => ref
                                                              .read(
                                                                weightChartPrefsProvider
                                                                    .notifier,
                                                              )
                                                              .setTimeRange(r),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              height: 220,
                                              child: chartRecords.isEmpty
                                                  ? Center(
                                                      child: Text(
                                                        visible.isEmpty
                                                            ? l10n.weightChartEmpty
                                                            : l10n.weightChartNoDataInRange,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .textLight,
                                                        ),
                                                      ),
                                                    )
                                                  : _WeightChart(
                                                      records: chartRecords,
                                                      prefs: prefs,
                                                      isMale: isMale,
                                                      birthDate:
                                                          baby?.birthDate ??
                                                          DateTime.now(),
                                                      percentile:
                                                          chartPercentile,
                                                    ),
                                            ),
                                            if (chartRecords.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 20,
                                                    height: 3,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          top: 5,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme
                                                          .primaryGreen
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      l10n.weightChartCaption,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: AppTheme
                                                                .textLight,
                                                            height: 1.35,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                l10n.weightChartSource,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          AppTheme.primaryBlue,
                                                      height: 1.35,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  loading: () => const Card(
                                    child: SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                  error: (e, _) => Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: StreamRecordLoadError(
                                        message: l10n.weightChartLoadError,
                                        onRetry: () {
                                          ref.invalidate(
                                            weightRecordsForChartStreamProvider,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                chartRecordsAsync.when(
                                  skipLoadingOnReload: true,
                                  data: (allRecords) {
                                    final allVisible = allRecords
                                        .where(
                                          (r) =>
                                              r.id == null ||
                                              !_deletedWeightIds.contains(r.id),
                                        )
                                        .toList();
                                    final takeCount = math.min(
                                      historyVisibleLimit,
                                      allVisible.length,
                                    );
                                    final records = allVisible
                                        .take(takeCount)
                                        .toList();
                                    final hasMoreInList =
                                        allVisible.length > takeCount;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.historyTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        if (records.isEmpty)
                                          Text(
                                            l10n.weightHistoryEmpty,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppTheme.textLight,
                                                  height: 1.4,
                                                ),
                                          )
                                        else ...[
                                          ...records.map(
                                            (r) => _WeightRecordTile(
                                              record: r,
                                              onDelete: r.id != null
                                                  ? () async {
                                                      final ok =
                                                          await confirmDeleteRecord(
                                                            context,
                                                          );
                                                      if (!context.mounted ||
                                                          !ok) {
                                                        return;
                                                      }
                                                      _deleteWeightRecord(
                                                        r.id!,
                                                      );
                                                    }
                                                  : null,
                                            ),
                                          ),
                                          if (hasMoreInList)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                l10n.historyScrollLoadMore,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: AppTheme.textLight,
                                                      height: 1.4,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ],
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (e, _) => StreamRecordLoadError(
                                    message: l10n.weightHistoryLoadError,
                                    onRetry: () => ref.invalidate(
                                      weightRecordsForChartStreamProvider,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(
                      child: StreamRecordLoadError(
                        message: l10n.weightStreamError,
                        onRetry: () => ref.invalidate(babyProfileProvider),
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

  Widget _summaryRow(
    BuildContext context,
    List<WeightRecord> records,
    MeasurementPrefs prefs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final lastWeight = records.isNotEmpty ? records.first : null;
    final dailyGPerDay = dailyWeightTrendLinearRegressionGramsPerDay(records);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: l10n.weightCurrentCard,
            value: lastWeight != null
                ? formatWeightFromKg(lastWeight.weightKg, prefs, l10n)
                : l10n.weightNoData,
            valueIsPlaceholder: lastWeight == null,
            showTrendIcon: false,
            valueColor: lastWeight != null ? Colors.black : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: l10n.weightTrendCard,
            value: dailyGPerDay != null
                ? formatWeightTrendCompact(dailyGPerDay, prefs, l10n)
                : l10n.weightDash,
            valueIsPlaceholder: dailyGPerDay == null,
            showTrendIcon: dailyGPerDay != null,
            isPositive: dailyGPerDay != null && dailyGPerDay >= 0,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final bool valueIsPlaceholder;
  final bool isPositive;
  final bool showTrendIcon;

  /// Si no es null y hay valor, colorea el texto (p. ej. negro para peso actual).
  final Color? valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.valueIsPlaceholder,
    this.isPositive = true,
    this.showTrendIcon = true,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final empty = valueIsPlaceholder;
    Color resolvedColor;
    if (empty) {
      resolvedColor = AppTheme.textLight;
    } else if (valueColor != null) {
      resolvedColor = valueColor!;
    } else if (showTrendIcon) {
      resolvedColor = isPositive
          ? AppTheme.trendPositiveGreen
          : AppTheme.trendNegativeRed;
    } else {
      resolvedColor = AppTheme.textDark;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
        border: Border.all(color: AppTheme.cardOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (showTrendIcon && !empty)
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 20,
                  color: resolvedColor,
                ),
              if (showTrendIcon && !empty) const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: resolvedColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightRecord> records;
  final MeasurementPrefs prefs;
  final bool isMale;
  final DateTime birthDate;
  final WeightPercentile percentile;

  const _WeightChart({
    required this.records,
    required this.prefs,
    required this.isMale,
    required this.birthDate,
    required this.percentile,
  });

  double _ageInMonths(DateTime date) {
    return BabyAgeCalendar.fractionalMonthsAt(birthDate, date);
  }

  /// Días transcurridos desde [origin] hasta [t] (fracción de día si hay hora).
  static double _daysSince(DateTime origin, DateTime t) {
    return t.difference(origin).inMilliseconds / Duration.millisecondsPerDay;
  }

  static double _bottomTitleInterval(double maxX) {
    if (maxX <= 0.5) return 0.25;
    if (maxX <= 2) return 0.5;
    if (maxX <= 10) return 1;
    if (maxX <= 45) return 7;
    if (maxX <= 120) return 14;
    return math.max(7, maxX / 6);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateCode = dateFormatLanguageCode(context);
    if (records.isEmpty) {
      return Center(
        child: Text(
          l10n.weightChartEmpty,
          style: TextStyle(color: AppTheme.textLight),
        ),
      );
    }

    final sortedRecords = List<WeightRecord>.from(records)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final origin = sortedRecords.first.dateTime;
    // Eje X: días reales desde la primera pesada (espaciado coherente con el tiempo).
    final spots = sortedRecords
        .map((r) => FlSpot(_daysSince(origin, r.dateTime), r.weightKg))
        .toList();

    var xMax = spots.map((s) => s.x).reduce(math.max);
    // El eje X termina en el último registro; sin tramo vacío a la derecha.
    if (xMax < 1e-9) {
      xMax = 1e-6; // mismo instante / un punto: evita maxX == minX en fl_chart
    }

    final minWeight = records
        .map((r) => r.weightKg)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = records
        .map((r) => r.weightKg)
        .reduce((a, b) => a > b ? a : b);

    // Percentil de referencia en el rango de edad de los registros
    final minMonth = _ageInMonths(
      sortedRecords.first.dateTime,
    ).clamp(0.0, 12.0);
    final maxMonth = _ageInMonths(sortedRecords.last.dateTime).clamp(0.0, 12.0);
    final refMinKg = PercentilesData.getPercentileWeight(
      isMale,
      percentile,
      minMonth,
    );
    final refMaxKg = PercentilesData.getPercentileWeight(
      isMale,
      percentile,
      maxMonth,
    );
    final refLow = refMinKg < refMaxKg ? refMinKg : refMaxKg;
    final refHigh = refMinKg > refMaxKg ? refMinKg : refMaxKg;

    // Rango Y: incluir siempre pesos y percentil para que la línea del percentil sea visible
    final dataMinY = minWeight < refLow ? minWeight : refLow;
    final dataMaxY = maxWeight > refHigh ? maxWeight : refHigh;
    var minY = (dataMinY - 0.5).clamp(0.0, 20.0);
    var maxY = (dataMaxY + 0.5).clamp(0.0, 20.0);
    if (maxY <= minY) {
      maxY = (minY + 0.5).clamp(0.0, 50.0);
      if (maxY <= minY) minY = math.max(0.0, maxY - 0.5);
    }

    final refSpots = sortedRecords.map((r) {
      final age = _ageInMonths(r.dateTime);
      return FlSpot(
        _daysSince(origin, r.dateTime),
        PercentilesData.getPercentileWeight(isMale, percentile, age),
      );
    }).toList();

    final bottomInterval = _bottomTitleInterval(xMax);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: xMax,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: prefs.weight == WeightUnitMode.metric ? 32 : 38,
              getTitlesWidget: (value, meta) {
                final label = prefs.weight == WeightUnitMode.metric
                    ? value.toStringAsFixed(1)
                    : (value * 2.2046226218).toStringAsFixed(1);
                return Text(
                  label,
                  style: TextStyle(color: AppTheme.textLight, fontSize: 10),
                );
              },
              interval: 0.5,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value < -1e-6 || value > xMax + 1e-6) {
                  return const SizedBox.shrink();
                }
                final labelDate = origin.add(
                  Duration(
                    milliseconds: (value * Duration.millisecondsPerDay).round(),
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('d/M', dateCode).format(labelDate),
                    style: TextStyle(color: AppTheme.textLight, fontSize: 10),
                  ),
                );
              },
              interval: bottomInterval,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          if (refSpots.length > 1)
            LineChartBarData(
              spots: refSpots,
              isCurved: true,
              color: AppTheme.textLight.withValues(alpha: 0.45),
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryGreen,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 2,
                    color: AppTheme.primaryGreen,
                    strokeWidth: 0,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.14),
                  AppTheme.primaryGreen.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            maxContentWidth: 240,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            tooltipRoundedRadius: 12,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => Colors.white,
            tooltipBorder: BorderSide(
              color: Colors.black.withValues(alpha: 0.12),
            ),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              if (touchedSpots.isEmpty) return [];

              final x = touchedSpots.first.x;
              final touchedDate = origin.add(
                Duration(
                  milliseconds: (x * Duration.millisecondsPerDay).round(),
                ),
              );
              final dateStr = DateFormat(
                'd MMM yyyy, HH:mm',
                dateCode,
              ).format(touchedDate);

              final hasRef = refSpots.length > 1;
              final dataBarIndex = hasRef ? 1 : 0;

              double? dataKg;
              double? refTouchedY;
              for (final s in touchedSpots) {
                if (s.barIndex == dataBarIndex) dataKg = s.y;
                if (hasRef && s.barIndex == 0) refTouchedY = s.y;
              }

              var refKg = refTouchedY;
              if (refKg == null && hasRef) {
                refKg = PercentilesData.getPercentileWeight(
                  isMale,
                  percentile,
                  _ageInMonths(touchedDate),
                );
              }

              final lines = <String>[dateStr];
              if (hasRef) {
                lines.add(
                  l10n.weightTooltipPercentile(
                    percentile.shortLabel,
                    formatWeightFromKg(refKg!, prefs, l10n),
                  ),
                );
              }
              if (dataKg != null) {
                lines.add(
                  l10n.weightTooltipWeighIn(
                    formatWeightFromKg(dataKg, prefs, l10n),
                  ),
                );
              }

              const tipStyle = TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.4,
              );
              final text = lines.join('\n');

              return touchedSpots.asMap().entries.map((e) {
                if (e.key == 0) {
                  return LineTooltipItem(
                    text,
                    tipStyle,
                    textAlign: TextAlign.left,
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}

class _WeightRecordTile extends ConsumerWidget {
  final WeightRecord record;
  final VoidCallback? onDelete;

  const _WeightRecordTile({required this.record, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefs =
        ref.watch(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final dateCode = dateFormatLanguageCode(context);
    final accent = AppTheme.weightHistoryAccent;
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
                decoration: AppTheme.historyRecordStripeDecoration(accent),
              ),
              Padding(
                padding: AppTheme.historyRecordLeadingPadding,
                child: Center(
                  child: CircleAvatar(
                    radius: AppTheme.historyRecordAvatarRadius,
                    backgroundColor: accent.withValues(
                      alpha: AppTheme.historyRecordAvatarAccentOpacity,
                    ),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      color: accent,
                      size: 22,
                    ),
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
                      Text(
                        formatWeightFromKg(record.weightKg, prefs, l10n),
                        style: AppTheme.historyRecordPrimaryValueStyle(accent),
                      ),
                      SizedBox(height: AppTheme.historyRecordDetailToDateGap),
                      Text(
                        DateFormat(
                          'd MMM, HH:mm',
                          dateCode,
                        ).format(record.dateTime),
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
                          onPressed: () =>
                              _showEditDialog(context, ref, record),
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
    WeightRecord record,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final prefs =
        ref.read(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final controller = TextEditingController(
      text: weightInputDisplayFromKg(record.weightKg, prefs),
    );
    var selectedDate = DateTime(
      record.dateTime.year,
      record.dateTime.month,
      record.dateTime.day,
    );
    var selectedTime = TimeOfDay.fromDateTime(record.dateTime);
    final editWeightFocus = FocusNode();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KeyboardActions(
        isDialog: true,
        config: KeyboardActionsConfig(
          keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
          keyboardBarColor: AppTheme.softPrimaryFill,
          nextFocus: false,
          actions: [
            KeyboardActionsItem(
              focusNode: editWeightFocus,
              displayArrows: false,
              toolbarButtons: [
                (node) => IconButton(
                  icon: const Icon(Icons.check_rounded),
                  color: AppTheme.palettePrimary,
                  tooltip: l10n.commonDone,
                  onPressed: () => node.unfocus(),
                ),
              ],
            ),
          ],
        ),
        child: StatefulBuilder(
          builder: (context, setState) => EditBottomSheet(
            title: l10n.weightEditTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  weightFieldLabelForPrefs(prefs, l10n),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  focusNode: editWeightFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => editWeightFocus.unfocus(),
                  onTapOutside: (_) => editWeightFocus.unfocus(),
                  decoration: InputDecoration(
                    hintText: weightEntryHint(prefs, l10n),
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
              final kg = parseWeightInputToKg(controller.text, prefs);
              if (kg != null && kg > 0 && kg <= 50) {
                final dt = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                await IsarService.updateWeightRecord(
                  record.copyWith(weightKg: kg, dateTime: dt),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
          ),
        ),
      ),
    ).whenComplete(() {
      editWeightFocus.dispose();
      controller.dispose();
    });
  }
}

/// Selector compacto en forma de píldora usado para filtrar la gráfica de peso
/// (rango temporal y percentil de referencia).
class _ChartFilterPill<T> extends StatelessWidget {
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const _ChartFilterPill({
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.softPrimaryFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.cardOutline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppTheme.palettePrimary,
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.palettePrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          items: values
              .map(
                (v) => DropdownMenuItem<T>(value: v, child: Text(labelOf(v))),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
