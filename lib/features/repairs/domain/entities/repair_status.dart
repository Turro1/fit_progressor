import 'package:equatable/equatable.dart';

enum RepairStatus {
  inProgress('В работе'),
  waitingParts('Ожидает запчасти'),
  completed('Завершен'),
  cancelled('Отменен');

  final String displayName;

  const RepairStatus(this.displayName);

  bool get isActive =>
      this == RepairStatus.inProgress || this == RepairStatus.waitingParts;

  static RepairStatus fromString(String value) {
    return RepairStatus.values.firstWhere(
      (status) => status.toString() == value,
      orElse: () => RepairStatus.inProgress,
    );
  }
}

class RepairStatusConverter extends Equatable {
  final RepairStatus status;

  const RepairStatusConverter({required this.status});

  @override
  List<Object?> get props => [status];
}
