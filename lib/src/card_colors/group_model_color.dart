import 'card_color_model.dart';
import 'hover_color_model.dart';

class GroupModelColor {
  final CardColorModel primaryColor;
  final CardColorModel secondaryColor;
  final CardColorModel tertiaryColor;
  final HoverColorModel hoverColor;

  const GroupModelColor(
      {required this.primaryColor,
      required this.secondaryColor,
      required this.hoverColor,
      required this.tertiaryColor});
}
