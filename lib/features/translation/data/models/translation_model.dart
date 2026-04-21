import 'package:listen/features/translation/domain/entities/translation.dart';

class TranslationModel extends Translation {
  const TranslationModel({
    required super.originalText,
    required super.translatedText,
    required super.sourceLang,
    required super.targetLang,
  });

  /// MyMemory API response shape:
  /// {
  ///   "responseData": {
  ///     "translatedText": "..."
  ///   }
  /// }
  factory TranslationModel.fromJson({
    required Map<String, dynamic> json,
    required String originalText,
    required String sourceLang,
    required String targetLang,
  }) {
    final responseData = json['responseData'] as Map<String, dynamic>;
    return TranslationModel(
      originalText: originalText,
      translatedText: responseData['translatedText'] as String,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }
}
