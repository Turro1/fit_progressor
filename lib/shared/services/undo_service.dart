import 'package:flutter/material.dart';

/// Сервис для отображения SnackBar с возможностью отмены действия
class UndoService {
  /// Длительность показа SnackBar для отмены
  static const Duration undoDuration = Duration(seconds: 5);

  /// Показывает SnackBar с возможностью отмены удаления.
  ///
  /// [context] - контекст для показа SnackBar
  /// [message] - сообщение об удалении
  /// [onUndo] - callback при нажатии "Отменить"
  /// [onDismissed] - callback когда SnackBar закрылся без отмены (опционально)
  static void showUndoSnackBar({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    VoidCallback? onDismissed,
  }) {
    final theme = Theme.of(context);

    // Убираем предыдущий SnackBar если есть
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: theme.colorScheme.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onInverseSurface),
              ),
            ),
          ],
        ),
        duration: undoDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'ОТМЕНИТЬ',
          textColor: theme.colorScheme.primary,
          onPressed: onUndo,
        ),
      ),
    );

    // Вызываем onDismissed когда SnackBar закрылся без отмены
    if (onDismissed != null) {
      controller.closed.then((reason) {
        if (reason != SnackBarClosedReason.action) {
          onDismissed();
        }
      });
    }
  }

  /// Показывает SnackBar успеха восстановления
  static void showRestoredSnackBar({
    required BuildContext context,
    required String message,
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.restore,
              color: theme.colorScheme.onSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
