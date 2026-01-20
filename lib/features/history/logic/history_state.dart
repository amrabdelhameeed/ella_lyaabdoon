part of 'history_cubit.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final Map<String, bool> checks;
  final DateTime lastUpdated;

  const HistoryLoaded({required this.checks, required this.lastUpdated});

  @override
  List<Object> get props => [checks, lastUpdated];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
