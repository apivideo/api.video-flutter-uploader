enum Environment { sandbox, production }

extension EnvironmentExtension on Environment {
  String get name {
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
