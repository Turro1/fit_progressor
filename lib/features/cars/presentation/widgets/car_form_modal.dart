import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_event.dart';
import '../../../clients/presentation/bloc/client_state.dart';
import '../../domain/entities/car.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import 'package:fit_progressor/shared/widgets/base_form_modal.dart'; // Import BaseFormModal
import 'car_dropdown_field.dart';

class CarFormModal extends StatefulWidget {
  final Car? car;
  final Client? client;

  const CarFormModal({Key? key, this.car, this.client}) : super(key: key);

  @override
  State<CarFormModal> createState() => _CarFormModalState();
}

class _CarFormModalState extends State<CarFormModal> {
  late TextEditingController _plateController;
  final _formKey = GlobalKey<FormState>();

  String _selectedClientId = '';
  String _selectedClientName = '';
  String _selectedMake = '';
  String _selectedModel = '';

  List<Client> _availableClients = [];
  List<String> _availableMakes = [];
  List<String> _availableModels = [];

  @override
  void initState() {
    super.initState();

    _plateController = TextEditingController(text: widget.car?.plate ?? '');

    if (widget.car != null) {
      _selectedClientId = widget.car!.clientId;
      _selectedMake = widget.car!.make;
      _selectedModel = widget.car!.model;
      context.read<CarBloc>().add(LoadCarModels(make: _selectedMake));
    }

    if (widget.client != null) {
      _selectedClientId = widget.client!.id;
      _selectedClientName = widget.client!.name;
    }

    context.read<ClientBloc>().add(LoadClients());
    context.read<CarBloc>().add(LoadCarMakes());
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnerPrefilled = widget.client != null;

    return BlocConsumer<CarBloc, CarState>(
      listener: (context, state) {
        if (state is CarOperationSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, carState) {
        final isLoading = carState is CarLoading;

        return BaseFormModal(
          titleIcon: Icon(
            widget.car == null ? Icons.directions_car : Icons.edit,
          ),
          titleText: widget.car == null
              ? 'Новый автомобиль'
              : 'Редактировать авто',
          showDragHandle: true,
          centeredTitle: true,
          isLoading: isLoading,
          formKey: _formKey,
          formFields: [
            BlocBuilder<ClientBloc, ClientState>(
              builder: (context, state) {
                if (state is ClientLoaded) {
                  _availableClients = state.clients;
                  if (widget.car != null && _selectedClientName.isEmpty) {
                    final owner = _availableClients.firstWhere(
                      (c) => c.id == widget.car!.clientId,
                      orElse: () => Client(
                        id: '',
                        name: 'Клиент не найден',
                        phone: '',
                        createdAt: DateTime.now(),
                      ),
                    );
                    if (owner.id.isNotEmpty) {
                      _selectedClientName = owner.name;
                    }
                  }
                }
                return CarDropdownField(
                  label: 'Владелец',
                  hint: 'Начните вводить имя владельца...',
                  items: _availableClients.map((c) => c.name).toList(),
                  value: _selectedClientName.isEmpty
                      ? null
                      : _selectedClientName,
                  onChanged: (value) {
                    setState(() {
                      _selectedClientName = value;
                      var client = _availableClients.firstWhere(
                        (c) => c.name == value,
                      );
                      _selectedClientId = client.id;
                    });
                  },
                  enabled: !isOwnerPrefilled,
                );
              },
            ),
            const SizedBox(height: 16),
            BlocListener<CarBloc, CarState>(
              listener: (context, state) {
                if (state is CarMakesLoaded) {
                  setState(() {
                    _availableMakes = state.makes;
                  });
                }
                if (state is CarModelsLoaded) {
                  setState(() {
                    _availableModels = state.models;
                  });
                }
              },
              child: CarDropdownField(
                label: 'Марка',
                hint: 'Начните вводить марку...',
                items: _availableMakes,
                value: _selectedMake.isEmpty ? null : _selectedMake,
                onChanged: (value) {
                  setState(() {
                    _selectedMake = value.toUpperCase();
                    _selectedModel = '';
                    _availableModels = [];
                  });
                  if (value.isNotEmpty) {
                    context.read<CarBloc>().add(
                      LoadCarModels(make: value.toUpperCase()),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            CarDropdownField(
              label: 'Модель',
              hint: 'Начните вводить модель...',
              items: _availableModels,
              value: _selectedModel.isEmpty ? null : _selectedModel,
              onChanged: (value) {
                setState(() {
                  _selectedModel = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: 'Гос. номер',
                hintText: 'А123ВВ 777',
                helperText: 'Введите регистрационный номер автомобиля',
                prefixIcon: const Icon(Icons.badge),
                counterText: '${_plateController.text.length}/15',
              ),
              maxLength: 15,
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                setState(() {}); // Update counter
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Пожалуйста, введите номер';
                }
                if (value.trim().length < 3) {
                  return 'Номер должен содержать минимум 3 символа';
                }
                return null;
              },
            ),
          ],
          onSubmit: _submitForm,
          submitButtonText: widget.car == null ? 'Добавить' : 'Сохранить',
        );
      },
    );
  }

  void _submitForm() {
    final theme = Theme.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Пожалуйста, выберите владельца из списка'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedMake.isEmpty || _selectedModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Пожалуйста, введите марку и модель'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    if (widget.car == null) {
      context.read<CarBloc>().add(
        AddCarEvent(
          clientId: _selectedClientId,
          make: _selectedMake,
          model: _selectedModel,
          plate: _plateController.text,
        ),
      );
    } else {
      context.read<CarBloc>().add(
        UpdateCarEvent(
          car: Car(
            id: widget.car!.id,
            clientId: _selectedClientId,
            make: _selectedMake,
            model: _selectedModel,
            plate: _plateController.text,
            createdAt: widget.car!.createdAt,
          ),
        ),
      );
    }
    Navigator.pop(context);
  }
}
