import 'dart:convert';

import 'package:image_picker/image_picker.dart';

/// Selecciona una foto de la galería y la devuelve como data URL base64.
/// Usa compresión del picker para reducir tamaño. Retorna null si cancela o hay error.
Future<String?> pickAndProcessBabyPhoto() async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 400,
    maxHeight: 400,
    imageQuality: 80,
  );
  if (xFile == null) return null;

  final bytes = await xFile.readAsBytes();
  return 'data:image/jpeg;base64,${base64Encode(bytes)}';
}
