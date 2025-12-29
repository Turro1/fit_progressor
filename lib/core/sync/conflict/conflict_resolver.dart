import 'package:fit_progressor/core/sync/sync_message.dart';

/// Результат разрешения конфликта
enum ConflictResolution {
  /// Использовать локальную версию
  useLocal,

  /// Использовать удалённую версию
  useRemote,

  /// Конфликта нет
  noConflict,
}

/// Результат разрешения конфликта с деталями
class ConflictResult {
  final ConflictResolution resolution;
  final ChangePayload? winningChange;
  final String? reason;

  const ConflictResult({
    required this.resolution,
    this.winningChange,
    this.reason,
  });

  bool get hasConflict => resolution != ConflictResolution.noConflict;
  bool get useLocal => resolution == ConflictResolution.useLocal;
  bool get useRemote => resolution == ConflictResolution.useRemote;
}

/// Разрешает конфликты между локальной и удалённой версией данных
/// Использует стратегию Last-Write-Wins
class ConflictResolver {
  /// Разрешить конфликт между локальной и удалённой версией
  ConflictResult resolve(ChangePayload local, ChangePayload remote) {
    // Проверяем что это одна и та же сущность
    if (local.entityId != remote.entityId ||
        local.entityType != remote.entityType) {
      return const ConflictResult(
        resolution: ConflictResolution.noConflict,
        reason: 'Different entities',
      );
    }

    // 1. Сравниваем версии
    if (remote.version > local.version) {
      return ConflictResult(
        resolution: ConflictResolution.useRemote,
        winningChange: remote,
        reason: 'Remote has higher version (${remote.version} > ${local.version})',
      );
    }

    if (local.version > remote.version) {
      return ConflictResult(
        resolution: ConflictResolution.useLocal,
        winningChange: local,
        reason: 'Local has higher version (${local.version} > ${remote.version})',
      );
    }

    // 2. При равных версиях сравниваем timestamp (last-write-wins)
    if (remote.changedAt.isAfter(local.changedAt)) {
      return ConflictResult(
        resolution: ConflictResolution.useRemote,
        winningChange: remote,
        reason: 'Remote has later timestamp (same version)',
      );
    }

    // По умолчанию сохраняем локальную версию
    return ConflictResult(
      resolution: ConflictResolution.useLocal,
      winningChange: local,
      reason: 'Local has later or equal timestamp (same version)',
    );
  }

  /// Проверить нужно ли применять удалённое изменение
  bool shouldApplyRemoteChange({
    required int localVersion,
    required DateTime localUpdatedAt,
    required int remoteVersion,
    required DateTime remoteChangedAt,
  }) {
    // Если удалённая версия выше - применяем
    if (remoteVersion > localVersion) {
      return true;
    }

    // Если версии равны - сравниваем время
    if (remoteVersion == localVersion) {
      return remoteChangedAt.isAfter(localUpdatedAt);
    }

    // Локальная версия выше - не применяем
    return false;
  }

  /// Определить следующую версию после разрешения конфликта
  int nextVersion(int localVersion, int remoteVersion) {
    return (localVersion > remoteVersion ? localVersion : remoteVersion) + 1;
  }
}
