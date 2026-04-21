import 'package:equatable/equatable.dart';
import 'package:listen/features/translation/domain/entities/translation.dart';

sealed class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object?> get props => [];
}

final class TranslationInitial extends TranslationState {
  const TranslationInitial();
}

final class TranslationLoading extends TranslationState {
  const TranslationLoading();
}

final class TranslationSuccess extends TranslationState {
  final Translation translation;
  const TranslationSuccess(this.translation);

  @override
  List<Object?> get props => [translation];
}

final class TranslationError extends TranslationState {
  final String message;
  const TranslationError(this.message);

  @override
  List<Object?> get props => [message];
}
