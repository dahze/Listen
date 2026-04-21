import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/translation/domain/entities/translation.dart';
import 'package:listen/features/translation/domain/repositories/translation_repository.dart';

class TranslateText implements UseCase<Translation, TranslateParams> {
  final TranslationRepository repository;
  const TranslateText(this.repository);

  @override
  Future<Either<Failure, Translation>> call(TranslateParams params) {
    return repository.translate(
      text: params.text,
      sourceLang: params.sourceLang,
      targetLang: params.targetLang,
    );
  }
}

class TranslateParams extends Equatable {
  final String text;
  final String sourceLang;
  final String targetLang;

  const TranslateParams({
    required this.text,
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  List<Object> get props => [text, sourceLang, targetLang];
}