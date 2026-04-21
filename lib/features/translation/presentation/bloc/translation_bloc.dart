import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listen/features/translation/domain/usecases/translate_text.dart';
import 'translation_event.dart';
import 'translation_state.dart';

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final TranslateText _translateText;

  TranslationBloc({required TranslateText translateText})
    : _translateText = translateText,
      super(const TranslationInitial()) {
    on<TranslateRequested>(_onTranslateRequested);
    on<TranslationCleared>(_onTranslationCleared);
  }

  Future<void> _onTranslateRequested(
    TranslateRequested event,
    Emitter<TranslationState> emit,
  ) async {
    emit(const TranslationLoading());
    final result = await _translateText(
      TranslateParams(
        text: event.text,
        sourceLang: event.sourceLang,
        targetLang: event.targetLang,
      ),
    );
    result.fold(
      (failure) => emit(TranslationError(failure.message)),
      (translation) => emit(TranslationSuccess(translation)),
    );
  }

  void _onTranslationCleared(
    TranslationCleared event,
    Emitter<TranslationState> emit,
  ) {
    emit(const TranslationInitial());
  }
}
