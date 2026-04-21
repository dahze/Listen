import 'package:dartz/dartz.dart';
import 'package:listen/core/error/exceptions.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/features/translation/data/datasources/translation_remote_datasource.dart';
import 'package:listen/features/translation/domain/entities/translation.dart';
import 'package:listen/features/translation/domain/repositories/translation_repository.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDatasource datasource;
  const TranslationRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, Translation>> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final model = await datasource.translate(
        text: text,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
      return Right(model);
    } on TranslationException catch (e) {
      return Left(TranslationFailure(e.message));
    }
  }
}
