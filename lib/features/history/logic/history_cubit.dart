import 'package:bloc/bloc.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:equatable/equatable.dart';
part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitial());

  Future<void> loadCheck(String zikrId) async {
    try {
      final isChecked = HistoryDBProvider.isCheckedToday(zikrId);
      final currentChecks = state is HistoryLoaded
          ? Map<String, bool>.from((state as HistoryLoaded).checks)
          : <String, bool>{};

      currentChecks[zikrId] = isChecked;
      emit(HistoryLoaded(checks: currentChecks, lastUpdated: DateTime.now()));
    } catch (e) {
      emit(HistoryError(e.toString()));
      // Fallback to simpler state if needed
    }
  }

  Future<void> toggleCheck(String zikrId) async {
    try {
      final isChecked = HistoryDBProvider.isCheckedToday(zikrId);
      final now = DateTime.now();

      if (isChecked) {
        await HistoryDBProvider.removeCheck(zikrId, now);
      } else {
        await HistoryDBProvider.addCheck(zikrId, now);
      }

      // Update local state
      final currentChecks = state is HistoryLoaded
          ? Map<String, bool>.from((state as HistoryLoaded).checks)
          : <String, bool>{};

      currentChecks[zikrId] = !isChecked;
      emit(HistoryLoaded(checks: currentChecks, lastUpdated: DateTime.now()));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> incrementCounter(String zikrId) async {
    try {
      await HistoryDBProvider.incrementCounter(zikrId);

      // Update local state to trigger rebuild
      final currentChecks = state is HistoryLoaded
          ? Map<String, bool>.from((state as HistoryLoaded).checks)
          : <String, bool>{};

      emit(HistoryLoaded(checks: currentChecks, lastUpdated: DateTime.now()));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
