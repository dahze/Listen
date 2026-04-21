import 'package:equatable/equatable.dart';

sealed class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object> get props => [];
}

final class TranslateRequested extends TranslationEvent {
  final String text;
  final String sourceLang;
  final String targetLang;

  const TranslateRequested({
    required this.text,
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  List<Object> get props => [text, sourceLang, targetLang];
}

final class TranslationCleared extends TranslationEvent {
  const TranslationCleared();
}
