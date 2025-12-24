enum RepairStatus {
  pending('pending', 'Ожидает'),
  inProgress('in_progress', 'В работе'),
  completed('completed', 'Завершен'),
  cancelled('cancelled', 'Отменен');

  final String value;
  final String displayName;

  const RepairStatus(this.value, this.displayName);

  static RepairStatus fromString(String value) {
    return RepairStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => RepairStatus.pending,
    );
  }

  @override
  String toString() => value;
}
