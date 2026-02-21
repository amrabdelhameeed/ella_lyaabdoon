import 'package:dio/dio.dart';
import 'package:ella_lyaabdoon/features/home/logic/quran_audio_cubit.dart';
import 'package:ella_lyaabdoon/utils/dio_factory.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
void initDI() {
  getIt.registerLazySingleton<Dio>(() => DioFactory.getDio());
  // getIt.registerLazySingleton<QuranAudioCubit>(() => QuranAudioCubit());
}

// final quranAudioCubit = getIt<QuranAudioCubit>();
// final fundsCubit = getIt<FundsCubit>();
