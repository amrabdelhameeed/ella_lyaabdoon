import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  /// private constructor to prevent instantiation
  DioFactory._();

  static Dio? _dio;

  static Dio getDio() {
    if (_dio == null) {
      final dio = Dio();

      dio.options
        ..connectTimeout = const Duration(seconds: 30)
        ..receiveTimeout = const Duration(seconds: 30);

      // Allow bad certificates on Android for dev/debug purposes only
      if (Platform.isAndroid) {
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
      }

      // Add interceptors
      dio.interceptors.add(BaseInterceptor());
      dio.interceptors.add(
        PrettyDioLogger(
          error: true,
          requestBody: true,
          requestHeader: true,
          maxWidth: 100,
          compact: false,
        ),
      );

      _dio = dio;
    }

    return _dio!;
  }
}

class BaseInterceptor extends Interceptor {
  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // options.headers['Authorization'] =
    //     authCubitAf.token ?? AppServicesDBprovider.token();
    // options.headers['app_key'] = ApiStringsAF.appKey;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Do something with response data
    super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    // If the error is 401 Unauthorized, log out the user
    // if (err.response?.statusCode == 401) {
    //   AppServicesDBprovider.deleteToken();
    //   accountCubit.clearAccountList();
    //   navBarCubit.changeIndex(2);
    //   Future.delayed(
    //     Duration(seconds: 1),
    //     () {
    //       AppRouter.router.goNamed(VlensRoutes.login_vlens);
    //     },
    //   );
    // }
    super.onError(err, handler);
  }
}
