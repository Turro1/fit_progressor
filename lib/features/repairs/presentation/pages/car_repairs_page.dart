import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/theme/app_colors.dart'; // Removed direct import
import '../../domain/entities/repair.dart';
import '../bloc/repair_bloc.dart';
import '../bloc/repair_event.dart';
import '../bloc/repair_state.dart';
import '../widgets/repair_card.dart';
import '../widgets/repair_editor_modal.dart';


class CarRepairsPage extends StatefulWidget {
  final String carId;

  const CarRepairsPage({Key? key, required this.carId}) : super(key: key);

  @override
  State<CarRepairsPage> createState() => _CarRepairsPageState();
}

class _CarRepairsPageState extends State<CarRepairsPage> {
  @override
  void initState() {
    super.initState();
    // Load repairs filtered by carId
    context.read<RepairBloc>().add(LoadRepairs(carIdFilter: widget.carId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ремонты автомобиля',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: BlocConsumer<RepairBloc, RepairState>(
        listener: (context, state) {
          if (state is RepairError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is RepairOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // After successful operation, refresh repairs for this car
            context.read<RepairBloc>().add(LoadRepairs(carIdFilter: widget.carId));
          }
        },
        builder: (context, state) {
          if (state is RepairLoading) {
            return Center(
              child: CircularProgressIndicator(color: theme.colorScheme.secondary),
            );
          } else if (state is RepairLoaded) {
            final carRepairs = state.repairs.where((r) => r.carId == widget.carId).toList(); // Ensure filtering in UI as well

            if (carRepairs.isEmpty) {
              return Center(
                child: Text(
                  'Нет ремонтов для этого автомобиля.',
style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              itemCount: carRepairs.length,
              itemBuilder: (context, index) {
                final repair = carRepairs[index];
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
              'Не удалось загрузить ремонты.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          );
        },
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить ремонт?'), // Use const for Text
        content: Text('Вы уверены, что хотите удалить ремонт "${repair.description}" для ${repair.carMake} ${repair.carModel}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'), // Use const for Text
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RepairBloc>().add(DeleteRepairEvent(repairId: repair.id));
              Navigator.pop(context); // Close dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: const Text('Удалить'), // Use const for Text
          ),
        ],
      ),
    );
  }
}
