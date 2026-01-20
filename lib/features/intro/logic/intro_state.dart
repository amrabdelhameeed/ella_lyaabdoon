part of 'intro_cubit.dart';

class IntroState extends Equatable {
  final int index;

  const IntroState({required this.index});

  IntroState copyWith({int? index}) {
    return IntroState(index: index ?? this.index);
  }

  @override
  List<Object> get props => [index];
}
