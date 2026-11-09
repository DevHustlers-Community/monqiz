/// Global Configuration & Environment Flags for MONQIZ
abstract final class AppConfig {
  /// Toggle for Mock Data Mode.
  /// Set to [true] while the .NET 10 Web API is under development.
  /// Set to [false] when connecting to the production REST API.
  static const bool useMockData = true;

  /// Base URL for the .NET 10 Web API
  static const String apiBaseUrl = 'https://api.monqiz.org/api';

  /// Emergency hotline number (Egyptian National Blood Transfusion Service)
  static const String emergencyHotline = '19888';

  /// Mock network latency in milliseconds
  static const int mockLatencyMs = 600;
}
