import 'package:flutter/material.dart';
import '../enums/confetti_enums.dart';
import '../helpers/confetti_helper.dart';

/// Example trigger button widget

class ConfettiTriggerButton extends StatelessWidget {
  const ConfettiTriggerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Tampilkan confetti dengan mode warna campur:
        await ConfettiHelper.showConfettiDialog(
          context: context,
          confettiType: ConfettiType.achievement,
          confettiStyle: ConfettiStyle.custom,
          animationStyle: AnimationConfetti.explosion,
          useController: false,
          durationInSeconds: 3,
          // Pilih color theme model-based (misal 'orange')
          colorTheme: ConfettiColorTheme.orange,
          // [NEW] aktifkan color campur
          isColorMixedFromModel: true,
          message: "Pencapaian Luar Biasa!",
        );
      },
      child: const Text('Show Mixed Color Confetti'),
    );
  }
}
