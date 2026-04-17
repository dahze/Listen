class LanguageDetector {
  LanguageDetector._();

  static const String urdu = 'ur';
  static const String english = 'en';

  /// Returns 'ur' if the text contains Arabic/Urdu script characters,
  /// 'en' otherwise.
  static String detect(String text) {
    for (final codeUnit in text.codeUnits) {
      if (codeUnit >= 0x0600 && codeUnit <= 0x06FF) return urdu;
    }
    return english;
  }

  /// Returns the target language given a source language.
  static String targetFor(String sourceLang) {
    return sourceLang == urdu ? english : urdu;
  }
}
