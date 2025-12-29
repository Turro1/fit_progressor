/// Конфигурация синхронизации
class SyncConfig {
  /// Порт WebSocket сервера по умолчанию
  static const int defaultPort = 8765;

  /// Таймаут подключения в секундах
  static const int connectionTimeoutSeconds = 10;

  /// Интервал ping/pong в секундах
  static const int pingIntervalSeconds = 30;

  /// Максимальное количество попыток переподключения
  static const int maxReconnectAttempts = 5;

  /// Задержка между попытками переподключения в секундах
  static const int reconnectDelaySeconds = 3;

  /// Размер пакета для batch синхронизации
  static const int batchSize = 100;

  /// URI схема для QR кода
  static const String uriScheme = 'fitprogressor';

  /// Версия протокола синхронизации
  static const String protocolVersion = '1.0';
}
