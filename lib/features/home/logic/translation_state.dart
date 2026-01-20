part of 'translation_cubit.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object> get props => [];
}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {}

class TranslationLoaded extends TranslationState {
  final String translatedText;

  const TranslationLoaded(this.translatedText);

  @override
  List<Object> get props => [translatedText];
}

class TranslationError extends TranslationState {
  final String message;

  const TranslationError(this.message);

  @override
  List<Object> get props => [message];
}
