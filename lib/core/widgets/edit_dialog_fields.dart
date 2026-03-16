import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// Campo táctil para seleccionar fecha. Diseñado para iOS (targets grandes).
class DatePickerField extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return _TapField(
      icon: Icons.calendar_today,
      label: 'Fecha',
      value: DateFormat('d MMM yyyy', 'es').format(value),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('es', 'ES'),
        );
        if (date != null) onChanged(date);
      },
    );
  }
}

/// Campo táctil para seleccionar hora. Diseñado para iOS.
class TimePickerField extends StatelessWidget {
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;
  final String label;

  const TimePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Hora',
  });

  @override
  Widget build(BuildContext context) {
    final text = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return _TapField(
      icon: Icons.access_time,
      label: label,
      value: text,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: value,
        );
        if (time != null) onChanged(time);
      },
    );
  }
}

class _TapField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TapField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: AppTheme.fieldBackground,
                borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                border: Border.all(color: AppTheme.fieldBorder, width: 1),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textDark,
                          ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.textLight, size: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
