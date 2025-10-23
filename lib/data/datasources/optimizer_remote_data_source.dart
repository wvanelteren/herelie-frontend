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
        AppConfig.optimizerUrl,
        data: request.toJson(),
        options: Options(
          headers: {
            if (AppConfig.optimizerApiKey.isNotEmpty)
              'x-api-key': AppConfig.optimizerApiKey,
          },
        ),
      );
      return ApiOptimizerResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data ?? e.message;
      throw Exception('Optimizer error: $msg');
    } catch (e) {
      throw Exception('Optimizer unexpected error: $e');
    }
  }
}
