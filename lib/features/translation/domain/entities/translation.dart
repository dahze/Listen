import 'package:equatable/equatable.dart';

class Translation extends Equatable {
  final String originalText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;

  const Translation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  List<Object> get props => [
        originalText,
        translatedText,
        sourceLang,
        targetLang,
      ];
}