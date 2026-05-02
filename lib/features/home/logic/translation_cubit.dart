import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'translation_state.dart';

class TranslationCubit extends Cubit<TranslationState> {
  TranslationCubit() : super(TranslationInitial());

  Future<String> translate(String arabicText) async {
    emit(TranslationLoading());

    try {
      final dio = Dio();

      final response = await dio.get(
        'https://api.mymemory.translated.net/get',
        queryParameters: {'q': arabicText, 'langpair': 'ar|en'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final translatedText = data['responseData']['translatedText'];

        if (translatedText != null && translatedText.toString().isNotEmpty) {
          emit(TranslationLoaded(translatedText.toString()));
          return translatedText.toString();
        } else {
          emit(TranslationError('Translation not available'));
        }
      } else {
        emit(TranslationError('Failed to translate: ${response.statusCode}'));
      }
      return '';
    } catch (e) {
      emit(TranslationError('Error: ${e.toString()}'));
      return '';
    }
  }

  void reset() => emit(TranslationInitial());
}
