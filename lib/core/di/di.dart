import 'package:dio/dio.dart';
import 'package:ella_lyaabdoon/utils/dio_factory.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
void initDI() {
  getIt.registerLazySingleton<Dio>(() => DioFactory.getDio());
}

// final fundsCubit = getIt<FundsCubit>();
