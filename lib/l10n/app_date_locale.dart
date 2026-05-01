import 'package:flutter/material.dart';

/// Código de idioma para [DateFormat] e intl (p. ej. "es", "en").
String dateFormatLanguageCode(BuildContext context) {
  final loc = Localizations.localeOf(context);
  return loc.languageCode;
}
