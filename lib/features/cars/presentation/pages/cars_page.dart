import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_event.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
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
                      Icon(Icons.directions_car, color: AppColors.textPrimary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Автомобили',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                  if (state is CarOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.accentSecondary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CarLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPrimary,
                      ),
                    );
                  }

                  if (state is CarLoaded) {
                    if (state.cars.isEmpty) {
                      return Center(
                        child: Text(
                          'Нажмите "+" для добавления автомобиля',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text(
          'Удалить автомобиль?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Это также удалит ВСЕ его ремонты!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<CarBloc>().add(DeleteCarEvent(carId: car.id));
              Navigator.pop(context);
            },
            child: Text('Удалить', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}