import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/isar_service.dart';
import '../firebase/firebase_service.dart';
import '../services/next_feeding_notification_service.dart';
import '../widgets/splash_screen.dart';
import 'auth_service.dart';
import '../../features/auth/views/family_qr_join_screen.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/home/views/main_navigation.dart';
import '../../features/onboarding/views/onboarding_view.dart';

/// Raíz de autenticación: login, invitado QR o app según sesión Firebase.
/// Debe permanecer como primera ruta del [Navigator] para que [authStateChanges]
/// siga activo al cerrar sesión.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FirebaseService.isAvailable) {
      return const AppInitializer();
    }
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.data == null) {
          return const LoginView();
        }
        final user = snapshot.data!;
        if (user.isAnonymous) {
          return const _AnonymousGuestGate();
        }
        return const AppInitializer();
      },
    );
  }
}

class _AnonymousGuestGate extends StatefulWidget {
  const _AnonymousGuestGate();

  @override
  State<_AnonymousGuestGate> createState() => _AnonymousGuestGateState();
}

class _AnonymousGuestGateState extends State<_AnonymousGuestGate> {
  Future<bool>? _familyCheck;

  @override
  void initState() {
    super.initState();
    _familyCheck = _userHasFamilyId();
  }

  Future<bool> _userHasFamilyId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final id = doc.data()?['familyId'] as String?;
    return id != null && id.isNotEmpty;
  }

  Future<void> _onQrScanned(String familyId) async {
    await IsarService.joinFamily(familyId);
    await IsarService.completeOnboarding();
    await IsarService.initialize();
    if (mounted) {
      setState(() {
        _familyCheck = _userHasFamilyId();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _familyCheck,
      builder: (context, snap) {
        // Ir directo al escáner: no bloquear con Splash mientras se lee users/{uid}.
        // Misma clave si aún no hay familia para no reiniciar la cámara al terminar el future.
        if (snap.connectionState == ConnectionState.done && snap.data == true) {
          return const AppInitializer();
        }
        return FamilyQrJoinScreen(
          key: const ValueKey<String>('anonymous_guest_qr'),
          hintText: 'Escanea el QR que te comparte la familia',
          onScanned: _onQrScanned,
          onBack: () => AuthService.signOut(),
        );
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
      if (!needsOnboarding) {
        await NextFeedingNotificationService.syncFromStorage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const SplashScreen();
    }
    if (_needsOnboarding) {
      return OnboardingView(
        onFinished: () async {
          await NextFeedingNotificationService.syncFromStorage();
          if (!mounted) return;
          setState(() => _needsOnboarding = false);
        },
      );
    }
    return const MainNavigation();
  }
}
