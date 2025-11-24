// lib/features/cars/presentation/widgets/car_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_state.dart';
import '../../domain/entities/car.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CarCard({
    Key? key,
    required this.car,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.make} ${car.model}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        car.plate,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                BlocBuilder<ClientBloc, ClientState>(
                  builder: (context, state) {
                    String ownerName = 'Владелец не найден';
                    
                    if (state is ClientLoaded) {
                      try {
                        final owner = state.clients.firstWhere(
                          (client) => client.id == car.clientId,
                        );
                        ownerName = owner.name;
                      } catch (e) {
                        ownerName = 'Владелец не найден';
                      }
                    }

                    return Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ownerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit, color: AppColors.textPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.bgHeader,
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete, color: AppColors.danger),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.bgHeader,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}