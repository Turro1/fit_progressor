import 'package:fit_progressor/core/sync/sync_config.dart';

/// Данные для QR-кода подключения
class QrDataModel {
  final String serverIp;
  final int port;
  final String serverName;
  final String serverId;

  const QrDataModel({
    required this.serverIp,
    required this.port,
    required this.serverName,
    required this.serverId,
  });

  /// Преобразовать в строку для QR-кода
  /// Формат: fitprogressor://ip:port?name=Name&id=uuid
  String toQrString() {
    final encodedName = Uri.encodeComponent(serverName);
    return '${SyncConfig.uriScheme}://$serverIp:$port?name=$encodedName&id=$serverId';
  }

  /// Создать из строки QR-кода
  factory QrDataModel.fromQrString(String qrString) {
    // Проверяем схему
    if (!qrString.startsWith('${SyncConfig.uriScheme}://')) {
      throw FormatException('Invalid QR code format: wrong scheme');
    }

    // Убираем схему
    final withoutScheme = qrString.substring('${SyncConfig.uriScheme}://'.length);

    // Разбираем host:port и query параметры
    final parts = withoutScheme.split('?');
    if (parts.isEmpty) {
      throw FormatException('Invalid QR code format: no host');
    }

    final hostPort = parts[0].split(':');
    if (hostPort.length != 2) {
      throw FormatException('Invalid QR code format: invalid host:port');
    }

    final serverIp = hostPort[0];
    final port = int.tryParse(hostPort[1]);
    if (port == null) {
      throw FormatException('Invalid QR code format: invalid port');
    }

    // Разбираем query параметры
    String serverName = 'Unknown Server';
    String serverId = '';

    if (parts.length > 1) {
      final queryParams = Uri.splitQueryString(parts[1]);
      serverName = queryParams['name'] ?? serverName;
      serverId = queryParams['id'] ?? '';
    }

    return QrDataModel(
      serverIp: serverIp,
      port: port,
      serverName: serverName,
      serverId: serverId,
    );
  }

  /// Создать из URI
  factory QrDataModel.fromUri(Uri uri) {
    if (uri.scheme != SyncConfig.uriScheme) {
      throw FormatException('Invalid URI scheme: ${uri.scheme}');
    }

    return QrDataModel(
      serverIp: uri.host,
      port: uri.port,
      serverName: uri.queryParameters['name'] ?? 'Unknown Server',
      serverId: uri.queryParameters['id'] ?? '',
    );
  }

  /// Преобразовать в URI
  Uri toUri() {
    return Uri(
      scheme: SyncConfig.uriScheme,
      host: serverIp,
      port: port,
      queryParameters: {
        'name': serverName,
        'id': serverId,
      },
    );
  }

  /// Получить WebSocket URL для подключения
  String get webSocketUrl => 'ws://$serverIp:$port';

  @override
  String toString() {
    return 'QrDataModel(serverIp: $serverIp, port: $port, serverName: $serverName, serverId: $serverId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QrDataModel &&
        other.serverIp == serverIp &&
        other.port == port &&
        other.serverName == serverName &&
        other.serverId == serverId;
  }

  @override
  int get hashCode {
    return serverIp.hashCode ^
        port.hashCode ^
        serverName.hashCode ^
        serverId.hashCode;
  }
}
