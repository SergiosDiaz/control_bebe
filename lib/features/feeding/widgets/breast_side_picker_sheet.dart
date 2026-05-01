import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/models/enums.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Hoja inferior con animación para elegir pecho izquierdo o derecho antes del cronómetro.
Future<LactationSide?> showBreastSidePickerSheet(BuildContext context) {
  return showModalBottomSheet<LactationSide>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
    ),
    builder: (ctx) => const _BreastSidePickerBody(),
  );
}

class _BreastSidePickerBody extends StatefulWidget {
  const _BreastSidePickerBody();

  @override
  State<_BreastSidePickerBody> createState() => _BreastSidePickerBodyState();
}

class _BreastSidePickerBodyState extends State<_BreastSidePickerBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideLeft;
  late final Animation<Offset> _slideRight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slideLeft = Tween<Offset>(
      begin: const Offset(-0.12, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    ));
    _slideRight = Tween<Offset>(
      begin: const Offset(0.12, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.78, curve: Curves.easeOutCubic),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.feedingChooseSideTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.feedingChooseSideSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                SlideTransition(
                  position: _slideLeft,
                  child: _SideChoiceTile(
                    label: l10n.feedingLeft,
                    icon: const FaIcon(
                      FontAwesomeIcons.personBreastfeeding,
                      size: 28,
                      color: AppTheme.feedingHistoryLeftAccent,
                    ),
                    accent: AppTheme.feedingHistoryLeftAccent,
                    onTap: () => Navigator.pop(context, LactationSide.left),
                  ),
                ),
                const SizedBox(height: 12),
                SlideTransition(
                  position: _slideRight,
                  child: _SideChoiceTile(
                    label: l10n.feedingRight,
                    icon: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(-1, 1, 1),
                      child: const FaIcon(
                        FontAwesomeIcons.personBreastfeeding,
                        size: 28,
                        color: AppTheme.feedingHistoryRightAccent,
                      ),
                    ),
                    accent: AppTheme.feedingHistoryRightAccent,
                    onTap: () => Navigator.pop(context, LactationSide.right),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideChoiceTile extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color accent;
  final VoidCallback onTap;

  const _SideChoiceTile({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        splashColor: accent.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              SizedBox(width: 44, child: Center(child: icon)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: accent.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}
