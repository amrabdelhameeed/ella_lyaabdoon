import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:equatable/equatable.dart';
part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  StreamSubscription? _zikrDoneSubscription;

  HistoryCubit() : super(HistoryInitial()) {
    _zikrDoneSubscription = NotificationHelper.zikrDoneStreamController.stream.listen((zikrId) {
      loadCheck(zikrId);
    });
  }

  @override
  Future<void> close() {
    _zikrDoneSubscription?.cancel();
    return super.close();
  }

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

  Future<void> reloadChecks() async {
    try {
      await HistoryDBProvider.reload();
      final currentChecks = state is HistoryLoaded
          ? Map<String, bool>.from((state as HistoryLoaded).checks)
          : <String, bool>{};

      for (final zikrId in currentChecks.keys) {
        currentChecks[zikrId] = HistoryDBProvider.isCheckedToday(zikrId);
      }

      emit(HistoryLoaded(checks: currentChecks, lastUpdated: DateTime.now()));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
