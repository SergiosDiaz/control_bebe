import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Tema y estilos para los modales de edición (bottom sheet) de la app.
class EditDialogTheme {
  static ShapeBorder get bottomSheetShape => RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.dialogRadius)),
      );

  static EdgeInsets get contentPadding =>
      const EdgeInsets.fromLTRB(28, 8, 28, 0);

  static EdgeInsets get bottomPadding =>
      const EdgeInsets.fromLTRB(28, 20, 28, 28);

  static double get spacingBetweenSections => 24;

  static double get spacingBetweenFields => 20;

  static ButtonStyle get saveButtonStyle => FilledButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
      );
}
