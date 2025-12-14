import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_state.dart';
import 'package:fit_progressor/features/cars/presentation/widgets/car_form_modal.dart';
import 'package:fit_progressor/features/cars/presentation/widgets/car_card.dart'; // Added this import
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Added this import
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

import '../../domain/entities/client.dart';

class ClientCarsModal extends StatelessWidget {
  final Client client;

  const ClientCarsModal({Key? key, required this.client}) : super(key: key);

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Handle error: could not launch phone call
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Автомобили клиента',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                icon: Icon(Icons.phone, color: theme.colorScheme.primary),
                onPressed: () => _makePhoneCall(client.phone),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            client.name,
            style: theme.textTheme.titleMedium,
          ),
          Text(
            client.phone,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
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
                    return Center(
                      child: Text(
                        'У этого клиента нет автомобилей.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: clientCars.length,
                    itemBuilder: (context, index) {
                      final car = clientCars[index];
                      return CarCard(
                        car: car,
                        onTap: () {
                          context.go('/cars/${car.id}/repairs');
                          Navigator.pop(context); // Close the modal
                        },
                        onEdit: null, // No edit action from this modal
                        onDelete: null, // No delete action from this modal
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close this modal first
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CarFormModal(client: client),
                  );
                },
                child: const Text('Добавить авто'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
