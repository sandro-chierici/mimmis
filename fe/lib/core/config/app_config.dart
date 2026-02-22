/// Central place to configure the backend base URL.
/// Change [baseUrl] to point at a different environment.
class AppConfig {
  const AppConfig._();

  /// Base URL of the backend API (no trailing slash).
  /// For local web dev the nginx proxy is on http://localhost.
  static const String baseUrl = 'https://188.213.161.34';
}
