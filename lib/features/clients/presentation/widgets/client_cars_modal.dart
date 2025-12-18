import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_state.dart';
import 'package:fit_progressor/features/cars/presentation/widgets/car_form_modal.dart';
import 'package:fit_progressor/features/cars/presentation/widgets/car_card.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fit_progressor/core/theme/app_spacing.dart';

import '../../domain/entities/client.dart';

class ClientCarsModal extends StatelessWidget {
  final Client client;

  const ClientCarsModal({Key? key, required this.client}) : super(key: key);

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch $phoneNumber');
    }
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
          // Header with client info
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                radius: 28,
                child: Text(
                  client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
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
                      client.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(client.phone, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              // Quick actions
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () => _makePhoneCall(client.phone),
                tooltip: 'Позвонить',
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),
          // Cars list
          Expanded(
            child: BlocBuilder<CarBloc, CarState>(
              builder: (context, state) {
                if (state is CarLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CarLoaded) {
                  final clientCars = state.cars
                      .where((car) => car.clientId == client.id)
                      .toList();

                  if (clientCars.isEmpty) {
                    return EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'Нет автомобилей',
                      message:
                          'У этого клиента пока нет добавленных автомобилей',
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: clientCars.length,
                    itemBuilder: (context, index) {
                      final car = clientCars[index];
                      return CarCard(
                        car: car,
                        onTap: () {
                          context.go('/cars/${car.id}/repairs');
                          Navigator.pop(context);
                        },
                        onEdit: null,
                        onDelete: null,
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
                    builder: (context) => CarFormModal(client: client),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Добавить авто'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
