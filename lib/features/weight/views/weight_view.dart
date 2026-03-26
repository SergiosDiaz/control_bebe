import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_app_title_bar.dart';
import '../../../core/theme/edit_dialog_theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/providers/record_stream_providers.dart';
import '../../../core/widgets/edit_dialog_fields.dart';
import '../../../core/widgets/stream_record_load_error.dart';
import '../../../core/widgets/edit_bottom_sheet.dart';
import '../../../core/models/baby_profile.dart';
import '../../../core/models/weight_record.dart';
import '../../../core/utils/baby_age_calendar.dart';
import '../../../core/percentiles_data.dart';
import '../../../core/utils/weight_daily_trend.dart';

class WeightView extends ConsumerStatefulWidget {
  final VoidCallback? onTitleTap;
  final VoidCallback onSettingsTap;
  final ScrollController? scrollController;

  const WeightView({
    super.key,
    this.onTitleTap,
    required this.onSettingsTap,
    this.scrollController,
  });

  @override
  ConsumerState<WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends ConsumerState<WeightView> {
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final Future<BabyProfile?> _babyProfileFuture =
      IsarService.getBabyProfile();
  final Set<int> _deletedWeightIds = {};

  /// Misma altura visual que [ElevatedButton] de esta fila.
  static const double _weightControlHeight = 56;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _registerWeight() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );
    if (weight == null || weight <= 0) return;

