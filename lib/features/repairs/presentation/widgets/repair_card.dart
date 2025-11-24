import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cars/domain/entities/car.dart';
import '../../../cars/presentation/bloc/car_bloc.dart';
import '../../../cars/presentation/bloc/car_state.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_state.dart';
import '../../domain/entities/repair.dart';
import 'status_tag.dart';

class RepairCard extends StatelessWidget {
  final Repair repair;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RepairCard({
    Key? key,
    required this.repair,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      StatusTag(status: repair.status),
                      const SizedBox(width: 8),
                      if (repair.photos.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.photo_camera,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${repair.photos.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, color: AppColors.danger, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<CarBloc, CarState>(
              builder: (context, carState) {
                Car? car;
                if (carState is CarLoaded) {
                  try {
                    car = carState.cars.firstWhere((c) => c.id == repair.carId);
                  } catch (_) {}
                }

                return BlocBuilder<ClientBloc, ClientState>(
                  builder: (context, clientState) {
                    Client? client;
                    if (clientState is ClientLoaded && car != null) {
                      try {
                        client = clientState.clients
                            .firstWhere((c) => c.id == car!.clientId);
                      } catch (_) {}
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car != null
                              ? '${car.make} ${car.model}'
                              : 'Авто удалено',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (client != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                client.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (car?.plate != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '(${car!.plate})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              repair.description.length > 80
                  ? '${repair.description.substring(0, 80)}...'
                  : repair.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Итого:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(repair.totalCost),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}