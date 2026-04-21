import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/features/translation/domain/entities/translation.dart';

abstract class TranslationRepository {
  Future<Either<Failure, Translation>> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  });
}