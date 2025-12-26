import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_state.dart';
import 'package:fit_progressor/features/cars/presentation/widgets/car_form_modal.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_card.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fit_progressor/core/theme/app_spacing.dart';
import 'package:fit_progressor/core/utils/car_logo_helper.dart';
import 'package:fit_progressor/core/widgets/country_flag.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';

import '../../domain/entities/client.dart';

class ClientCarsModal extends StatefulWidget {
  final Client client;

  const ClientCarsModal({super.key, required this.client});

  @override
  State<ClientCarsModal> createState() => _ClientCarsModalState();
}

class _ClientCarsModalState extends State<ClientCarsModal> {
  final Set<String> _expandedCars = {};

  @override
  void initState() {
    super.initState();
    // Загружаем все ремонты клиента
    context.read<RepairsBloc>().add(LoadRepairs(clientId: widget.client.id));
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  List<Repair> _getRepairsForCar(String carId, RepairsState state) {
    if (state is RepairsLoaded) {
      return state.repairs.where((r) => r.carId == carId).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.lg,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
            ),
            child: Column(
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
                // Client info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      radius: 28,
                      child: Text(
                        widget.client.name.isNotEmpty
                            ? widget.client.name[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.client.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.client.phone,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () => _makePhoneCall(widget.client.phone),
                      tooltip: 'Позвонить',
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // Заголовок секции
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Автомобили',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Cars list with expandable repairs
          Expanded(
            child: BlocBuilder<CarBloc, CarState>(
              builder: (context, carState) {
                if (carState is CarLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (carState is CarLoaded) {
                  final clientCars = carState.cars
                      .where((car) => car.clientId == widget.client.id)
                      .toList();

                  if (clientCars.isEmpty) {
                    return const EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'Нет автомобилей',
                      message: 'У этого клиента пока нет добавленных автомобилей',
                    );
                  }

                  return BlocBuilder<RepairsBloc, RepairsState>(
                    builder: (context, repairsState) {
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: clientCars.length,
                        itemBuilder: (context, index) {
                          final car = clientCars[index];
                          final repairs = _getRepairsForCar(car.id, repairsState);
                          final isExpanded = _expandedCars.contains(car.id);

                          return _buildExpandableCarCard(
                            context,
                            theme,
                            car,
                            repairs,
                            isExpanded,
                            repairsState is RepairsLoading,
                          );
                        },
                      );
                    },
                  );
                }

                return Center(
                  child: Text(
                    'Не удалось загрузить автомобили',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              },
            ),
          ),
          // Add car button
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CarFormModal(client: widget.client),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Добавить автомобиль'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCarCard(
    BuildContext context,
    ThemeData theme,
    Car car,
    List<Repair> repairs,
    bool isExpanded,
    bool isLoading,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Car header (clickable)
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCars.remove(car.id);
                } else {
                  _expandedCars.add(car.id);
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Car logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        CarLogoHelper.getLogoPath(car.make),
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.directions_car_rounded,
                            size: 28,
                            color: theme.colorScheme.onSecondaryContainer,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // Car info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car.make} ${car.model}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        PlateWithFlag(
                          plate: car.plate,
                          textStyle: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Repairs count badge
                  if (repairs.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${repairs.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(width: AppSpacing.sm),
                  // Expand icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded repairs section
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildRepairsSection(context, theme, car, repairs, isLoading),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairsSection(
    BuildContext context,
    ThemeData theme,
    Car car,
    List<Repair> repairs,
    bool isLoading,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repairs header
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Ремонты',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Repairs list or empty state
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (repairs.isEmpty)
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: 32,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Нет ремонтов',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              itemCount: repairs.length,
              itemBuilder: (context, index) {
                return RepairCard(
                  repair: repairs[index],
                  compact: true,
                );
              },
            ),
          // Add repair button
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addRepairForCar(context, car),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Добавить ремонт'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addRepairForCar(BuildContext context, Car car) {
    final repairsBloc = context.read<RepairsBloc>();
    final carBloc = context.read<CarBloc>();
    final clientBloc = context.read<ClientBloc>();

    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: repairsBloc),
          BlocProvider.value(value: carBloc),
          BlocProvider.value(value: clientBloc),
        ],
        child: RepairFormModal(
          preselectedCarId: car.id,
          preselectedClientId: car.clientId,
        ),
      ),
    );
  }
}
