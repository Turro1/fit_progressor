import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';

/// Обогащенная модель ремонта с данными клиента и автомобиля
/// для отображения на дашборде
class RepairWithDetails extends Equatable {
  final Repair repair;
  final String clientName;
  final String? clientPhone;
  final String carFullName;

  const RepairWithDetails({
    required this.repair,
    required this.clientName,
    this.clientPhone,
    required this.carFullName,
  });

  @override
  List<Object?> get props => [repair, clientName, clientPhone, carFullName];
}
