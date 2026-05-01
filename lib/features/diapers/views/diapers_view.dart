import 'dart:async';

import 'package:control_bebe/l10n/app_date_locale.dart';
import 'package:control_bebe/l10n/app_localizations.dart';
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
import '../../../core/widgets/stream_record_load_error.dart';
import '../../../core/widgets/confirm_delete_record_dialog.dart';
import '../../../core/models/diaper_record.dart';
import '../../../core/models/enums.dart';
import '../../../core/utils/history_calendar_window.dart';

class DiapersView extends ConsumerStatefulWidget {
  final VoidCallback? onTitleTap;
  final VoidCallback onSettingsTap;
  final ScrollController? scrollController;
  final bool isActiveTab;

  const DiapersView({
    super.key,
    this.onTitleTap,
    required this.onSettingsTap,
    this.scrollController,
    this.isActiveTab = true,
  });

  @override
  ConsumerState<DiapersView> createState() => _DiapersViewState();
}

class _DiapersViewState extends ConsumerState<DiapersView> {
  DiaperType _selectedType = DiaperType.wet;
  DiaperRecord? _optimisticRecord;
  DateTime _lastHistoryScrollExpand = DateTime.fromMillisecondsSinceEpoch(0);

  List<DiaperRecord> _mergeOptimistic(List<DiaperRecord> records) {
    final opt = _optimisticRecord;
    if (opt == null) return records;
    final match = records.any(
      (r) =>
          r.type == opt.type &&
          r.dateTime.difference(opt.dateTime).inSeconds.abs() < 2,
    );
    if (match) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _optimisticRecord = null);
      });
      return records;
    }
    return [opt, ...records];
  }

  bool _onDiaperHistoryScrollNotification(ScrollNotification n) {
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
    final days = ref.read(diaperHistoryFirestoreDaysProvider);
    if (days >= kHistoryPaginationMaxDays) {
      return false;
    }
    _lastHistoryScrollExpand = now;
    unawaited(_maybeExpandDiaperHistoryWindow());
    return false;
  }

  Future<void> _maybeExpandDiaperHistoryWindow() async {
    final hasOlder = await ref.read(hasOlderDiaperRecordsProvider.future);
    if (!mounted || !hasOlder) return;
    final days = ref.read(diaperHistoryFirestoreDaysProvider);
    if (days >= kHistoryPaginationMaxDays) return;
    ref.read(diaperHistoryFirestoreDaysProvider.notifier).state =
        days + kHistoryPaginationStepDays;
  }

  Widget _diaperHistoryColumn(
    BuildContext context,
    List<DiaperRecord> records, {
    required bool hasOlderOutsideWindow,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final dateCode = dateFormatLanguageCode(context);
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
                : l10n.diapersHistoryEmpty,
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
                      ? l10n.diaperChangeCountOne
                      : l10n.diaperChangeCountN(e.value.length),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...e.value.map(
              (r) => _DiaperRecordTile(
                record: r,
                onDelete: () async {
                  final ok = await confirmDeleteRecord(context);
                  if (!context.mounted || !ok || r.id == null) return;
                  IsarService.deleteDiaperRecord(r.id!);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final diaperRecordsAsync = widget.isActiveTab
        ? ref.watch(diaperRecordsStreamProvider)
        : ref.read(diaperRecordsStreamProvider);
    final hasOlderAsync = widget.isActiveTab
        ? ref.watch(hasOlderDiaperRecordsProvider)
        : ref.read(hasOlderDiaperRecordsProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onDiaperHistoryScrollNotification,
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
                            Icon(
                              MdiIcons.humanBabyChangingTable,
                              color: AppTheme.pageTitleIconDiapers,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.diapersTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.diapersChangeType,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _TypeButton(
                                label: l10n.diaperWet,
                                icon: Icons.water_drop,
                                selected: _selectedType == DiaperType.wet,
                                onTap: () => setState(
                                  () => _selectedType = DiaperType.wet,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TypeButton(
                                label: l10n.diaperDirty,
                                icon: FontAwesomeIcons.poo,
                                selected: _selectedType == DiaperType.dirty,
                                onTap: () => setState(
                                  () => _selectedType = DiaperType.dirty,
                                ),
                                isFaIcon: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TypeButton(
                                label: l10n.diaperBoth,
                                icon: Icons.sync,
                                selected: _selectedType == DiaperType.both,
                                onTap: () => setState(
                                  () => _selectedType = DiaperType.both,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _registerDiaper,
                            child: Text(l10n.diapersRegisterButton),
                          ),
                        ),
                        const SizedBox(height: 32),
                        diaperRecordsAsync.when(
                          skipLoadingOnReload: true,
                          data: (records) {
                            final merged = _mergeOptimistic(records);
                            final hasOlder = hasOlderAsync.maybeWhen(
                              data: (v) => v,
                              orElse: () => false,
                            );
                            return _diaperHistoryColumn(
                              context,
                              merged,
                              hasOlderOutsideWindow: hasOlder,
                            );
                          },
                          loading: () {
                            if (_optimisticRecord != null) {
                              return _diaperHistoryColumn(
                                context,
                                [_optimisticRecord!],
                                hasOlderOutsideWindow: hasOlderAsync.maybeWhen(
                                  data: (v) => v,
                                  orElse: () => false,
                                ),
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          error: (e, _) => StreamRecordLoadError(
                            message: l10n.diapersStreamError,
                            onRetry: () =>
                                ref.invalidate(diaperRecordsStreamProvider),
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
    final iconColor = selected ? AppTheme.primaryBlue : AppTheme.textLight;
    final surface = selected ? const Color(0xFFF5F5F5) : Colors.white;
    final borderColor = selected
        ? AppTheme.primaryBlue.withValues(alpha: 0.55)
        : AppTheme.fieldBorder;
    final borderWidth = selected ? 2.0 : 1.5;

    return Material(
      color: surface,
      elevation: selected ? 2 : 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        splashColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
        highlightColor: AppTheme.primaryBlue.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
          child: Column(
            children: [
              isFaIcon
                  ? FaIcon(icon, size: 28, color: iconColor)
                  : Icon(icon, size: 28, color: iconColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppTheme.textDark : AppTheme.textLight,
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

class _DiaperRecordTile extends StatelessWidget {
  final DiaperRecord record;
  final VoidCallback onDelete;

  const _DiaperRecordTile({required this.record, required this.onDelete});

  void _showEditDialog(
    BuildContext context,
    DiaperRecord record,
    VoidCallback onDelete,
  ) {
    final l10n = AppLocalizations.of(context)!;
    var selectedType = record.type;
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
          title: l10n.diapersEditRecord,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.diapersTypeLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: DiaperType.values.map((type) {
                  final (icon, label, isFa) = switch (type) {
                    DiaperType.wet => (Icons.water_drop, l10n.diaperWet, false),
                    DiaperType.dirty => (
                      FontAwesomeIcons.poo,
                      l10n.diaperDirty,
                      true,
                    ),
                    DiaperType.both => (Icons.sync, l10n.diaperBoth, false),
                  };
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: InkWell(
                        onTap: () => setState(() => selectedType = type),
                        borderRadius: BorderRadius.circular(
                          AppTheme.fieldRadius,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: selectedType == type
                                ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                                : AppTheme.fieldBackground,
                            borderRadius: BorderRadius.circular(
                              AppTheme.fieldRadius,
                            ),
                            border: Border.all(
                              color: selectedType == type
                                  ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                                  : AppTheme.fieldBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              isFa
                                  ? FaIcon(icon, size: 24)
                                  : Icon(icon, size: 24),
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
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            await IsarService.updateDiaperRecord(
              record.copyWith(type: selectedType, dateTime: dt),
            );
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateCode = dateFormatLanguageCode(context);
    final (icon, label, isFa, accentColor) = switch (record.type) {
      DiaperType.wet => (
        Icons.water_drop,
        l10n.diaperWet,
        false,
        AppTheme.diaperHistoryWetAccent,
      ),
      DiaperType.dirty => (
        FontAwesomeIcons.poo,
        l10n.diaperDirty,
        true,
        AppTheme.diaperHistoryDirtyAccent,
      ),
      DiaperType.both => (
        Icons.sync,
        l10n.diaperBoth,
        false,
        AppTheme.diaperHistoryBothAccent,
      ),
    };
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
                    child: isFa
                        ? FaIcon(icon, color: accentColor, size: 20)
                        : Icon(icon, color: accentColor, size: 22),
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
                        label,
                        style: AppTheme.historyRecordTypeTitleStyle(
                          accentColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.historyRecordAfterTitleGap),
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
                              _showEditDialog(context, record, onDelete),
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
}
