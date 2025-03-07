import 'package:flutter/material.dart';

import '../enums/confetti_enums.dart';
import '../widgets/confetti_dialog.dart';

/// Helper class to show confetti dialogs

class ConfettiHelper {
  /// Fungsi statis untuk memunculkan dialog confetti.
  static Future<void> showConfettiDialog({
    required BuildContext context,
    required ConfettiType confettiType,
    required ConfettiStyle confettiStyle,
    required AnimationConfetti animationStyle,
    final Widget? cardDialog,
    bool useController = false,
    int durationInSeconds = 3,
    ConfettiColorTheme colorTheme = ConfettiColorTheme.rainbow,
    String? message,
    ConfettiDensity density = ConfettiDensity.medium,
    BlendMode? blendMode,
    VoidCallback? onComplete,
    bool isClosedDialogAutomatic = false,

    /// [NEW] jika true, setiap partikel ambil warna acak dari [card, shadow, text].
    bool isColorMixedFromModel = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return ConfettiDialog(
          confettiType: confettiType,
          confettiStyle: confettiStyle,
          animationStyle: animationStyle,
          colorTheme: colorTheme,
          useExternalController: useController,
          externalController: null,
          cardDialog: cardDialog,
          durationInSeconds: durationInSeconds,
          density: density,
          isClosedDialogAutomatic: isClosedDialogAutomatic,
          blendMode: blendMode,
          onComplete: onComplete,
          isColorMixedFromModel: isColorMixedFromModel, // [NEW]
        );
      },
    );
  }
}
