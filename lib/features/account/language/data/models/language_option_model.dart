import 'dart:ui' as ui;

class LanguageOptionModel {
  final String title;
  final String subtitle;
  final String label;
  final String languageCode;
  final ui.TextDirection direction;

  const LanguageOptionModel({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.languageCode,
    required this.direction,
  });
}
