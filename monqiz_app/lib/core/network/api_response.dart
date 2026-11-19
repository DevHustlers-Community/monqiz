/// Unified response wrapper matching the backend `ApiResponse<T>`
class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final List<String> errors;

  const ApiResponse({
    required this.isSuccess,
    this.message = '',
    this.data,
    this.errors = const [],
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawJson)? fromData,
  ) {
    final rawData = json['data'] ?? json['dates'];
    final isSuccess = json['isSuccess'] as bool? ??
        (json['token'] != null || json['id'] != null || json['dates'] != null || json['message'] != null);
    final message = json['message'] as String? ?? '';
    final errorsList = json['errors'] as List<dynamic>?;
    final errors = errorsList?.map((e) => e.toString()).toList() ?? [];

    return ApiResponse<T>(
      isSuccess: isSuccess,
      message: message,
      data: rawData != null && fromData != null ? fromData(rawData) : rawData as T?,
      errors: errors,
    );
  }
}