    // Limpiar el campo inmediatamente sin esperar confirmación de red
    _weightController.clear();
    unawaited(
      IsarService.addWeightRecord(
        WeightRecord(weightKg: weight, dateTime: DateTime.now()),
      ),
    );
  }

  void _deleteWeightRecord(int id) {
    setState(() => _deletedWeightIds.add(id));
    unawaited(IsarService.deleteWeightRecord(id).then((_) {
      if (mounted) setState(() => _deletedWeightIds.remove(id));
    }));
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(weightRecordsStreamProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainAppTitleBar(
              onTitleTap: widget.onTitleTap,
              onSettingsTap: widget.onSettingsTap,
            ),
            Expanded(
              child: FutureBuilder<BabyProfile?>(
                future: _babyProfileFuture,
                builder: (context, babySnapshot) {
                  final baby = babySnapshot.data;
                  final isMale = baby?.isMale ?? true;

                  return GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.opaque,
                    child: SingleChildScrollView(
                      controller: widget.scrollController,
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.screenEdgePadding,
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.monitor_weight,
                                        color: AppTheme.pageTitleIconWeight,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Control de Peso',
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
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Peso (kg)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                color: AppTheme.textLight,
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
                                                height: _weightControlHeight,
                                                child: TextFormField(
                                                  controller: _weightController,
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  expands: true,
                                                  maxLines: null,
                                                  minLines: null,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText: 'Ej: 4.5',
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                            ),
                                                        isDense: false,
                                                      ),
                                                  validator: (v) {
                                                    if (v == null ||
                                                        v.trim().isEmpty) {
                                                      return 'Introduce el peso';
                                                    }
                                                    final n = double.tryParse(
                                                      v.trim().replaceAll(
                                                        ',',
                                                        '.',
                                                      ),
                                                    );
                                                    if (n == null ||
                                                        n <= 0 ||
                                                        n > 50) {
                                                      return 'Peso inválido';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: SizedBox(
                                                height: _weightControlHeight,
                                                child: ElevatedButton(
                                                  onPressed: _registerWeight,
                                                  style: ElevatedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
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
                                                        VisualDensity.compact,
                                                  ),
                                                  child: const FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Registrar',
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                  const SizedBox(height: 24),
                                  recordsAsync.when(
                                    skipLoadingOnReload: true,
                                    data: _summaryRow,
                                    loading: () => const SizedBox(
                                      height: 80,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    error: (e, _) => StreamRecordLoadError(
                                      message:
                                          'No se pudieron cargar los pesos. Comprueba la conexión o reintenta.',
                                      onRetry: () => ref.invalidate(
                                        weightRecordsStreamProvider,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          recordsAsync.when(
                            skipLoadingOnReload: true,
                            data: (records) => Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Evolución',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 220,
                                      child: _WeightChart(
                                        records: records,
                                        isMale: isMale,
                                        birthDate:
                                            baby?.birthDate ?? DateTime.now(),
                                      ),
                                    ),
                                    if (records.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 3,
                                            margin: const EdgeInsets.only(
                                              top: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryGreen
                                                  .withValues(alpha: 0.4),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Línea de referencia: percentil 50 (mediana) de peso por edad según los estándares de crecimiento infantil de la OMS.',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: AppTheme.textLight,
                                                        height: 1.35,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Fuente: Organización Mundial de la Salud (OMS) — Child Growth Standards. who.int/tools/child-growth-standards',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: AppTheme.primaryBlue,
                                                        height: 1.35,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
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
                                  message:
                                      'No se pudo cargar la gráfica de peso.',
                                  onRetry: () => ref.invalidate(
                                    weightRecordsStreamProvider,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          recordsAsync.when(
                            skipLoadingOnReload: true,
                            data: (allRecords) {
                              final records = allRecords
                                  .where((r) => r.id == null || !_deletedWeightIds.contains(r.id))
                                  .toList();
                              return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Historial',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                if (records.isEmpty)
                                  Text(
                                    'Todavía no hay registros. Escribe el peso y pulsa «Registrar» arriba para añadir el primero.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textLight,
                                          height: 1.4,
                                        ),
                                  )
                                else
                                  ...records.map(
                                    (r) => _WeightRecordTile(
                                      record: r,
                                      onDelete: r.id != null ? () => _deleteWeightRecord(r.id!) : null,
                                    ),
                                  ),
                              ],
                            );},
                            loading: () => const SizedBox.shrink(),
                            error: (e, _) => StreamRecordLoadError(
                              message:
                                  'No se pudo cargar el historial de peso.',
                              onRetry: () =>
                                  ref.invalidate(weightRecordsStreamProvider),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(List<WeightRecord> records) {
    final lastWeight = records.isNotEmpty ? records.first : null;
    final dailyGPerDay = dailyWeightTrendLinearRegressionGramsPerDay(records);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Peso Actual',
            value: lastWeight != null
                ? '${lastWeight.weightKg.toStringAsFixed(2)} kg'
                : 'Sin datos',
            showTrendIcon: false,
            valueColor: lastWeight != null ? Colors.black : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Tendencia diaria',
            value: dailyGPerDay != null
                ? '${dailyGPerDay >= 0 ? '+' : ''}${dailyGPerDay.toStringAsFixed(1)} g'
                : '-',
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
  final bool isPositive;
  final bool showTrendIcon;

  /// Si no es null y hay valor, colorea el texto (p. ej. negro para peso actual).
  final Color? valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.isPositive = true,
    this.showTrendIcon = true,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final empty = value == 'Sin datos' || value == '-';
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
  final bool isMale;
  final DateTime birthDate;

  const _WeightChart({
    required this.records,
    required this.isMale,
    required this.birthDate,
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
    if (records.isEmpty) {
      return Center(
        child: Text(
          'Sin datos aún',
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

    // Percentil P50 en el rango de edad de los registros
    final minMonth = _ageInMonths(
      sortedRecords.first.dateTime,
    ).clamp(0.0, 12.0);
    final maxMonth = _ageInMonths(sortedRecords.last.dateTime).clamp(0.0, 12.0);
    final p50Min = PercentilesData.getP50Weight(isMale, minMonth);
    final p50Max = PercentilesData.getP50Weight(isMale, maxMonth);
    final p50Low = p50Min < p50Max ? p50Min : p50Max;
    final p50High = p50Min > p50Max ? p50Min : p50Max;

    // Rango Y: incluir siempre pesos y percentil para que la línea del percentil sea visible
    final dataMinY = minWeight < p50Low ? minWeight : p50Low;
    final dataMaxY = maxWeight > p50High ? maxWeight : p50High;
    final minY = (dataMinY - 0.5).clamp(0.0, 20.0);
    final maxY = (dataMaxY + 0.5).clamp(0.0, 20.0);

    final refSpots = sortedRecords.map((r) {
      final age = _ageInMonths(r.dateTime);
      return FlSpot(
        _daysSince(origin, r.dateTime),
        PercentilesData.getP50Weight(isMale, age),
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
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: TextStyle(color: AppTheme.textLight, fontSize: 10),
              ),
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
                    DateFormat('d/M').format(labelDate),
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
              color: AppTheme.primaryGreen.withValues(alpha: 0.4),
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.textDark,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.textDark,
                    strokeWidth: 0,
                  ),
            ),
            belowBarData: BarAreaData(show: false),
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
                'es',
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
                refKg = PercentilesData.getP50Weight(
                  isMale,
                  _ageInMonths(touchedDate),
                );
              }

              final lines = <String>[dateStr];
              if (hasRef) {
                lines.add('P50 (OMS): ${refKg!.toStringAsFixed(2)} kg');
              }
              if (dataKg != null) {
                lines.add('Pesada: ${dataKg.toStringAsFixed(2)} kg');
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

class _WeightRecordTile extends StatelessWidget {
  final WeightRecord record;
  final VoidCallback? onDelete;

  const _WeightRecordTile({required this.record, this.onDelete});

  @override
  Widget build(BuildContext context) {
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
                color: accent,
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
                        '${record.weightKg.toStringAsFixed(2)} kg',
                        style: AppTheme.historyRecordPrimaryValueStyle(accent),
                      ),
                      SizedBox(height: AppTheme.historyRecordDetailToDateGap),
                      Text(
                        DateFormat('d MMM, HH:mm').format(record.dateTime),
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
                          onPressed: () => _showEditDialog(context, record),
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

  void _showEditDialog(BuildContext context, WeightRecord record) {
    final controller = TextEditingController(text: record.weightKg.toString());
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
        builder: (context, setState) => EditBottomSheet(
          title: 'Editar peso',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Peso (kg)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Ej: 4.5',
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
            final w = double.tryParse(
              controller.text.trim().replaceAll(',', '.'),
            );
            if (w != null && w > 0) {
              final dt = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              await IsarService.updateWeightRecord(
                record.copyWith(weightKg: w, dateTime: dt),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
        ),
      ),
    );
  }
}
