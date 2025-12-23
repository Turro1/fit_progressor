import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_card.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_progressor/core/theme/app_spacing.dart';
import 'package:fit_progressor/core/utils/car_logo_helper.dart';

import '../../domain/entities/car.dart';

class CarRepairsModal extends StatefulWidget {
  final Car car;

  const CarRepairsModal({Key? key, required this.car}) : super(key: key);

  @override
  State<CarRepairsModal> createState() => _CarRepairsModalState();
}

class _CarRepairsModalState extends State<CarRepairsModal> {
  @override
  void initState() {
    super.initState();
    // Загружаем ремонты для конкретного автомобиля
    context.read<RepairsBloc>().add(LoadRepairs(carId: widget.car.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header with car info
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    CarLogoHelper.getLogoPath(widget.car.make),
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.directions_car_rounded,
                        size: 32,
                        color: theme.colorScheme.onSecondaryContainer,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.car.make} ${widget.car.model}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 16,
                          color: theme.iconTheme.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.car.plate,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),
          // Repairs list
          Expanded(
            child: BlocBuilder<RepairsBloc, RepairsState>(
              builder: (context, state) {
                if (state is RepairsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RepairsLoaded) {
                  if (state.repairs.isEmpty) {
                    return EmptyState(
                      icon: Icons.build_circle_outlined,
                      title: 'Нет ремонтов',
                      message:
                          'У этого автомобиля пока нет зарегистрированных ремонтов',
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.repairs.length,
                    itemBuilder: (context, index) {
                      final repair = state.repairs[index];
                      return RepairCard(repair: repair);
                    },
                  );
                }

                return Center(
                  child: Text(
                    'Не удалось загрузить ремонты',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
              SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<RepairsBloc>(),
                      child: RepairFormModal(
                        preselectedCarId: widget.car.id,
                        preselectedClientId: widget.car.clientId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Добавить ремонт'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
