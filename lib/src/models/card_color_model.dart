import 'package:flutter/material.dart';

/// Card color model that defines the color scheme for a card
class CardColorModel {
  final Color card;
  final Color shadow;
  final Color text;

  const CardColorModel({
    required this.card,
    required this.shadow,
    required this.text,
  });
}
