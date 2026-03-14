import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/models/diaper_record.dart';
import '../../../core/models/enums.dart';

class DiapersView extends ConsumerStatefulWidget {
  const DiapersView({super.key});

  @override
  ConsumerState<DiapersView> createState() => _DiapersViewState();
}

class _DiapersViewState extends ConsumerState<DiapersView> {
  DiaperType _selectedType = DiaperType.dirty;

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
                    Icon(Icons.water_drop, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Control de Pañales',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Tipo de cambio',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Mojado',
                        icon: Icons.water_drop,
                        selected: _selectedType == DiaperType.wet,
                        onTap: () => setState(() => _selectedType = DiaperType.wet),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeButton(
                        label: 'Sucio',
                        icon: FontAwesomeIcons.poo,
                        selected: _selectedType == DiaperType.dirty,
                        onTap: () => setState(() => _selectedType = DiaperType.dirty),
                        isFaIcon: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeButton(
                        label: 'Ambos',
                        icon: Icons.sync,
                        selected: _selectedType == DiaperType.both,
                        onTap: () => setState(() => _selectedType = DiaperType.both),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerDiaper,
                    child: const Text('Registrar Cambio de Pañal'),
                  ),
                ),
                const SizedBox(height: 32),
                StreamBuilder<List<DiaperRecord>>(
                  stream: IsarService.watchDiaperRecords(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final records = snapshot.data!;
                    final sorted = List<DiaperRecord>.from(records)
                      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
                    final grouped = <String, List<DiaperRecord>>{};
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
                              '${sorted.length} cambios',
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
                          ...e.value.map((r) => _DiaperRecordTile(
                              record: r,
                              onDelete: () { if (r.id != null) IsarService.deleteDiaperRecord(r.id!); },
                            )),
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

  Future<void> _registerDiaper() async {
    await IsarService.addDiaperRecord(DiaperRecord(type: _selectedType, dateTime: DateTime.now()));
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isFaIcon;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.isFaIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primaryBlue : AppTheme.textLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: selected ? AppTheme.primaryBlue.withValues(alpha: 0.5) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            isFaIcon ? FaIcon(icon, size: 28, color: color) : Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppTheme.textDark : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaperRecordTile extends StatelessWidget {
  final DiaperRecord record;
  final VoidCallback onDelete;

  const _DiaperRecordTile({required this.record, required this.onDelete});

  void _showEditDialog(BuildContext context, DiaperRecord record, VoidCallback onDelete) {
    var selectedType = record.type;
    var selectedDate = record.dateTime;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar registro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: DiaperType.values.map((type) {
                    final (icon, label, isFa) = switch (type) {
                      DiaperType.wet => (Icons.water_drop, 'Mojado', false),
                      DiaperType.dirty => (FontAwesomeIcons.poo, 'Sucio', true),
                      DiaperType.both => (Icons.sync, 'Ambos', false),
                    };
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InkWell(
                          onTap: () => setState(() => selectedType = type),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType == type
                                  ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                isFa ? FaIcon(icon, size: 24) : Icon(icon, size: 24),
                                const SizedBox(height: 4),
                                Text(label, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
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
                await IsarService.updateDiaperRecord(record.copyWith(type: selectedType, dateTime: selectedDate));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (icon, label, isFa) = switch (record.type) {
      DiaperType.wet => (Icons.water_drop, 'Mojado', false),
      DiaperType.dirty => (FontAwesomeIcons.poo, 'Sucio', true),
      DiaperType.both => (Icons.sync, 'Ambos', false),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: isFa
            ? FaIcon(icon, color: AppTheme.primaryBlue)
            : Icon(icon, color: AppTheme.primaryBlue),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(DateFormat('d MMM, HH:mm').format(record.dateTime)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(context, record, onDelete),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
