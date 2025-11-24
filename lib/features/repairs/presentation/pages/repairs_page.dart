import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/repair.dart';
import '../bloc/repair_bloc.dart';
import '../bloc/repair_event.dart';
import '../bloc/repair_state.dart';
import '../widgets/repair_card.dart';
import '../widgets/repair_search_bar.dart';
import '../widgets/repair_editor_modal.dart';
import '../widgets/status_filter_chips.dart';

class RepairsPage extends StatelessWidget {
  const RepairsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.build,
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
                  const SizedBox(height: 20),
                  RepairSearchBar(
                    onSearch: (query) {
                      context.read<RepairBloc>().add(
                            SearchRepairsEvent(query: query),
                          );
                    },
                  ),
                  const SizedBox(height: 15),
                  StatusFilterChips(
                    onFilterChanged: (status) {
                      context.read<RepairBloc>().add(
                            FilterRepairsByStatusEvent(status: status),
                          );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<RepairBloc, RepairState>(
                listener: (context, state) {
                  if (state is RepairError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                  if (state is RepairOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.accentSecondary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is RepairLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPrimary,
                      ),
                    );
                  }

                  if (state is RepairLoaded) {
                    if (state.repairs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.build_outlined,
                              size: 80,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.statusFilter != null
                                  ? 'Нет ремонтов с таким статусом'
                                  : 'Нет ремонтов',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Нажмите "+" для создания ремонта',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
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

                  return const SizedBox();
                },
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
        backgroundColor: AppColors.bgCard,
        title: Text(
          'Удалить ремонт?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Это действие нельзя отменить. Списанные материалы будут возвращены на склад.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<RepairBloc>().add(
                    DeleteRepairEvent(repairId: repair.id),
                  );
              Navigator.pop(context);
            },
            child: Text(
              'Удалить',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}