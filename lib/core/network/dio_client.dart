import 'package:dio/dio.dart';
import '../config/app_config.dart';

class DioClient {
  static Dio build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.parserBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: false,
      error: true,
      request: false,
      requestHeader: false,
      responseHeader: false,
    ));

    return dio;
  }
}
