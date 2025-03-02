class ApiError implements Exception {
  final String message;
  final String action;
  final String? details;
  final int? statusCode;

  ApiError({
    required this.message,
    required this.action,
    this.details,
    this.statusCode,
  });

  @override
  String toString() => message;
} 