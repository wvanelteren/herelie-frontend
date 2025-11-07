import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../models/api/optimizer_request.dart';
import '../models/api/optimizer_response.dart';

class OptimizerRemoteDataSource {
  final Dio _dio;

  OptimizerRemoteDataSource(this._dio);

  Future<ApiOptimizerResponse> optimize(OptimizerRequest request) async {
    try {
      final res = await _dio.post(
        AppConfig.optimizerApiPath,
        data: request.toJson(),
        options: Options(
          headers: {
            if (AppConfig.optimizerApiKey.isNotEmpty)
              'x-api-key': AppConfig.optimizerApiKey,
          },
        ),
      );
      return ApiOptimizerResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      final payload = e.response?.data;
      final message = 'Optimizer error: ${e.message}';

      log(
        payload == null
            ? message
            : '$message — payload: ${payload is String ? payload : jsonEncode(payload)}',
        name: 'OptimizerRemoteDataSource',
        error: e,
        stackTrace: st,
      );

      throw Exception(payload ?? e.message);
    } catch (e, st) {
      log(
        'Optimizer unexpected error: $e',
        name: 'OptimizerRemoteDataSource',
        error: e,
        stackTrace: st,
      );
      throw Exception('Optimizer unexpected error: $e');
    }
  }
}
