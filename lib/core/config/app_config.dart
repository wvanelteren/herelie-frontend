class AppConfig {
  AppConfig._();

  static const String parserBaseUrl = String.fromEnvironment(
    'PARSER_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String processPath = String.fromEnvironment(
    'PARSER_PROCESS_PATH',
    defaultValue: '/process',
  );

  static const String optimizerUrl = String.fromEnvironment(
    'OPTIMIZER_URL',
    defaultValue: 'https://optimizer-dev-1ju8cxvt.uc.gateway.dev/optimizer',
  );

  static const String optimizerApiKey = String.fromEnvironment(
    'OPTIMIZER_API_KEY',
    defaultValue: '',
  );
}
