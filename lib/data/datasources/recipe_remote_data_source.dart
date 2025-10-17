import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../models/api/process_response.dart';

class RecipeRemoteDataSource {
  final Dio _dio;
  RecipeRemoteDataSource(this._dio);

  Future<ProcessResponse> processText(String text) async {
    try {
      final res = await _dio.post(
        AppConfig.processPath,
        data: {'text': text},
      );
      return ProcessResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data ?? e.message;
      throw Exception('Netwerkfout: $msg');
    } catch (e) {
      throw Exception('Onverwachte fout: $e');
    }
  }
}