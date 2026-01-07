abstract class TranslationState {}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {}

class TranslationLoaded extends TranslationState {
  final String translatedText;

  TranslationLoaded(this.translatedText);
}

class TranslationError extends TranslationState {
  final String message;

  TranslationError(this.message);
}
