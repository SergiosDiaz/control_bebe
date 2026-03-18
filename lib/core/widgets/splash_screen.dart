import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pantalla de carga con el icono de la app. Se muestra mientras la app inicializa.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Image.asset(
          'assets/images/app_icon.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.child_care,
            size: 120,
            color: AppTheme.primaryPink,
          ),
        ),
      ),
    );
  }
}
