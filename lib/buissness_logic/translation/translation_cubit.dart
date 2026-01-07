import 'package:ella_lyaabdoon/utils/dio_factory.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'translation_state.dart';

class TranslationCubit extends Cubit<TranslationState> {
  TranslationCubit() : super(TranslationInitial());

  Future<void> translate(String arabicText) async {
    emit(TranslationLoading());

    try {
      final dio = DioFactory.getDio();

      final response = await dio.get(
        'https://api.mymemory.translated.net/get',
        queryParameters: {'q': arabicText, 'langpair': 'ar|en'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final translatedText = data['responseData']['translatedText'];

        if (translatedText != null && translatedText.toString().isNotEmpty) {
          emit(TranslationLoaded(translatedText.toString()));
        } else {
          emit(TranslationError('Translation not available'));
        }
      } else {
        emit(TranslationError('Failed to translate: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TranslationError('Error: ${e.toString()}'));
    }
  }
}
