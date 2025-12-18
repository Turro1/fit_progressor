import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/repairs_bloc.dart';
import '../bloc/repairs_event.dart';
import '../bloc/repairs_state.dart';
import '../widgets/repair_card.dart';
import '../widgets/repair_form_modal.dart';
import 'package:fit_progressor/shared/widgets/app_search_bar.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({Key? key}) : super(key: key);

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  @override
  void initState() {
    super.initState();
    // Load repairs on init
    context.read<RepairsBloc>().add(const LoadRepairs());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRepairModal(context),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with icon and title
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Icon(
                    Icons.build,
                    color: theme.colorScheme.onSurface,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text('Ремонты', style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: AppSearchBar(
                hintText: 'Поиск по описанию...',
                onSearch: (query) {
                  context.read<RepairsBloc>().add(
                    SearchRepairsEvent(query: query),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            // Content
            Expanded(
              child: BlocConsumer<RepairsBloc, RepairsState>(
                listener: (context, state) {
                  if (state is RepairsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  if (state is RepairsOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is RepairsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RepairsLoaded) {
                    if (state.repairs.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<RepairsBloc>().add(const LoadRepairs());
                        },
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: EmptyState(
                                icon: Icons.build_circle_outlined,
                                title: 'Нет ремонтов',
                                message:
                                    'Добавьте первый ремонт, нажав кнопку "Добавить"',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<RepairsBloc>().add(const LoadRepairs());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: state.repairs.length,
                        itemBuilder: (context, index) {
                          final repair = state.repairs[index];
                          return RepairCard(
                            repair: repair,
                            onEdit: () => _showRepairModal(context, repair),
                            onDelete: () => _confirmDelete(context, repair),
                          );
                        },
                      ),
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

  void _showRepairModal(BuildContext context, [Repair? repair]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RepairFormModal(repair: repair),
    );
  }

  void _confirmDelete(BuildContext context, Repair repair) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить ремонт?'),
        content: Text(
          'Вы уверены, что хотите удалить этот ремонт?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<RepairsBloc>().add(
                DeleteRepairEvent(repairId: repair.id),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Удалить',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
