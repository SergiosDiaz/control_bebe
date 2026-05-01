import 'package:control_bebe/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/firebase/firebase_service.dart';
import 'register_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  static const double _primaryActionHeight = 45;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;

  /// Solo entrada anónima para QR: no usa [_isLoading] para no bloquear toda la tarjeta ni el botón principal.
  bool _guestQrLoading = false;
  String? _errorMessage;

  bool get _anyAuthBusy => _isLoading || _guestQrLoading;

  void _onFocusChange() => setState(() {});

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) _navigateToApp();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = _mapAuthError(e.code, l10n);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.loginErrorGeneric;
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cred = await AuthService.signInWithGoogle();
      if (cred != null && mounted) {
        _navigateToApp();
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = _mapAuthError(e.code, l10n);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.loginErrorGoogle;
        _isLoading = false;
      });
    }
  }

  Future<void> _signInAsGuestForQr() async {
    if (!FirebaseService.isAvailable) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.loginGuestNeedsFirebase;
      });
      return;
    }
    setState(() {
      _guestQrLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _guestQrLoading = false;
        _errorMessage = switch (e.code) {
          'operation-not-allowed' => l10n.loginGuestNotAllowed,
          _ => l10n.loginGuestFailed,
        };
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _guestQrLoading = false;
        _errorMessage = l10n.loginGuestFailed;
      });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cred = await AuthService.signInWithApple();
      if (cred != null && mounted) {
        _navigateToApp();
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = _mapAuthError(e.code, l10n);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.loginErrorApple;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToApp() async {
    if (!mounted) return;
    // Mantener [AuthWrapper] como ruta raíz (escucha auth). Onboarding / inicio lo decide AppInitializer.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _mapAuthError(String code, AppLocalizations l10n) {
    return switch (code) {
      'user-not-found' => l10n.authErrorUserNotFound,
      'wrong-password' => l10n.authErrorWrongPassword,
      'invalid-email' => l10n.authErrorInvalidEmail,
      'user-disabled' => l10n.authErrorUserDisabled,
      'invalid-credential' => l10n.authErrorInvalidCredential,
      'operation-not-allowed' => l10n.authErrorOperationNotAllowed,
      _ => l10n.loginErrorGeneric,
    };
  }

  String _mapPasswordResetError(String code, AppLocalizations l10n) {
    return switch (code) {
      'invalid-email' => l10n.resetErrorInvalidEmail,
      'user-not-found' => l10n.resetErrorUserNotFound,
      'user-disabled' => l10n.resetErrorUserDisabled,
      'operation-not-allowed' => l10n.resetErrorOpNotAllowed,
      _ => l10n.resetErrorGeneric,
    };
  }

  Future<void> _openForgotPasswordDialog() async {
    if (!FirebaseService.isAvailable) return;

    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    String? dialogError;
    var sending = false;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final l10n = AppLocalizations.of(dialogCtx)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.dialogRadius),
              ),
              title: Text(l10n.loginForgotPasswordTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.loginForgotPasswordBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        hintText: l10n.loginEmailHint,
                      ),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        dialogError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: sending
                      ? null
                      : () => Navigator.of(dialogCtx).pop(),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: sending
                      ? null
                      : () async {
                          final email = emailCtrl.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            setDialogState(() {
                              dialogError = l10n.loginResetInvalidEmail;
                            });
                            return;
                          }
                          setDialogState(() {
                            sending = true;
                            dialogError = null;
                          });
                          try {
                            await AuthService.sendPasswordResetEmail(email);
                            if (!dialogCtx.mounted) return;
                            Navigator.of(dialogCtx).pop();
                            if (!mounted) return;
                            final rootL10n = AppLocalizations.of(context)!;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(rootL10n.loginResetCheckEmail),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            setDialogState(() {
                              sending = false;
                              dialogError = _mapPasswordResetError(
                                e.code,
                                l10n,
                              );
                            });
                          } catch (_) {
                            setDialogState(() {
                              sending = false;
                              dialogError = l10n.loginResetSendFail;
                            });
                          }
                        },
                  child: sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.commonSend),
                ),
              ],
            );
          },
        );
      },
    );

    emailCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F0F8)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppTheme.screenEdgePadding,
              right: AppTheme.screenEdgePadding,
              bottom: AppTheme.safeBottomPadding(context),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildCard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/app_icon.png',
            width: 168,
            height: 168,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.loginHeaderTitle,
          style: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppTheme.textHeading,
            height: 1.15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.homeCardRadius),
        border: Border.all(color: AppTheme.cardOutline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTheme.textLight,
                ),
                hintText: _emailFocusNode.hasFocus ? null : l10n.loginEmailHint,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.loginValidatorEmailEmpty;
                }
                if (!v.contains('@')) return l10n.loginValidatorEmailInvalid;
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: AppTheme.textLight,
                ),
                hintText: _passwordFocusNode.hasFocus
                    ? null
                    : l10n.loginPasswordHint,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textLight,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return l10n.loginValidatorPasswordEmpty;
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _anyAuthBusy ? null : _openForgotPasswordDialog,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.loginForgotLink,
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: _primaryActionHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _anyAuthBusy ? null : _signInWithEmail,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    _primaryActionHeight,
                  ),
                  maximumSize: const Size(
                    double.infinity,
                    _primaryActionHeight,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.loginSignIn,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: _primaryActionHeight,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _anyAuthBusy ? null : _signInAsGuestForQr,
                icon: _guestQrLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : Icon(Icons.qr_code_scanner, color: AppTheme.primaryBlue),
                label: Text(
                  l10n.loginGuestQr,
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    _primaryActionHeight,
                  ),
                  maximumSize: const Size(
                    double.infinity,
                    _primaryActionHeight,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(
                    color: AppTheme.primaryBlue,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.loginOrWith,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _anyAuthBusy ? null : _signInWithGoogle,
                    icon: SvgPicture.asset(
                      'assets/images/google_logo.svg',
                      width: 20,
                      height: 20,
                    ),
                    label: const Text(
                      'Google',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _anyAuthBusy ? null : _signInWithApple,
                    icon: const Icon(
                      Icons.apple,
                      size: 24,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Apple',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.loginNoAccount,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterView()),
                  ),
                  child: Text(
                    l10n.loginRegisterLink,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
