class AppConfig {
  AppConfig._();

  static const String parserBaseUrl = String.fromEnvironment(
    'PARSER_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String parserApiPath = String.fromEnvironment(
    'PARSER_API_PATH',
    defaultValue: '/parse',
  );

  static const String optimizerBaseUrl = String.fromEnvironment(
    'OPTIMIZER_BASE_URL',
    defaultValue: 'https://optimizer-dev-1ju8cxvt.uc.gateway.dev',
  );

  static const String optimizerApiPath = String.fromEnvironment(
    'OPTIMIZER_API_PATH',
    defaultValue: '/optimize',
  );

  static const String optimizerApiKey = String.fromEnvironment(
    'OPTIMIZER_API_KEY',
    defaultValue: '',
  );
}
