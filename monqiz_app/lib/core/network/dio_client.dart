import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';

class DioClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  DioClient({
    Dio? dio,
    TokenStorage? tokenStorage,
  })  : tokenStorage = tokenStorage ?? TokenStorage(),
        dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Extract user-friendly error message from response
          String formattedMessage = 'حدث خطأ في الاتصال بالخادم';

          final data = error.response?.data;
          if (data is Map<String, dynamic>) {
            if (data['message'] != null && data['message'].toString().isNotEmpty) {
              formattedMessage = data['message'].toString();
            } else if (data['detail'] != null) {
              formattedMessage = data['detail'].toString();
            } else if (data['errors'] != null) {
              final errs = data['errors'];
              if (errs is List && errs.isNotEmpty) {
                formattedMessage = errs.first.toString();
              } else if (errs is Map) {
                formattedMessage = errs.values.first.toString();
              }
            }
          } else if (data is String && data.isNotEmpty) {
            formattedMessage = data;
          }

          final customError = DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: formattedMessage,
            message: formattedMessage,
          );

          return handler.next(customError);
        },
      ),
    );
  }
}
