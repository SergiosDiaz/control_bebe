import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/models/feeding_record.dart';
import '../../../core/models/lactation_timer.dart';
import '../../../core/models/enums.dart';
import 'bottle_view.dart';

class FeedingView extends ConsumerStatefulWidget {
  const FeedingView({super.key});

  @override
  ConsumerState<FeedingView> createState() => _FeedingViewState();
}

class _FeedingViewState extends ConsumerState<FeedingView> {
  Timer? _timer;
  LactationTimer? _activeTimer;

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
      if (timer != null) _startTick();
    }
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _startBreast(LactationSide side) async {
    await IsarService.startLactationTimer(side);
    if (mounted) {
      setState(() {
        _activeTimer = LactationTimer(side: side, startedAt: DateTime.now());
        _startTick();
      });
    }
  }

  Future<void> _stopBreast() async {
    final timer = await IsarService.stopLactationTimer();
    _timer?.cancel();
    if (mounted && timer != null) {
      setState(() => _activeTimer = null);
      await IsarService.addFeedingRecord(FeedingRecord(
        type: timer.side == LactationSide.left ? FeedingType.leftBreast : FeedingType.rightBreast,
        dateTime: timer.startedAt,
        durationSeconds: timer.elapsed.inSeconds,
      ));
    }
  }

  Future<void> _openBottle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BottleView()),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_drink, color: AppTheme.primaryPink),
                    const SizedBox(width: 8),
                    Text(
                      'Alimentación',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_activeTimer != null) ...[
                  _ActiveTimerBanner(
                    timer: _activeTimer!,
                    onStop: _stopBreast,
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _BreastButton(
                        label: 'Teta Izquierda',
                        icon: Icons.arrow_back,
                        onTap: () async {
                          if (_activeTimer?.side == LactationSide.left) {
                            await _stopBreast();
                          } else {
                            if (_activeTimer != null) await _stopBreast();
                            await _startBreast(LactationSide.left);
                          }
                        },
                        isActive: _activeTimer?.side == LactationSide.left,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BreastButton(
                        label: 'Teta Derecha',
                        icon: Icons.arrow_forward,
                        onTap: () async {
                          if (_activeTimer?.side == LactationSide.right) {
                            await _stopBreast();
                          } else {
                            if (_activeTimer != null) await _stopBreast();
                            await _startBreast(LactationSide.right);
                          }
                        },
                        isActive: _activeTimer?.side == LactationSide.right,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BottleButton(onTap: _openBottle),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                StreamBuilder<List<FeedingRecord>>(
                  stream: IsarService.watchFeedingRecords(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final records = snapshot.data!;
                    final sorted = List<FeedingRecord>.from(records)
                      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
                    final grouped = <String, List<FeedingRecord>>{};
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final yesterday = today.subtract(const Duration(days: 1));
                    for (final r in sorted) {
                      final d = r.dateTime;
                      final day = DateTime(d.year, d.month, d.day);
                      String key;
                      if (day == today) {
                        key = 'Hoy';
                      } else if (day == yesterday) {
                        key = 'Ayer';
                      } else {
                        key = DateFormat('d/M').format(d);
                      }
                      grouped.putIfAbsent(key, () => []).add(r);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Historial',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${sorted.length} toma${sorted.length != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...grouped.entries.expand((e) => [
                          Text(
                            e.key,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textLight,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ...e.value.map((r) => _FeedingRecordTile(record: r)),
                          const SizedBox(height: 16),
                        ]),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
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
    final minutes = timer.elapsed.inMinutes;
    final seconds = timer.elapsed.inSeconds % 60;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: AppTheme.primaryPink, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cronómetro activo: ${timer.side == LactationSide.left ? "Teta Izquierda" : "Teta Derecha"}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${minutes}m ${seconds}s',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onStop,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink),
            child: const Text('Parar'),
          ),
        ],
      ),
    );
  }
}

class _BreastButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _BreastButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isActive
              ? Border.all(color: AppTheme.primaryPink, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isActive ? AppTheme.primaryPink : AppTheme.textLight,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.primaryPink : AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BottleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.local_drink, size: 48, color: AppTheme.primaryBlue),
            const SizedBox(height: 8),
            Text(
              'Biberón',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedingRecordTile extends StatelessWidget {
  final FeedingRecord record;

  const _FeedingRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (record.type) {
      FeedingType.leftBreast => (Icons.timer, 'Teta Izquierda', AppTheme.primaryPink),
      FeedingType.rightBreast => (Icons.timer, 'Teta Derecha', AppTheme.primaryPink),
      FeedingType.bottle => (Icons.local_drink, 'Biberón', AppTheme.primaryBlue),
    };
    final duration = record.durationSeconds != null
        ? '${record.durationSeconds! ~/ 60}m ${record.durationSeconds! % 60}s'
        : null;
    final amount = record.amountMl != null ? '${record.amountMl} ml' : null;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            DateFormat('d MMM, HH:mm').format(record.dateTime),
            duration,
            amount,
          ].whereType<String>().join(' • '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(context, record),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: record.id != null ? () => IsarService.deleteFeedingRecord(record.id!) : () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, FeedingRecord record) {
    if (record.type == FeedingType.bottle) {
      final controller = TextEditingController(text: '${record.amountMl ?? 0}');
      var selectedDate = record.dateTime;
      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Editar biberón'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad (ml)'),
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
                  final ml = int.tryParse(controller.text.trim());
                  if (ml != null && ml > 0) {
                    await IsarService.updateFeedingRecord(record.copyWith(amountMl: ml, dateTime: selectedDate));
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      );
    } else {
      final controller = TextEditingController(
        text: '${(record.durationSeconds ?? 0) ~/ 60}',
      );
      var selectedDate = record.dateTime;
      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Editar duración'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duración (minutos)'),
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
                  final mins = int.tryParse(controller.text.trim());
                  if (mins != null && mins >= 0) {
                    await IsarService.updateFeedingRecord(record.copyWith(
                      durationSeconds: mins * 60,
                      dateTime: selectedDate,
                    ));
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
}
