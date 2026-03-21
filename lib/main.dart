import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/db/isar_service.dart';
import 'core/services/next_feeding_notification_service.dart';
import 'core/firebase/firebase_service.dart';
import 'core/auth/auth_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  await FirebaseService.initialize();
  await IsarService.initialize();
  await NextFeedingNotificationService.init();
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
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemUiForLightBackground,
          child: child ?? const SizedBox.shrink(),
        );
      },
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
