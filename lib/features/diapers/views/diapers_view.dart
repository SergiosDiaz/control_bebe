import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/edit_dialog_theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/widgets/edit_dialog_fields.dart';
import '../../../core/widgets/edit_bottom_sheet.dart';
import '../../../core/models/diaper_record.dart';
import '../../../core/models/enums.dart';

class DiapersView extends ConsumerStatefulWidget {
  final VoidCallback? onTitleTap;
  final ScrollController? scrollController;

  const DiapersView({super.key, this.onTitleTap, this.scrollController});

  @override
  ConsumerState<DiapersView> createState() => _DiapersViewState();
}

class _DiapersViewState extends ConsumerState<DiapersView> {
  DiaperType _selectedType = DiaperType.dirty;
  DiaperRecord? _optimisticRecord;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: InkWell(
          onTap: widget.onTitleTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppTheme.titleIconAsset, width: 22, height: 22, fit: BoxFit.contain),
                const SizedBox(width: 6),
                Flexible(child: Text('MiBebé Diario', overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.humanBabyChangingTable, color: AppTheme.primaryBlue),
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
                    if (!snapshot.hasData && _optimisticRecord == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var records = snapshot.data ?? [];
                    if (_optimisticRecord != null) {
                      final match = records.any((r) =>
                          r.type == _optimisticRecord!.type &&
                          r.dateTime.difference(_optimisticRecord!.dateTime).inSeconds.abs() < 2);
                      if (match) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _optimisticRecord = null);
                        });
                      } else {
                        records = [_optimisticRecord!, ...records];
                      }
                    }
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
                        Text(
                          'Historial',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...grouped.entries.expand((e) => [
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
                                '${e.value.length} cambio${e.value.length != 1 ? 's' : ''}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                              ),
                            ],
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
    final record = DiaperRecord(type: _selectedType, dateTime: DateTime.now());
    setState(() => _optimisticRecord = record);
    await IsarService.addDiaperRecord(record);
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
    var selectedDate = DateTime(record.dateTime.year, record.dateTime.month, record.dateTime.day);
    var selectedTime = TimeOfDay.fromDateTime(record.dateTime);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => EditBottomSheet(
          title: 'Editar registro',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tipo',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
              ),
              const SizedBox(height: 10),
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
                        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: selectedType == type
                                ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                                : AppTheme.fieldBackground,
                            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                            border: Border.all(
                              color: selectedType == type
                                  ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                                  : AppTheme.fieldBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              isFa ? FaIcon(icon, size: 24) : Icon(icon, size: 24),
                              const SizedBox(height: 6),
                              Text(label, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
            final dt = DateTime(
              selectedDate.year, selectedDate.month, selectedDate.day,
              selectedTime.hour, selectedTime.minute,
            );
            await IsarService.updateDiaperRecord(record.copyWith(type: selectedType, dateTime: dt));
            if (ctx.mounted) Navigator.pop(ctx);
          },
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
