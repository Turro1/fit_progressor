enum RepairStatus {
  inProgress('в работе'),
  waitingForParts('ожидает запчасти'),
  completed('выполнено'),
  cancelled('отменен');

  const RepairStatus(this.displayName);
  final String displayName;

  static RepairStatus fromString(String value) {
    return RepairStatus.values.firstWhere(
      (e) => e.displayName == value,
      orElse: () => RepairStatus.inProgress,
    );
  }
}