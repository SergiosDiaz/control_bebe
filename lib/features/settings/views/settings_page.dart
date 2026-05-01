import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:control_bebe/l10n/app_date_locale.dart';
import 'package:control_bebe/l10n/app_localizations.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/models/baby_profile.dart';
import '../../../core/models/measurement_units.dart';
import '../../../core/providers/baby_profile_provider.dart';
import '../../../core/providers/measurement_prefs_provider.dart';
import '../../../core/services/next_feeding_notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/feeding_interval_labels.dart';
import '../../../core/utils/measurement_display.dart';
import '../../../core/widgets/edit_dialog_fields.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final BabyProfile? initialBaby;
  final void Function(BabyProfile profile)? onProfileSaved;

  const SettingsPage({super.key, this.initialBaby, this.onProfileSaved});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  BabyProfile? _baby;
  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();
    _baby = widget.initialBaby;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_refreshBabyFromStorage());
    });
  }

  Future<void> _refreshBabyFromStorage() async {
    ref.invalidate(babyProfileProvider);
    final b = await ref.read(babyProfileProvider.future);
    if (!mounted || b == null) return;
    setState(() => _baby = b);
  }

  Future<void> _saveFeedingSchedule({
    required int intervalMinutes,
    required bool notifyNextFeeding,
  }) async {
    final b = _baby;
    if (b == null) return;
    var notify = notifyNextFeeding;
    if (notify) {
      final ok = await NextFeedingNotificationService.requestPermissions();
      if (!ok && mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsNotifyPermission)));
        notify = false;
      }
    }
    final clamped = intervalMinutes.clamp(30, 720);
    final updated = b.copyWith(
      expectedFeedingIntervalMinutes: clamped,
      notifyNextFeeding: notify,
    );
    await IsarService.saveBabyProfile(updated);
    ref.invalidate(babyProfileProvider);
    await NextFeedingNotificationService.syncFromStorage();
    if (mounted) {
      setState(() => _baby = updated);
      widget.onProfileSaved?.call(updated);
    }
  }

  Future<void> _editProfile() async {
    final baby =
        _baby ??
        BabyProfile(
          name: '',
          isMale: true,
          birthDate: DateTime.now().subtract(const Duration(days: 30)),
        );

    final result = await showModalBottomSheet<BabyProfile?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileSheet(baby: baby),
    );
    if (result != null && mounted) {
      await IsarService.saveBabyProfile(result);
      ref.invalidate(babyProfileProvider);
      setState(() => _baby = result);
      widget.onProfileSaved?.call(result);
    }
  }

  Future<void> _openFeedingIntervalSheet() async {
    final b = _baby;
    if (b == null) return;
    final l10n = AppLocalizations.of(context)!;
    final initialMinutes = b.expectedFeedingIntervalMinutes.clamp(30, 720);
    final selected = await _showFeedingIntervalPicker(
      context,
      initialMinutes: initialMinutes,
      l10n: l10n,
    );
    if (selected == null) return;
    await _saveFeedingSchedule(
      intervalMinutes: selected,
      notifyNextFeeding: b.notifyNextFeeding,
    );
  }

  Future<void> _openWeightUnitSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await ref.read(measurementPrefsProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<WeightUnitMode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OptionPickerSheet<WeightUnitMode>(
        title: l10n.settingsSheetUnitWeightTitle,
        intro: l10n.settingsUnitsIntro,
        currentValue: prefs.weight,
        options: [
          for (final mode in WeightUnitMode.values)
            _SheetOption(value: mode, label: weightSegmentLabel(mode, l10n)),
        ],
      ),
    );
    if (selected == null) return;
    await ref.read(measurementPrefsProvider.notifier).setWeight(selected);
  }

  Future<void> _openLiquidUnitSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await ref.read(measurementPrefsProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<LiquidUnitMode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OptionPickerSheet<LiquidUnitMode>(
        title: l10n.settingsSheetUnitLiquidTitle,
        intro: l10n.settingsUnitsIntro,
        currentValue: prefs.liquid,
        options: [
          for (final mode in LiquidUnitMode.values)
            _SheetOption(value: mode, label: liquidSegmentLabel(mode, l10n)),
        ],
      ),
    );
    if (selected == null) return;
    await ref.read(measurementPrefsProvider.notifier).setLiquid(selected);
  }

  Future<void> _openShareFamilySheet() async {
    final familyId = await IsarService.getFamilyId();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ShareFamilySheet(familyId: familyId),
    );
  }

  Future<void> _toggleNotify(bool on) async {
    final b = _baby;
    if (b == null) return;
    await _saveFeedingSchedule(
      intervalMinutes: b.expectedFeedingIntervalMinutes,
      notifyNextFeeding: on,
    );
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.dialogRadius),
        ),
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _deletingAccount = true);
    try {
      await AuthService.deleteAccount();
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _deletingAccount = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountError(e))));
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.dialogRadius),
        ),
        title: Text(l10n.signOutTitle),
        content: Text(l10n.signOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.signOutConfirm),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await AuthService.signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.signOutError(e))));
        }
        return;
      }
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final baby = _baby;
    final prefs = ref.watch(measurementPrefsProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppTheme.screenEdgePadding,
          12,
          AppTheme.screenEdgePadding,
          24 + AppTheme.safeBottomPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========== BEBÉ ==========
            _SettingsGroup(
              title: l10n.settingsGroupBaby,
              rows: [
                _SettingsRow(
                  icon: Icons.person_outline,
                  iconColor: AppTheme.palettePrimary,
                  title: l10n.settingsRowProfileTitle,
                  subtitle: l10n.settingsRowProfileSubtitle,
                  trailing: const _RowChevron(),
                  onTap: _editProfile,
                ),
                _SettingsRow(
                  icon: Icons.schedule_outlined,
                  iconColor: AppTheme.palettePrimary,
                  title: l10n.settingsRowFeedingInterval,
                  trailing: _RowValue(
                    text: baby == null
                        ? l10n.settingsValueNotSet
                        : feedingIntervalOptionLabel(
                            l10n,
                            baby.expectedFeedingIntervalMinutes.clamp(30, 720),
                          ),
                    chevron: baby != null,
                  ),
                  onTap: baby == null ? null : _openFeedingIntervalSheet,
                ),
                _SettingsRow(
                  icon: Icons.notifications_outlined,
                  iconColor: AppTheme.palettePrimary,
                  title: l10n.settingsRowFeedingNotify,
                  subtitle: l10n.settingsNotifySubtitle,
                  trailing: Switch.adaptive(
                    value: baby?.notifyNextFeeding ?? false,
                    onChanged: baby == null ? null : _toggleNotify,
                  ),
                  onTap: baby == null
                      ? null
                      : () => _toggleNotify(!baby.notifyNextFeeding),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ========== PREFERENCIAS ==========
            _SettingsGroup(
              title: l10n.settingsGroupPreferences,
              rows: [
                _SettingsRow(
                  icon: Icons.monitor_weight_outlined,
                  iconColor: AppTheme.palettePrimary,
                  title: l10n.settingsRowUnitWeight,
                  trailing: _RowValue(
                    text: prefs == null
                        ? l10n.settingsValueNotSet
                        : weightSegmentLabel(prefs.weight, l10n),
                    chevron: true,
                  ),
                  onTap: prefs == null ? null : _openWeightUnitSheet,
                ),
                _SettingsRow(
                  icon: Icons.local_drink_outlined,
                  iconColor: AppTheme.palettePrimary,
                  title: l10n.settingsRowUnitLiquid,
                  trailing: _RowValue(
                    text: prefs == null
                        ? l10n.settingsValueNotSet
                        : liquidSegmentLabel(prefs.liquid, l10n),
                    chevron: true,
                  ),
                  onTap: prefs == null ? null : _openLiquidUnitSheet,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ========== FAMILIA ==========
            _SettingsGroup(
              title: l10n.settingsGroupFamily,
              rows: [
                _SettingsRow(
                  icon: Icons.qr_code_2_outlined,
                  iconColor: AppTheme.palettePrimary,
                  title: l10n.settingsRowFamilyShare,
                  subtitle: l10n.settingsRowFamilyShareSubtitle,
                  trailing: const _RowChevron(),
                  onTap: _openShareFamilySheet,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ========== CUENTA ==========
            _SettingsGroup(
              title: l10n.settingsGroupAccount,
              rows: [
                _SettingsRow(
                  icon: Icons.logout,
                  iconColor: AppTheme.palettePrimary,
                  title: l10n.settingsSignOutButton,
                  subtitle: l10n.settingsSignOutRowSubtitle,
                  trailing: const _RowChevron(),
                  onTap: _signOut,
                ),
                _SettingsRow(
                  icon: Icons.delete_forever_outlined,
                  iconColor: Theme.of(context).colorScheme.error,
                  title: l10n.settingsDeleteAccount,
                  subtitle: l10n.settingsDeleteAccountRowSubtitle,
                  titleColor: Theme.of(context).colorScheme.error,
                  trailing: _deletingAccount
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const _RowChevron(),
                  onTap: _deletingAccount ? null : _deleteAccount,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Componentes reutilizables (estilo "iOS Settings")
// ============================================================

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _SettingsGroup({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 12,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1) const _RowDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: Divider(height: 1, thickness: 0.6, color: AppTheme.fieldBorder),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final effectiveTitleColor =
        titleColor ?? (isEnabled ? AppTheme.textDark : AppTheme.textLight);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: effectiveTitleColor,
                      fontSize: 15,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _RowValue extends StatelessWidget {
  final String text;
  final bool chevron;

  const _RowValue({required this.text, this.chevron = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (chevron) ...const [
          SizedBox(width: 4),
          _RowChevron(),
        ],
      ],
    );
  }
}

class _RowChevron extends StatelessWidget {
  const _RowChevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.chevron_right,
      color: AppTheme.textLight.withValues(alpha: 0.7),
      size: 14,
    );
  }
}

// ============================================================
// Bottom sheets reutilizables
// ============================================================

class _SheetContainer extends StatelessWidget {
  final String title;
  final String? intro;
  final Widget child;
  /// Si es true, cabecera + [child] van en un [ListView] con [shrinkWrap] y
  /// altura máxima acotada (no rellena toda la pantalla en vacío).
  final bool scrollBody;

  const _SheetContainer({
    required this.title,
    this.intro,
    required this.child,
    this.scrollBody = false,
  });

  List<Widget> _header(BuildContext context) {
    return [
      Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.fieldBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.textHeading,
        ),
      ),
      if (intro != null) ...[
        const SizedBox(height: 6),
        Text(
          intro!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
            height: 1.35,
          ),
        ),
      ],
      const SizedBox(height: 16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.dialogRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: scrollBody
              ? Builder(
                  builder: (context) {
                    final mq = MediaQuery.of(context);
                    final maxH = (mq.size.height -
                            mq.viewInsets.bottom -
                            mq.padding.top -
                            32)
                        .clamp(240.0, 9000.0);
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxH),
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: [
                          ..._header(context),
                          child,
                        ],
                      ),
                    );
                  },
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._header(context),
                    child,
                  ],
                ),
        ),
      ),
    );
  }
}

class _SheetOption<T> {
  final T value;
  final String label;
  const _SheetOption({required this.value, required this.label});
}

class _OptionPickerSheet<T> extends StatelessWidget {
  final String title;
  final String? intro;
  final T currentValue;
  final List<_SheetOption<T>> options;

  const _OptionPickerSheet({
    required this.title,
    this.intro,
    required this.currentValue,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      title: title,
      intro: intro,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.6,
                indent: 12,
                endIndent: 12,
                color: AppTheme.fieldBorder,
              ),
            InkWell(
              onTap: () => Navigator.pop(context, options[i].value),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        options[i].label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: options[i].value == currentValue
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: options[i].value == currentValue
                              ? AppTheme.palettePrimary
                              : AppTheme.textDark,
                        ),
                      ),
                    ),
                    if (options[i].value == currentValue)
                      Icon(
                        CupertinoIcons.checkmark,
                        color: AppTheme.palettePrimary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Picker estilo iOS (rueda) para el intervalo entre tomas.
/// Dos columnas: horas (0..12) y minutos (0 o 30). Sin loop. El valor
/// guardado se hace clamp(30, 720) en `_saveFeedingSchedule`.
Future<int?> _showFeedingIntervalPicker(
  BuildContext context, {
  required int initialMinutes,
  required AppLocalizations l10n,
}) {
  const maxHours = 12;
  const minuteOptions = [0, 30];

  var selectedHours = (initialMinutes ~/ 60).clamp(0, maxHours);
  var selectedMinIndex = (initialMinutes % 60) >= 30 ? 1 : 0;

  int currentTotal() =>
      selectedHours * 60 + minuteOptions[selectedMinIndex];

  return showCupertinoModalPopup<int>(
    context: context,
    builder: (ctx) {
      final labelStyle = TextStyle(
        fontSize: 18,
        color: CupertinoColors.label.resolveFrom(ctx),
      );
      return Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(ctx),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.commonCancel),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => Navigator.pop(ctx, currentTotal()),
                      child: Text(l10n.commonDone),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 216,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        looping: false,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedHours,
                        ),
                        onSelectedItemChanged: (i) => selectedHours = i,
                        children: [
                          for (var h = 0; h <= maxHours; h++)
                            Center(
                              child: Text(
                                '$h ${l10n.timeSuffixHour}',
                                style: labelStyle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        looping: false,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMinIndex,
                        ),
                        onSelectedItemChanged: (i) => selectedMinIndex = i,
                        children: [
                          for (final m in minuteOptions)
                            Center(
                              child: Text(
                                '$m ${l10n.timeSuffixMinute}',
                                style: labelStyle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ShareFamilySheet extends StatelessWidget {
  final String? familyId;

  const _ShareFamilySheet({required this.familyId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasFamily = familyId != null && familyId!.isNotEmpty;
    return _SheetContainer(
      title: l10n.settingsSheetShareTitle,
      intro: hasFamily
          ? l10n.settingsShareQrIntro
          : l10n.settingsFamilyFirebaseOnly,
      child: hasFamily
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
                    border: Border.all(color: AppTheme.fieldBorder),
                  ),
                  child: QrImageView(
                    data: familyId!,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppTheme.textDark,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.settingsQrCaption,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textLight),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

// ============================================================
// Sheet de edición de perfil
// ============================================================

class _EditProfileSheet extends StatefulWidget {
  final BabyProfile baby;

  const _EditProfileSheet({required this.baby});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late bool _isMale;
  late DateTime _birthDate;

  @override
  void initState() {
    super.initState();
    final baby = widget.baby;
    _nameController = TextEditingController(text: baby.name);
    _heightController = TextEditingController(
      text: _formatHeight(baby.heightCm),
    );
    _isMale = baby.isMale;
    _birthDate = baby.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String _formatHeight(double? heightCm) {
    if (heightCm == null) return '';
    return heightCm == heightCm.roundToDouble()
        ? '${heightCm.round()}'
        : '$heightCm';
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final heightRaw = _heightController.text.trim().replaceAll(',', '.');
    double? heightCm;
    if (heightRaw.isEmpty) {
      heightCm = null;
    } else {
      heightCm = double.tryParse(heightRaw);
      if (heightCm == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.heightInvalid)));
        return;
      }
      if (heightCm < 25 || heightCm > 120) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.heightRangeError)));
        return;
      }
    }

    final profile = widget.baby.copyWith(
      name: name,
      isMale: _isMale,
      birthDate: _birthDate,
      heightCm: heightCm,
      setHeightCm: true,
    );
    Navigator.pop(context, profile);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppTheme.textDark,
    );
    final fieldDecoration = BoxDecoration(
      color: AppTheme.fieldBackground,
      borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
      border: Border.all(color: AppTheme.fieldBorder),
    );

    final form = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.labelName, style: labelStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: fieldDecoration,
          child: Row(
            children: [
              Icon(Icons.badge_outlined, color: AppTheme.primaryBlue, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.textDark),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.labelGender, style: labelStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderChip(
                label: l10n.commonGenderBoy,
                icon: Icons.male_outlined,
                selected: _isMale,
                onTap: () => setState(() => _isMale = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderChip(
                label: l10n.commonGenderGirl,
                icon: Icons.female_outlined,
                selected: !_isMale,
                onTap: () => setState(() => _isMale = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.heightFieldLabel, style: labelStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: fieldDecoration,
          child: Row(
            children: [
              Icon(
                Icons.straighten_outlined,
                color: AppTheme.primaryBlue,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: l10n.heightFieldHint,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.textDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.settingsBirthDate, style: labelStyle),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final firstDate = DateTime.now().subtract(
              const Duration(days: 365 * 2),
            );
            final lastDate = DateTime.now();
            final initial = _birthDate.isBefore(firstDate)
                ? firstDate
                : (_birthDate.isAfter(lastDate) ? lastDate : _birthDate);
            final Future<DateTime?> futureDate;
            if (defaultTargetPlatform == TargetPlatform.iOS) {
              futureDate = showCupertinoDatePickerSheet(
                context,
                initial,
                firstDate,
                lastDate,
                l10n,
              );
            } else {
              futureDate = showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: firstDate,
                lastDate: lastDate,
                locale: locale,
              );
            }
            final date = await futureDate;
            if (date != null && mounted) {
              setState(() => _birthDate = date);
            }
          },
          borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: fieldDecoration,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat(
                      'd MMM yyyy',
                      dateFormatLanguageCode(context),
                    ).format(_birthDate),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.textDark),
                  ),
                ),
                const _RowChevron(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text(l10n.commonCancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _save,
                child: Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ],
    );

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: _SheetContainer(
            scrollBody: true,
            title: l10n.editBabyProfileTitle,
            child: form,
          ),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryBlue.withValues(alpha: 0.15)
              : AppTheme.fieldBackground,
          borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
          border: Border.all(
            color: selected ? AppTheme.primaryBlue : AppTheme.fieldBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? AppTheme.primaryBlue : AppTheme.textLight,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.primaryBlue : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
