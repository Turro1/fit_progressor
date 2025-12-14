import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/repair.dart';
import '../bloc/repair_bloc.dart';
import '../bloc/repair_event.dart';
import '../bloc/repair_state.dart';
import '../widgets/repair_card.dart';
import '../widgets/repair_editor_modal.dart';
import '../widgets/repair_search_bar.dart';
import '../widgets/repair_wizard_modal.dart';
import '../../domain/entities/repair_status.dart';

class RepairsPage extends StatelessWidget {
  const RepairsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Добавлено
                    children: [
                      Row( // Оборачиваем Icon и Text в отдельный Row для выравнивания
                        children: [
                          Icon(
                            Icons.build, // Иконка для ремонтов
                            color: AppColors.textPrimary,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Ремонты',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      BlocBuilder<RepairBloc, RepairState>( // Для обновления DropdownButton
                        builder: (context, state) {
                          RepairStatus? selectedStatus;
                          if (state is RepairLoaded) {
                            selectedStatus = state.statusFilter; // Получаем statusFilter из RepairLoaded
                          }
                          // Если фильтр был сброшен (null), то DropdownButton покажет "Все"
                          // Иначе покажет выбранный статус

                          return DropdownButton<RepairStatus?>(
                            value: selectedStatus,
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                            dropdownColor: AppColors.surface,
                            underline: const SizedBox(), // Убираем подчеркивание
                            onChanged: (RepairStatus? newValue) {
                              context.read<RepairBloc>().add(FilterRepairsByStatusEvent(status: newValue));
                            },
                            items: [
                              DropdownMenuItem<RepairStatus?>(
                                value: null, // Опция "Все"
                                child: Text(
                                  'Все',
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                              ...RepairStatus.values.map<DropdownMenuItem<RepairStatus?>>((RepairStatus status) {
                                return DropdownMenuItem<RepairStatus?>(
                                  value: status,
                                  child: Text(
                                    status.displayName,
                                    style: TextStyle(color: AppColors.textPrimary),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Добавлено для соответствия CarsPage
                  RepairSearchBar(
                    onSearch: (query) {
                      context.read<RepairBloc>().add(SearchRepairsEvent(query: query));
                    },
                  ),
                  BlocBuilder<RepairBloc, RepairState>(
                    builder: (context, state) {
                      if (state is RepairLoaded && state.carIdFilter != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Фильтр по авто: ${state.repairs.isNotEmpty ? '${state.repairs.first.carMake} ${state.repairs.first.carModel}' : state.carIdFilter}',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              IconButton(
                                icon: Icon(Icons.clear, color: AppColors.error),
                                onPressed: () {
                                  context.read<RepairBloc>().add(LoadRepairs());
                                },
                              )
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final state = context.read<RepairBloc>().state;
                  if (state is RepairLoaded) {
                    context.read<RepairBloc>().add(LoadRepairs(carIdFilter: state.carIdFilter));
                  } else {
                    context.read<RepairBloc>().add(LoadRepairs());
                  }
                },
                child: BlocConsumer<RepairBloc, RepairState>(
                  listener: (context, state) {
                    if (state is RepairError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    } else if (state is RepairOperationSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is RepairLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      );
                    } else if (state is RepairLoaded) {
                      if (state.repairs.isEmpty) {
                        return Center(
                          child: Text(
                            state.carIdFilter != null ? 'Нет ремонтов для этого автомобиля' : 'Ремонты не найдены',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: state.repairs.length,
                        itemBuilder: (context, index) {
                          final repair = state.repairs[index];
                          return RepairCard(
                            repair: repair,
                            onTap: () => _openRepairEditor(context, repair),
                            onDelete: () => _confirmDelete(context, repair),
                          );
                        },
                      );
                    }
                    return Center(
                      child: Text(
                        'Начните добавлять ремонты',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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
        content: Text('Вы уверены, что хотите удалить ремонт "${repair.description}" для ${repair.carMake} ${repair.carModel}?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RepairBloc>().add(DeleteRepairEvent(repairId: repair.id));
              context.pop(); // Close dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
