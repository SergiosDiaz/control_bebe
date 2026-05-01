import 'package:flutter/material.dart';

/// Mantiene el aspecto del splash nativo hasta que Flutter esté listo.
/// Sin icono: el nativo ya lo mostró; evita la “segunda fase” con el mismo asset más pequeño.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Mismo color que `flutter_native_splash` en [pubspec.yaml].
  static const Color _holdColor = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _holdColor,
      body: SizedBox.expand(),
    );
  }
}
