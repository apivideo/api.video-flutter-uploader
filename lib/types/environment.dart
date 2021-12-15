/// An enumeration of api.video endpoint.
enum Environment {
  /// The sandbox environment (for test).
  sandbox,

  /// The production environment.
  production
}

/// Extension for [Environment].
extension EnvironmentExtension on Environment {
  /// The api.video environment url [basePath].
  String get basePath {
    switch (this) {
      case Environment.sandbox:
        return 'https://sandbox.api.video';
      case Environment.production:
        return 'https://ws.api.video';
      default:
        throw Exception('Unknown environment');
    }
  }
}
