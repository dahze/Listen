class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class TranslationException implements Exception {
  final String message;
  const TranslationException(this.message);
}

class SpeechException implements Exception {
  final String message;
  const SpeechException(this.message);
}

class ConversationException implements Exception {
  final String message;
  const ConversationException(this.message);
}
