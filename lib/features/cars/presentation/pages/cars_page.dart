import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_event.dart';
import '../../../repairs/presentation/bloc/repair_bloc.dart';
import '../../../repairs/presentation/bloc/repair_event.dart';
import '../../domain/entities/car.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import '../widgets/car_card.dart';
import '../widgets/car_form_modal.dart';
import '../widgets/car_search_bar.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({Key? key}) : super(key: key);

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем клиентов для выбора владельца
    context.read<ClientBloc>().add(LoadClients());
    // Загружаем автомобили
    context.read<CarBloc>().add(LoadCars());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car,
                        color: theme.colorScheme.onSurface,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Автомобили',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CarSearchBar(
                    onSearch: (query) {
                      context.read<CarBloc>().add(
                        SearchCarsEvent(query: query),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<CarBloc, CarState>(
                listener: (context, state) {
                  if (state is CarError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  if (state is CarOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CarLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is CarLoaded) {
                    if (state.cars.isEmpty) {
                      return Center(
                        child: Text(
                          'Нажмите "+" для добавления автомобиля',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: state.cars.length,
                      itemBuilder: (context, index) {
                        final car = state.cars[index];
                        return CarCard(
                          car: car,
                          onTap: () {
                            context
                                .read<RepairBloc>()
                                .add(LoadRepairs(carIdFilter: car.id));
                            context.go('/repairs');
                          },
                          onEdit: () => _showCarModal(context, car),
                          onDelete: () => _confirmDelete(context, car),
                        );
                      },
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

  void _showCarModal(BuildContext context, [Car? car]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CarFormModal(car: car),
    );
  }

  void _confirmDelete(BuildContext context, Car car) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить автомобиль?'),
        content: Text(
          'Это также удалит ВСЕ его ремонты!',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<CarBloc>().add(DeleteCarEvent(carId: car.id));
              Navigator.pop(context);
            },
            child: Text('Удалить',
                style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
