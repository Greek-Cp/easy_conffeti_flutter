import 'package:flutter/material.dart';

import 'hover_color_model.dart';

class CardColorModel {
  final Color card;
  final Color shadow;
  final Color text;
  final HoverColorModel hover;

  const CardColorModel(
      {required this.card,
      required this.shadow,
      required this.text,
      required this.hover});

  CardColorModel copyWith({
    Color? card,
    Color? shadow,
    Color? text,
    HoverColorModel? hover,
  }) {
    return CardColorModel(
      card: card ?? this.card,
      shadow: shadow ?? this.shadow,
      text: text ?? this.text,
      hover: hover ?? this.hover,
    );
  }
}
