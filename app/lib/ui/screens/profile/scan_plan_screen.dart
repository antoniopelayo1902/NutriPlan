import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../application/app_controllers.dart';
import '../../../application/toast_controller.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/gallery.dart';
import '../../../data/nutritionist_service.dart';
import '../../../data/plan_share_service.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/data_display/confirm_dialog.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_icon.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../login/auth_gate.dart';
import '../page_frame.dart';

/// Factor WOW (parte 2): escanea un QR con la cámara (mobile_scanner), de
/// una foto o pegado. El de una nutrióloga vincula al paciente con ella; el
/// de otro paciente importa su plan.
class ScanPlanScreen extends StatefulWidget {
  const ScanPlanScreen({super.key});

  @override
  State<ScanPlanScreen> createState() => _ScanPlanScreenState();
}

class _ScanPlanScreenState extends State<ScanPlanScreen> {
  final MobileScannerController _scanner = MobileScannerController();

  /// Evita procesar el mismo código varias veces seguidas.
  bool _busy = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  /// La cámara encontró un código.
  void _onDetect(BarcodeCapture capture) {
    final String? raw = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (raw != null) _handle(raw);
  }

  /// Busca el código QR dentro de una imagen de la galería.
  Future<void> _fromGallery() async {
    final ToastController toast = context.read<ToastController>();
    final String? path = await Gallery.pickImage();
    if (path == null) return;
    final BarcodeCapture? capture;
    try {
      capture = await _scanner.analyzeImage(path);
    } on UnsupportedError {
      // mobile_scanner no lee imágenes en el simulador de iOS.
      toast.show(S.galleryScanUnavailable);
      return;
    } catch (_) {
      toast.show(S.noCodeFound);
      return;
    }
    final String? raw = (capture == null || capture.barcodes.isEmpty)
        ? null
        : capture.barcodes.first.rawValue;
    if (raw == null) {
      toast.show(S.noCodeFound);
      return;
    }
    await _handle(raw);
  }

  /// El código que se copió en "Mi código" (por ejemplo, por WhatsApp).
  Future<void> _fromClipboard() async {
    final ToastController toast = context.read<ToastController>();
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? text = data?.text;
    if (text == null || text.trim().isEmpty) {
      toast.show(S.clipboardEmpty);
      return;
    }
    await _handle(text);
  }

  /// Valida el código, pide confirmación e importa el plan.
  Future<void> _handle(String raw) async {
    if (_busy || !mounted) return;
    _busy = true;
    final ToastController toast = context.read<ToastController>();
    final AppControllers controllers = context.read<AppControllers>();
    final String? myUid = AuthScope.maybeOf(context)?.uid;
    final String? nutriUid = PlanShareService.nutriUidFrom(raw);
    final String? fromUid = PlanShareService.uidFrom(raw);
    try {
      if (nutriUid != null && myUid != null) {
        await _link(myUid, nutriUid, controllers, toast);
        return;
      }
      if (fromUid == null || myUid == null) {
        toast.show(S.invalidCode);
        return;
      }
      if (fromUid == myUid) {
        toast.show(S.ownCode);
        return;
      }
      final bool sure = await showConfirmDialog(
        context,
        title: S.importTitle,
        body: S.importBody,
        confirmLabel: S.importAction,
      );
      if (!sure || !mounted) return;
      await PlanShareService.importPlan(fromUid: fromUid, toUid: myUid);
      await Future.wait(<Future<void>>[
        controllers.plan.load(),
        controllers.activity.load(),
      ]);
      toast.show(S.planImported);
      // Regresa a las pestañas para ver el plan nuevo.
      if (mounted) Navigator.popUntil(context, (Route<void> r) => r.isFirst);
    } catch (_) {
      toast.show(S.importFailed);
    } finally {
      _busy = false;
    }
  }

  /// Vincula al paciente con la nutrióloga del código.
  Future<void> _link(
    String myUid,
    String nutriUid,
    AppControllers controllers,
    ToastController toast,
  ) async {
    if (controllers.profile.nutritionist?.id == nutriUid) {
      toast.show(S.alreadyLinked);
      return;
    }
    final String name;
    try {
      name = await NutritionistService.loadName(nutriUid);
    } catch (_) {
      toast.show(S.invalidCode);
      return;
    }
    if (!mounted) return;
    final bool sure = await showConfirmDialog(
      context,
      title: S.linkTitle(name),
      body: S.linkBody,
      confirmLabel: S.linkAction,
    );
    if (!sure || !mounted) return;
    try {
      await NutritionistService.link(myUid, nutriUid);
      await controllers.profile.load();
      toast.show(S.linked(name));
      if (mounted) Navigator.popUntil(context, (Route<void> r) => r.isFirst);
    } catch (_) {
      toast.show(S.linkFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return PageFrame(
      eyebrow: S.wowEyebrow,
      title: S.scanTitle,
      children: <Widget>[
        const AppText(S.scanBodyAny, tone: TextTone.secondary),
        ClipRRect(
          borderRadius: BorderRadius.circular(t.radius.xl),
          child: SizedBox(
            height: t.size.scannerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                MobileScanner(
                  controller: _scanner,
                  onDetect: _onDetect,
                  // En el simulador no hay cámara: se avisa y queda la galería.
                  errorBuilder:
                      (BuildContext context, MobileScannerException _) =>
                          AppCard(
                            tone: CardTone.surface,
                            child: Center(
                              child: AppStack(
                                gap: t.space.s3,
                                align: CrossAxisAlignment.center,
                                children: const <Widget>[
                                  AppIcon(
                                    AppIconName.camera,
                                    tone: TextTone.muted,
                                  ),
                                  AppText(
                                    S.cameraUnavailable,
                                    key: Key('cameraUnavailable'),
                                    tone: TextTone.secondary,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                ),
                // Guía encima de la cámara (en el simulador la cámara sale negra).
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(t.space.s4),
                    child: const AppText(
                      S.scanHint,
                      tone: TextTone.inverse,
                      variant: TextVariant.label,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppButton(
          key: const Key('pickQrImageButton'),
          label: S.pickQrImage,
          iconLeft: AppIconName.image,
          fullWidth: true,
          onPressed: _fromGallery,
        ),
        AppButton(
          key: const Key('pasteCodeButton'),
          label: S.pasteCode,
          variant: ButtonVariant.outlineNeutral,
          fullWidth: true,
          onPressed: _fromClipboard,
        ),
      ],
    );
  }
}
