import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/models/baby_profile.dart';
import '../../../core/models/weight_record.dart';
import '../../../core/percentiles_data.dart';

class WeightView extends ConsumerStatefulWidget {
  const WeightView({super.key});

  @override
  ConsumerState<WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends ConsumerState<WeightView> {
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _registerWeight() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text.trim().replaceAll(',', '.'));
    if (weight == null || weight <= 0) return;

    await IsarService.addWeightRecord(WeightRecord(weightKg: weight, dateTime: DateTime.now()));
    _weightController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care, color: AppTheme.textDark, size: 28),
            const SizedBox(width: 8),
            const Text('Control de Bebé'),
          ],
        ),
      ),
      body: FutureBuilder<BabyProfile?>(
        future: IsarService.getBabyProfile(),
        builder: (context, babySnapshot) {
          final baby = babySnapshot.data;
          final isMale = baby?.isMale ?? true;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                            Icon(Icons.monitor_weight, color: AppTheme.primaryGreen),
                            const SizedBox(width: 8),
                            Text(
                              'Control de Peso',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Peso (kg)',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            color: AppTheme.textLight,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _weightController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        hintText: 'Ej: 4.5',
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'Introduce el peso';
                                        final n = double.tryParse(v.trim().replaceAll(',', '.'));
                                        if (n == null || n <= 0 || n > 50) return 'Peso inválido';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 32),
                                  child: ElevatedButton(
                                    onPressed: _registerWeight,
                                    child: const Text('Registrar'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        StreamBuilder<List<WeightRecord>>(
                          stream: IsarService.watchWeightRecords(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
                            }
                            final records = snapshot.data!;
                            final lastWeight = records.isNotEmpty ? records.first : null;
                            final prevWeight = records.length > 1 ? records[1] : null;
                            final change = lastWeight != null && prevWeight != null
                                ? lastWeight.weightKg - prevWeight.weightKg
                                : null;

                            return Row(
                              children: [
                                Expanded(
                                  child: _SummaryCard(
                                    title: 'Peso Actual',
                                    value: lastWeight != null
                                        ? '${lastWeight.weightKg.toStringAsFixed(2)} kg'
                                        : 'Sin datos',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SummaryCard(
                                    title: 'Cambio',
                                    value: change != null
                                        ? '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} kg'
                                        : '-',
                                    isPositive: change != null && change >= 0,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                StreamBuilder<List<WeightRecord>>(
                  stream: IsarService.watchWeightRecords(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Card(child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())));
                    }
                    final records = snapshot.data!;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Evolución',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child: _WeightChart(
                                records: records,
                                isMale: isMale,
                                birthDate: baby?.birthDate ?? DateTime.now(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                StreamBuilder<List<WeightRecord>>(
                  stream: IsarService.watchWeightRecords(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final records = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...records.map((r) => _WeightRecordTile(record: r)),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (value != '-' && value != 'Sin datos')
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 20,
                  color: isPositive ? AppTheme.primaryGreen : Colors.red,
                ),
              if (value != '-' && value != 'Sin datos') const SizedBox(width: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: value == 'Sin datos' || value == '-'
                          ? AppTheme.textLight
                          : (isPositive ? AppTheme.primaryGreen : Colors.red),
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
    return date.difference(birthDate).inDays / 30.44;
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

    final sortedRecords = List<WeightRecord>.from(records)..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final n = sortedRecords.length;

    // Eje X: índice (0, 1, 2...) para mostrar fechas en el eje inferior
    final spots = sortedRecords.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weightKg)).toList();

    final minWeight = records.map((r) => r.weightKg).reduce((a, b) => a < b ? a : b);
    final maxWeight = records.map((r) => r.weightKg).reduce((a, b) => a > b ? a : b);

    // Percentil P50 en el rango de edad de los registros
    final minMonth = _ageInMonths(sortedRecords.first.dateTime).clamp(0.0, 12.0);
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

    final refSpots = sortedRecords.asMap().entries.map((e) {
      final age = _ageInMonths(e.value.dateTime);
      return FlSpot(e.key.toDouble(), PercentilesData.getP50Weight(isMale, age));
    }).toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (n - 1).toDouble().clamp(1.0, double.infinity),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 10,
                ),
              ),
              interval: 0.5,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.round();
                if (idx >= 0 && idx < n) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('d/M').format(sortedRecords[idx].dateTime),
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              interval: 1,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  FlDotCirclePainter(radius: 4, color: AppTheme.textDark, strokeWidth: 0),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}

class _WeightRecordTile extends StatelessWidget {
  final WeightRecord record;

  const _WeightRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          '${record.weightKg.toStringAsFixed(2)} kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(DateFormat('d MMM yyyy, HH:mm').format(record.dateTime)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(context, record),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: record.id != null ? () => IsarService.deleteWeightRecord(record.id!) : () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WeightRecord record) {
    final controller = TextEditingController(text: record.weightKg.toString());
    var selectedDate = record.dateTime;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar peso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                ),
                const SizedBox(height: 16),
                const Text('Fecha y hora', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (date != null && ctx.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null && ctx.mounted) {
                        setState(() => selectedDate = DateTime(
                          date.year, date.month, date.day,
                          time.hour, time.minute,
                        ));
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Text(DateFormat('d MMM yyyy, HH:mm').format(selectedDate)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final w = double.tryParse(controller.text.trim().replaceAll(',', '.'));
                if (w != null && w > 0) {
                  await IsarService.updateWeightRecord(record.copyWith(weightKg: w, dateTime: selectedDate));
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
