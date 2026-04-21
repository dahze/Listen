import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:listen/core/error/exceptions.dart';
import 'package:listen/features/translation/data/models/translation_model.dart';

abstract class TranslationRemoteDatasource {
  Future<TranslationModel> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  });
}

class TranslationRemoteDatasourceImpl implements TranslationRemoteDatasource {
  final http.Client client;
  const TranslationRemoteDatasourceImpl(this.client);

  static const _baseUrl = 'https://api.mymemory.translated.net/get';

  @override
  Future<TranslationModel> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {'q': text, 'langpair': '$sourceLang|$targetLang'},
    );

    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw TranslationException(
          'Translation failed — status ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // MyMemory returns status 200 even on errors — check responseStatus.
      final responseStatus = json['responseStatus'];
      if (responseStatus != 200) {
        throw TranslationException(
          json['responseDetails']?.toString() ?? 'Translation failed',
        );
      }

      return TranslationModel.fromJson(
        json: json,
        originalText: text,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    } on TranslationException {
      rethrow;
    } catch (e) {
      throw TranslationException('Unexpected error: $e');
    }
  }
}
