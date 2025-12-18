import 'package:fit_progressor/shared/widgets/app_search_bar.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/car.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import '../widgets/car_card.dart';
import '../widgets/car_form_modal.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({Key? key}) : super(key: key);

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  @override
  void initState() {
    super.initState();
    // Load cars on init
    context.read<CarBloc>().add(LoadCars());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCarModal(context),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with icon and title
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    color: theme.colorScheme.onSurface,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text('Автомобили', style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: AppSearchBar(
                hintText: 'Поиск по марке, модели или номеру...',
                onSearch: (query) {
                  context.read<CarBloc>().add(SearchCarsEvent(query: query));
                },
              ),
            ),
            const SizedBox(height: 15),
            // Content
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CarLoaded) {
                    if (state.cars.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<CarBloc>().add(LoadCars());
                        },
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: EmptyState(
                                icon: Icons.directions_car_outlined,
                                title: 'Нет автомобилей',
                                message:
                                    'Добавьте первый автомобиль, нажав кнопку "Добавить"',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<CarBloc>().add(LoadCars());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: state.cars.length,
                        itemBuilder: (context, index) {
                          final car = state.cars[index];
                          return CarCard(
                            car: car,

                            onEdit: () => _showCarModal(context, car),
                            onDelete: () => _confirmDelete(context, car),
                          );
                        },
                      ),
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
            child: Text(
              'Удалить',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
