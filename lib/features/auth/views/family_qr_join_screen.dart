import 'package:control_bebe/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';

/// Escaneo de QR para unirse a una familia existente (onboarding o invitado en login).
class FamilyQrJoinScreen extends StatefulWidget {
  final Future<void> Function(String familyId) onScanned;
  final VoidCallback onBack;
  final String? hintText;

  const FamilyQrJoinScreen({
    super.key,
    required this.onScanned,
    required this.onBack,
    this.hintText,
  });

  @override
  State<FamilyQrJoinScreen> createState() => _FamilyQrJoinScreenState();
}

class _FamilyQrJoinScreenState extends State<FamilyQrJoinScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _processing = false;
  String? _error;

  String _joinFailureDescription(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final technical = _technicalErrorText(error);
    final summary = _joinFailureSummary(context, error);
    final String body;
    if (technical == summary) {
      body = summary;
    } else {
      body = '$summary\n\n${l10n.familyQrDetailLabel} $technical';
    }
    return '$body\n\n[QR join] $error\n$stackTrace';
  }

  String _joinFailureSummary(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return l10n.familyQrJoinFailPermission;
        case 'unavailable':
          return l10n.familyQrJoinFailUnavailable;
        case 'not-found':
        case 'not_found':
          return l10n.familyQrJoinFailNotFound;
        default:
          return l10n.familyQrJoinFailFirebase(error.code);
      }
    }
    if (error is StateError) {
      final m = error.message;
      if (m.contains('no encontrada') || m.contains('not found')) {
        return l10n.familyQrJoinFailFamily;
      }
      return l10n.familyQrJoinFailState;
    }
    if (error is UnsupportedError) {
      return l10n.familyQrJoinFailUnsupported;
    }
    return l10n.familyQrJoinFailGeneric;
  }

  static String _technicalErrorText(Object error) {
    if (error is FirebaseException) {
      final msg = error.message;
      if (msg != null && msg.isNotEmpty) return '${error.code}: $msg';
      return error.code;
    }
    return error.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue?.trim();
    if (code == null || code.isEmpty) return;

    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      await widget.onScanned(code);
    } catch (e, st) {
      debugPrint('[QR join] $e\n$st');
      if (mounted) {
        setState(() {
          _processing = false;
          _error = _joinFailureDescription(context, e, st);
        });
      }
    }
  }

  void _onDetectError(Object error, StackTrace stackTrace) {
    debugPrint('[QR decode] $error\n$stackTrace');
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _processing = false;
      _error =
          '${l10n.familyQrDecodeFail}\n\n${l10n.familyQrDetailLabel} ${error.toString()}\n\n[QR decode] $error\n$stackTrace';
    });
  }

  Widget _cameraErrorWidget(
    BuildContext context,
    MobileScannerException error,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final detail = error.errorDetails?.message;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                error.errorCode.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (detail != null && detail.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                '${l10n.familyQrInternalCode} ${error.errorCode.name}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayHint = widget.hintText ?? l10n.familyQrHint;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(l10n.familyQrTitle),
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              onDetectError: _onDetectError,
              errorBuilder: _cameraErrorWidget,
            ),
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54, width: 2),
                  borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              bottom: 40,
              left: AppTheme.screenEdgePadding,
              right: AppTheme.screenEdgePadding,
              child: Column(
                children: [
                  Text(
                    displayHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(
                          AppTheme.fieldRadius,
                        ),
                      ),
                      child: SelectableText(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  if (_processing) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(color: Colors.white),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
