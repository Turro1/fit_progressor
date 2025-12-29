import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

/// Сервис для получения информации о сети
class NetworkInfoService {
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Получить локальный IP адрес устройства
  Future<String?> getLocalIpAddress() async {
    // Пробуем получить WiFi IP (для мобильных устройств)
    try {
      final wifiIP = await _networkInfo.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty) {
        return wifiIP;
      }
    } catch (_) {
      // Игнорируем ошибки и пробуем другой способ
    }

    // Fallback: ищем IP через NetworkInterface (для десктопа)
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        // Пропускаем loopback и virtual интерфейсы
        if (interface.name.toLowerCase().contains('loopback') ||
            interface.name.toLowerCase().contains('virtual') ||
            interface.name.toLowerCase().contains('vethernet')) {
          continue;
        }

        for (final addr in interface.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            final ip = addr.address;
            // Пропускаем link-local адреса (169.254.x.x)
            if (!ip.startsWith('169.254')) {
              return ip;
            }
          }
        }
      }
    } catch (_) {
      // Игнорируем ошибки
    }

    return null;
  }

  /// Получить имя WiFi сети
  Future<String?> getWifiName() async {
    try {
      return await _networkInfo.getWifiName();
    } catch (_) {
      return null;
    }
  }

  /// Получить все доступные IP адреса
  Future<List<String>> getAllIpAddresses() async {
    final addresses = <String>[];

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('169.254')) {
            addresses.add(addr.address);
          }
        }
      }
    } catch (_) {
      // Игнорируем ошибки
    }

    return addresses;
  }

  /// Проверить доступность хоста
  Future<bool> isHostReachable(String host, int port, {Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: timeout,
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
