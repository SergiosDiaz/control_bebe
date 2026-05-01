import 'package:control_bebe/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/measurement_units.dart';
import '../../../core/providers/measurement_prefs_provider.dart';
import '../../../core/utils/measurement_display.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/services/next_feeding_notification_service.dart';
import '../../../core/models/feeding_record.dart';
import '../../../core/models/enums.dart';

class BottleView extends ConsumerStatefulWidget {
  const BottleView({super.key});

  @override
  ConsumerState<BottleView> createState() => _BottleViewState();
}

class _BottleViewState extends ConsumerState<BottleView> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = ref.read(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final ml = parseVolumeInputToMl(_controller.text, prefs);
    if (ml == null || ml <= 0 || ml > kMaxReasonableVolumeMl) return;

    await IsarService.addFeedingRecord(FeedingRecord(
      type: FeedingType.bottle,
      dateTime: DateTime.now(),
      amountMl: ml,
    ));
    await NextFeedingNotificationService.syncFromStorage();

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.watch(measurementPrefsProvider).valueOrNull ??
        MeasurementPrefs.defaultsForDispatcher();
    final liquidLabel = prefs.liquid == LiquidUnitMode.milliliters
        ? l10n.feedingAmountMl
        : l10n.liquidFieldLabelFlOz;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(l10n.bottleTitle),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.screenEdgePadding,
                  24,
                  AppTheme.screenEdgePadding,
                  16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        liquidLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: bottleVolumeHint(prefs, l10n),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.bottleValidatorEmpty;
                          }
                          final parsed = parseVolumeInputToMl(v, prefs);
                          if (parsed == null ||
                              parsed <= 0 ||
                              parsed > kMaxReasonableVolumeMl) {
                            return l10n.bottleValidatorInvalid;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: AppTheme.background,
              elevation: 8,
              shadowColor: Colors.black26,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.screenEdgePadding,
                    12,
                    AppTheme.screenEdgePadding,
                    12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(l10n.commonSave),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
