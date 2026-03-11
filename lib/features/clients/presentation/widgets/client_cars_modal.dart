import 'package:car_repair_manager/features/cars/presentation/bloc/car_bloc.dart';
import 'package:car_repair_manager/features/cars/presentation/bloc/car_state.dart';
import 'package:car_repair_manager/features/cars/presentation/widgets/car_form_modal.dart';
import 'package:car_repair_manager/features/cars/presentation/widgets/car_repairs_modal.dart';
import 'package:car_repair_manager/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:car_repair_manager/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:car_repair_manager/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:car_repair_manager/core/theme/app_spacing.dart';
import 'package:car_repair_manager/core/utils/car_logo_helper.dart';
import 'package:car_repair_manager/core/widgets/country_flag.dart';
import 'package:car_repair_manager/features/cars/domain/entities/car.dart';

import '../../domain/entities/client.dart';

class ClientCarsModal extends StatelessWidget {
  final Client client;

  const ClientCarsModal({super.key, required this.client});

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  int _getRepairsCountForCar(String carId, RepairsState state) {
    if (state is RepairsLoaded) {
      return state.allRepairs.where((r) => r.carId == carId).length;
    }
    return 0;
  }

  void _openCarRepairsModal(BuildContext context, Car car) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CarRepairsModal(
        car: car,
        sourceClient: client, // передаём клиента для кнопки "Назад"
      ),
    );
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
            padding: const EdgeInsets.only(
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
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                        client.name.isNotEmpty
                            ? client.name[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(client.phone, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    if (client.phone.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () => _makePhoneCall(client.phone),
                        tooltip: 'Позвонить',
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Заголовок секции
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Автомобили',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Cars list
          Expanded(
            child: BlocBuilder<CarBloc, CarState>(
              builder: (context, carState) {
                if (carState is CarLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (carState is CarLoaded) {
                  final clientCars = carState.cars
                      .where((car) => car.clientId == client.id)
                      .toList();

                  if (clientCars.isEmpty) {
                    return const EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'Нет автомобилей',
                      message:
                          'У этого клиента пока нет добавленных автомобилей',
                    );
                  }

                  return BlocBuilder<RepairsBloc, RepairsState>(
                    builder: (context, repairsState) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: clientCars.length,
                        itemBuilder: (context, index) {
                          final car = clientCars[index];
                          final repairsCount = _getRepairsCountForCar(
                            car.id,
                            repairsState,
                          );

                          return _buildCarCard(
                            context,
                            theme,
                            car,
                            repairsCount,
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CarFormModal(client: client),
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

  Widget _buildCarCard(
    BuildContext context,
    ThemeData theme,
    Car car,
    int repairsCount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openCarRepairsModal(context, car),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: CarLogoHelper.getLogoWidget(
                    context,
                    car.make,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
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
                    const SizedBox(height: AppSpacing.xs),
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
              if (repairsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.build_circle_outlined,
                        size: 14,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$repairsCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
