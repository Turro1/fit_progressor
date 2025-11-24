import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cars/presentation/bloc/car_bloc.dart';
import '../../../cars/presentation/bloc/car_state.dart';
import '../../domain/entities/client.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientCard({
    Key? key,
    required this.client,
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
                  client.name,
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
                      Icons.call,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        client.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                BlocBuilder<CarBloc, CarState>(
                  builder: (context, state) {
                    int carCount = 0;
                    if (state is CarLoaded) {
                      carCount = state.cars
                          .where((car) => car.clientId == client.id)
                          .length;
                    }

                    return Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Автомобилей: $carCount',
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