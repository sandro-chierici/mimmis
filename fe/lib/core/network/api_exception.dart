/// Thrown when the API returns a non-2xx response or a network error occurs.
class ApiException implements Exception {
  const ApiException({required this.code, required this.message});

  /// HTTP status code, or 0 for network/parse errors.
  final int code;
  final String message;

  @override
  String toString() => 'ApiException($code): $message';
}
