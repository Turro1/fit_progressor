enum RepairStatus {
  inProgress('в работе'),
  waitingParts('ожидает запчасти'),
  completed('выполнено'),
  cancelled('отменен');

  final String displayName;
  const RepairStatus(this.displayName);

  static RepairStatus fromString(String value) {
    return RepairStatus.values.firstWhere(
      (status) => status.displayName == value,
      orElse: () => RepairStatus.inProgress,
    );
  }
}