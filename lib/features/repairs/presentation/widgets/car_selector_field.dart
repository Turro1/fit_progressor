import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_event.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_state.dart';

class CarSelectorField extends StatefulWidget {
  final String clientId;
  final String? initialCarId;
  final Function(Car?) onCarSelected;

  const CarSelectorField({
    Key? key,
    required this.clientId,
    this.initialCarId,
    required this.onCarSelected,
  }) : super(key: key);

  @override
  State<CarSelectorField> createState() => _CarSelectorFieldState();
}

class _CarSelectorFieldState extends State<CarSelectorField> {
  Car? _selectedCar;

  @override
  void initState() {
    super.initState();
    // Load cars if not already loaded
    final carBloc = context.read<CarBloc>();
    if (carBloc.state is! CarLoaded) {
      carBloc.add(LoadCars());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CarBloc, CarState>(
      builder: (context, state) {
        List<Car> allCars = [];
        List<Car> clientCars = [];

        if (state is CarLoaded) {
          allCars = state.cars;
          // Filter cars by client
          clientCars = allCars
              .where((car) => car.clientId == widget.clientId)
              .toList();

          // Set initial car if provided
          if (widget.initialCarId != null && _selectedCar == null) {
            _selectedCar = clientCars
                .where((c) => c.id == widget.initialCarId)
                .firstOrNull;
          }
        }

        if (clientCars.isEmpty) {
          return TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Автомобиль',
              helperText: 'У клиента нет автомобилей',
              prefixIcon: const Icon(Icons.directions_car),
              fillColor: theme.disabledColor.withValues(alpha: 0.1),
            ),
          );
        }

        return DropdownButtonFormField<Car>(
          initialValue: _selectedCar,
          decoration: const InputDecoration(
            labelText: 'Автомобиль',
            helperText: 'Выберите автомобиль',
            prefixIcon: Icon(Icons.directions_car),
          ),
          items: clientCars.map((car) {
            return DropdownMenuItem<Car>(
              value: car,
              child: Text('${car.make} ${car.model} (${car.plate})'),
            );
          }).toList(),
          onChanged: (car) {
            setState(() {
              _selectedCar = car;
            });
            widget.onCarSelected(car);
          },
          validator: (value) {
            if (value == null) {
              return 'Выберите автомобиль';
            }
            return null;
          },
        );
      },
    );
  }
}
