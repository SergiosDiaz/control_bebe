import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/splash_screen.dart';
import 'core/db/isar_service.dart';
import 'core/firebase/firebase_service.dart';
import 'core/auth/auth_service.dart';
import 'features/auth/views/login_view.dart';
import 'features/onboarding/views/onboarding_view.dart';
import 'features/home/views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  await FirebaseService.initialize();
  await IsarService.initialize();
  runApp(const ProviderScope(child: ControlBebeApp()));
}

class ControlBebeApp extends ConsumerWidget {
  const ControlBebeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MiBebé Diario',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('es'),
      ],
      home: const AuthWrapper(),
    );
  }
}

/// Envuelve la app y muestra Login si no hay usuario autenticado.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FirebaseService.isAvailable) {
      // Firebase no configurado: arrancar sin auth (modo desarrollo)
      return const AppInitializer();
    }
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.data == null) {
          return const LoginView();
        }
        return const AppInitializer();
      },
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isReady = false;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    final needsOnboarding = await IsarService.needsOnboarding();
    if (mounted) {
      setState(() {
        _needsOnboarding = needsOnboarding;
        _isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const SplashScreen();
    }
    if (_needsOnboarding) {
      return const OnboardingView();
    }
    return const MainNavigation();
  }
}
