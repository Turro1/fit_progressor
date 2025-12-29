import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:fit_progressor/core/sync/bloc/sync_bloc.dart';
import 'package:fit_progressor/core/sync/bloc/sync_event.dart';
import 'package:fit_progressor/core/sync/bloc/sync_state.dart';
import 'package:fit_progressor/core/sync/sync_engine.dart';
import 'package:fit_progressor/core/sync/qr/qr_data_model.dart';
import 'package:fit_progressor/core/sync/client/sync_client.dart';

/// Страница настройки синхронизации
class SyncSettingsPage extends StatelessWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Синхронизация'),
            actions: [
              if (state.isActive)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<SyncBloc>().add(const SyncRefreshQrData());
                  },
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SyncState state) {
    // Синхронизация недоступна на Web
    if (kIsWeb) {
      return _buildWebNotSupported(context);
    }

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return _buildError(context, state);
    }

    if (state.mode == SyncMode.server) {
      return _buildServerMode(context, state);
    }

    if (state.mode == SyncMode.client) {
      return _buildClientMode(context, state);
    }

    return _buildModeSelection(context, state);
  }

  Widget _buildWebNotSupported(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.desktop_windows,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Синхронизация недоступна в веб-версии',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Используйте настольное или мобильное приложение для синхронизации данных между устройствами.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, SyncState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Произошла ошибка',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SyncBloc>().add(const SyncInitialize());
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDesktopPlatform() {
    if (kIsWeb) return true; // Web считаем десктопом
    return defaultTargetPlatform == TargetPlatform.windows ||
           defaultTargetPlatform == TargetPlatform.macOS ||
           defaultTargetPlatform == TargetPlatform.linux;
  }

  Widget _buildModeSelection(BuildContext context, SyncState state) {
    final isDesktop = _isDesktopPlatform();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Информация об устройстве
        Card(
          child: ListTile(
            leading: const Icon(Icons.devices),
            title: Text(state.deviceName),
            subtitle: Text('ID: ${state.deviceId.substring(0, 8)}...'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditNameDialog(context, state),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Заголовок
        Text(
          'Выберите режим работы',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // Режим сервера
        _buildModeCard(
          context,
          icon: Icons.cloud_upload,
          title: 'Режим сервера',
          description: isDesktop
              ? 'Этот компьютер будет основным хранилищем данных. Телефоны смогут подключаться для синхронизации.'
              : 'Это устройство будет основным хранилищем данных.',
          buttonText: 'Запустить сервер',
          onPressed: () {
            context.read<SyncBloc>().add(const SyncStartServer());
          },
        ),
        const SizedBox(height: 16),

        // Режим клиента
        _buildModeCard(
          context,
          icon: Icons.cloud_download,
          title: 'Режим клиента',
          description: 'Подключиться к другому устройству для синхронизации данных.',
          buttonText: 'Сканировать QR-код',
          onPressed: () => _showQrScanner(context),
          enabled: !isDesktop, // QR сканер только на мобильных
        ),

        if (isDesktop) ...[
          const SizedBox(height: 8),
          Text(
            'Сканирование QR-кода доступно только на мобильных устройствах',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: enabled ? onPressed : null,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerMode(BuildContext context, SyncState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Статус
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: Icon(
              Icons.cloud_done,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            title: Text(
              'Сервер запущен',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            subtitle: Text(
              '${state.connectedClients.length} подключений',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // QR код
        if (state.qrData != null) ...[
          Text(
            'QR-код для подключения',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    QrImageView(
                      data: state.qrData!.toQrString(),
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'IP: ${state.qrData!.serverIp}:${state.qrData!.port}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Отсканируйте этот код на телефоне для подключения',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
        const SizedBox(height: 24),

        // Подключенные устройства
        if (state.connectedClients.isNotEmpty) ...[
          Text(
            'Подключенные устройства',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...state.connectedClients.map(
            (client) => Card(
              child: ListTile(
                leading: const Icon(Icons.smartphone),
                title: Text(client.deviceName),
                subtitle: Text(client.ipAddress),
                trailing: Text(
                  _formatTime(client.lastSeenAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),

        // Кнопка остановки
        OutlinedButton.icon(
          onPressed: () {
            context.read<SyncBloc>().add(const SyncStopServer());
          },
          icon: const Icon(Icons.stop),
          label: const Text('Остановить сервер'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildClientMode(BuildContext context, SyncState state) {
    final isConnected = state.connectionState == SyncConnectionState.connected;
    final isConnecting = state.connectionState == SyncConnectionState.connecting;
    final isReconnecting = state.connectionState == SyncConnectionState.reconnecting;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Статус подключения
        Card(
          color: isConnected
              ? Theme.of(context).colorScheme.primaryContainer
              : isConnecting || isReconnecting
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.errorContainer,
          child: ListTile(
            leading: Icon(
              isConnected
                  ? Icons.cloud_done
                  : isConnecting || isReconnecting
                      ? Icons.cloud_sync
                      : Icons.cloud_off,
            ),
            title: Text(
              isConnected
                  ? 'Подключено'
                  : isConnecting
                      ? 'Подключение...'
                      : isReconnecting
                          ? 'Переподключение...'
                          : 'Отключено',
            ),
            subtitle: state.serverInfo != null
                ? Text(state.serverInfo!.serverName)
                : null,
          ),
        ),
        const SizedBox(height: 24),

        // Информация о сервере
        if (state.serverInfo != null) ...[
          Text(
            'Сервер',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns),
                  title: Text(state.serverInfo!.serverName),
                  subtitle: Text('ID: ${state.serverInfo!.serverId.substring(0, 8)}...'),
                ),
                ListTile(
                  leading: const Icon(Icons.wifi),
                  title: const Text('Адрес'),
                  subtitle: Text('${state.serverInfo!.serverIp}:${state.serverInfo!.port}'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        // Кнопка отключения
        OutlinedButton.icon(
          onPressed: () {
            context.read<SyncBloc>().add(const SyncDisconnectFromServer());
          },
          icon: const Icon(Icons.link_off),
          label: const Text('Отключиться'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'только что';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} мин. назад';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showEditNameDialog(BuildContext context, SyncState state) {
    final controller = TextEditingController(text: state.deviceName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Имя устройства'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Имя',
            hintText: 'Введите имя устройства',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<SyncBloc>().add(SyncUpdateDeviceName(name));
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showQrScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QrScannerScreen(
          onScanned: (data) {
            Navigator.pop(context);
            context.read<SyncBloc>().add(SyncConnectToServer(data));
          },
        ),
      ),
    );
  }
}

/// Экран сканирования QR-кода
class _QrScannerScreen extends StatefulWidget {
  final void Function(QrDataModel data) onScanned;

  const _QrScannerScreen({required this.onScanned});

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканирование QR-кода'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Text(
              'Наведите камеру на QR-код\nна экране компьютера',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null) continue;

      try {
        final data = QrDataModel.fromQrString(value);
        _isProcessing = true;
        widget.onScanned(data);
        return;
      } catch (_) {
        // Не валидный QR код, продолжаем сканирование
      }
    }
  }
}
