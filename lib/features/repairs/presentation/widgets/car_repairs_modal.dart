import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/repair.dart';
import '../bloc/repair_bloc.dart';
import '../bloc/repair_event.dart';
import '../bloc/repair_state.dart';
import 'repair_card.dart';
import 'repair_editor_modal.dart';

class CarRepairsModal extends StatefulWidget {
  final String carId;
  final String carName;

  const CarRepairsModal({
    Key? key,
    required this.carId,
    required this.carName,
  }) : super(key: key);

  @override
  State<CarRepairsModal> createState() => _CarRepairsModalState();
}

class _CarRepairsModalState extends State<CarRepairsModal> {
  @override
  void initState() {
    super.initState();
    context.read<RepairBloc>().add(LoadRepairs(carIdFilter: widget.carId));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Ремонты для ${widget.carName}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<RepairBloc, RepairState>(
                  builder: (context, state) {
                    if (state is RepairLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is RepairLoaded) {
                      final repairs = state.repairs.where((r) => r.carId == widget.carId).toList();
                      if (repairs.isEmpty) {
                        return const Center(
                          child: Text('Для данного автомобиля ремонтов нет.'),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: repairs.length,
                        itemBuilder: (context, index) {
                          final repair = repairs[index];
                          return RepairCard(
                            repair: repair,
                            onTap: () {
                              Navigator.pop(context); // Close the modal first
                              _openRepairEditor(context, repair);
                            },
                            onDelete: () => _confirmDelete(context, repair),
                          );
                        },
                      );
                    }
                    if (state is RepairError) {
                      return Center(
                        child: Text('Ошибка загрузки: ${state.message}'),
                      );
                    }
                    return const Center(
                      child: Text('Нет данных о ремонтах.'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openRepairEditor(BuildContext context, Repair repair) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RepairEditorModal(repair: repair),
    );
  }

  void _confirmDelete(BuildContext context, Repair repair) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить ремонт?'),
        content: Text(
            'Вы уверены, что хотите удалить ремонт "${repair.description}" для ${repair.carMake} ${repair.carModel}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RepairBloc>().add(DeleteRepairEvent(repairId: repair.id));
              Navigator.pop(context); // Close dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
