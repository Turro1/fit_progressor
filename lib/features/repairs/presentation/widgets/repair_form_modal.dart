import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_event.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_state.dart';
import 'package:fit_progressor/features/cars/presentation/widgets/car_dropdown_field.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_event.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_state.dart';
import 'package:fit_progressor/features/repairs/domain/entities/part_types.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/material_selector.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/photo_gallery_field.dart';
import 'package:fit_progressor/shared/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RepairFormModal extends StatefulWidget {
  final Repair? repair;
  final String? preselectedClientId;
  final String? preselectedCarId;

  const RepairFormModal({
    Key? key,
    this.repair,
    this.preselectedClientId,
    this.preselectedCarId,
  }) : super(key: key);

  @override
  State<RepairFormModal> createState() => _RepairFormModalState();
}

class _RepairFormModalState extends State<RepairFormModal> {
  int _currentStep = 0;

  // Пропускаем шаг выбора клиента/авто если:
  // 1. Редактируем существующий ремонт
  // 2. Или есть предварительно выбранные клиент и авто
  bool get _shouldSkipClientCarStep =>
      widget.repair != null ||
      (widget.preselectedClientId != null && widget.preselectedCarId != null);

  int get _totalSteps => _shouldSkipClientCarStep ? 2 : 3;

  // Form keys for each step
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _costController;
  late TextEditingController _descriptionController;

  // Step 1: Client & Car
  String _selectedClientId = '';
  String _selectedClientName = '';
  String _selectedCarId = '';
  String _selectedCarName = '';
  List<Client> _availableClients = [];
  List<Car> _availableCars = [];

  // Step 2: Repair Details
  String _selectedPartType = PartTypes.shock;
  String _selectedPartPosition = PartPositions.frontLeft;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  // Step 3: Photos
  List<String> _selectedPhotoPaths = [];

  // Materials
  List<RepairMaterial> _selectedMaterials = [];

  @override
  void initState() {
    super.initState();
    _costController = TextEditingController(
      text: widget.repair?.cost.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.repair?.description ?? '',
    );

    if (widget.repair != null) {
      _selectedClientId = widget.repair!.clientId;
      _selectedCarId = widget.repair!.carId;
      _selectedPartType = widget.repair!.partType;
      _selectedPartPosition = widget.repair!.partPosition;
      _selectedDate = widget.repair!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.repair!.date);
      _selectedPhotoPaths = List.from(widget.repair!.photoPaths);
      _selectedMaterials = List.from(widget.repair!.materials);
    } else {
      // Set preselected values if provided
      if (widget.preselectedClientId != null) {
        _selectedClientId = widget.preselectedClientId!;
      }
      if (widget.preselectedCarId != null) {
        _selectedCarId = widget.preselectedCarId!;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ClientBloc>().add(LoadClients());
        context.read<CarBloc>().add(LoadCars());
      }
    });
  }

  @override
  void dispose() {
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    // Если пропускаем шаг выбора клиента/авто
    if (_shouldSkipClientCarStep) {
      switch (_currentStep) {
        case 0: // Детали ремонта
          return _step2FormKey.currentState!.validate();
        case 1: // Фото
          return true; // Photos are optional
        default:
          return false;
      }
    }

    // Если показываем все 3 шага
    switch (_currentStep) {
      case 0: // Step 1: Client & Car
        if (!_step1FormKey.currentState!.validate()) {
          return false;
        }
        if (_selectedClientId.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Выберите клиента')));
          return false;
        }
        if (_selectedCarId.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Выберите автомобиль')));
          return false;
        }
        return true;
      case 1: // Step 2: Repair Details
        return _step2FormKey.currentState!.validate();
      case 2: // Step 3: Photos
        return true; // Photos are optional
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitForm() {
    if (_validateCurrentStep()) {
      // Получить информацию об автомобиле
      final carState = context.read<CarBloc>().state;
      String carMake = '';
      String carModel = '';

      if (carState is CarLoaded) {
        final car = carState.cars.firstWhere(
          (c) => c.id == _selectedCarId,
          orElse: () => carState.cars.first,
        );
        carMake = car.make;
        carModel = car.model;
      }

      // Объединить дату и время
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (widget.repair != null) {
        // Редактирование существующего ремонта
        context.read<RepairsBloc>().add(
          UpdateRepairEvent(
            repair: widget.repair!.copyWith(
              partType: _selectedPartType,
              partPosition: _selectedPartPosition,
              photoPaths: _selectedPhotoPaths,
              description: _descriptionController.text,
              date: combinedDateTime,
              cost: double.parse(_costController.text),
              clientId: _selectedClientId,
              carId: _selectedCarId,
              carMake: carMake,
              carModel: carModel,
              materials: _selectedMaterials,
            ),
          ),
        );
      } else {
        // Добавление нового ремонта
        context.read<RepairsBloc>().add(
          AddRepairEvent(
            partType: _selectedPartType,
            partPosition: _selectedPartPosition,
            photoPaths: _selectedPhotoPaths,
            description: _descriptionController.text,
            date: combinedDateTime,
            cost: double.parse(_costController.text),
            clientId: _selectedClientId,
            carId: _selectedCarId,
            carMake: carMake,
            carModel: carModel,
            materials: _selectedMaterials,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Widget _buildStepContent() {
    // Если пропускаем шаг выбора клиента/авто
    if (_shouldSkipClientCarStep) {
      switch (_currentStep) {
        case 0:
          return _buildStep2RepairDetails();
        case 1:
          return _buildStep3Photos();
        default:
          return const SizedBox();
      }
    }

    // Если показываем все 3 шага
    switch (_currentStep) {
      case 0:
        return _buildStep1ClientAndCar();
      case 1:
        return _buildStep2RepairDetails();
      case 2:
        return _buildStep3Photos();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1ClientAndCar() {
    return Form(
      key: _step1FormKey,
      child: Column(
        children: [
          BlocBuilder<ClientBloc, ClientState>(
            builder: (context, state) {
              if (state is ClientLoaded) {
                _availableClients = state.clients;

                // При редактировании: установить имя клиента по ID
                if (widget.repair != null &&
                    _selectedClientName.isEmpty &&
                    _selectedClientId.isNotEmpty) {
                  final client = _availableClients.firstWhere(
                    (c) => c.id == _selectedClientId,
                    orElse: () => _availableClients.first,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedClientName = client.name;
                      });
                    }
                  });
                }
              }
              return CarDropdownField(
                label: 'Клиент',
                hint: 'Выберите клиента...',
                items: _availableClients.map((c) => c.name).toList(),
                value: _selectedClientName.isEmpty ? null : _selectedClientName,
                onChanged: (value) {
                  setState(() {
                    _selectedClientName = value;
                    final client = _availableClients.firstWhere(
                      (c) => c.name == value,
                    );
                    _selectedClientId = client.id;
                    _selectedCarId = '';
                    _selectedCarName = '';
                  });
                },
                enabled:
                    widget.repair == null, // Заблокировано при редактировании
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<CarBloc, CarState>(
            builder: (context, state) {
              if (state is CarLoaded) {
                _availableCars = state.cars;

                // При редактировании: установить имя авто по ID
                if (widget.repair != null &&
                    _selectedCarName.isEmpty &&
                    _selectedCarId.isNotEmpty) {
                  final car = _availableCars.firstWhere(
                    (c) => c.id == _selectedCarId,
                    orElse: () => _availableCars.first,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedCarName = car.fullName;
                      });
                    }
                  });
                }
              }
              final filteredCars = _selectedClientId.isNotEmpty
                  ? _availableCars
                        .where((car) => car.clientId == _selectedClientId)
                        .toList()
                  : _availableCars;
              return CarDropdownField(
                label: 'Автомобиль',
                hint: 'Выберите автомобиль...',
                items: filteredCars.map((c) => c.fullName).toList(),
                value: _selectedCarName.isEmpty ? null : _selectedCarName,
                onChanged: (value) {
                  setState(() {
                    _selectedCarName = value;
                    final car = filteredCars.firstWhere(
                      (c) => c.fullName == value,
                    );
                    _selectedCarId = car.id;
                  });
                },
                enabled:
                    widget.repair == null &&
                    _selectedClientId
                        .isNotEmpty, // Заблокировано при редактировании
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2RepairDetails() {
    return Form(
      key: _step2FormKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('partType_$_selectedPartType'),
            initialValue: _selectedPartType,
            decoration: const InputDecoration(
              labelText: 'Тип детали',
              border: OutlineInputBorder(),
            ),
            items: PartTypes.all.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPartType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey('partPosition_$_selectedPartPosition'),
            initialValue: _selectedPartPosition,
            decoration: const InputDecoration(
              labelText: 'Позиция',
              border: OutlineInputBorder(),
            ),
            items: PartPositions.all.map((position) {
              return DropdownMenuItem(value: position, child: Text(position));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPartPosition = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Дата ремонта',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Время',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(_selectedTime.format(context)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _costController,
            decoration: const InputDecoration(
              labelText: 'Стоимость',
              border: OutlineInputBorder(),
              suffixText: '₽',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите стоимость';
              }
              final cost = double.tryParse(value);
              if (cost == null || cost <= 0) {
                return 'Введите корректную стоимость';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Описание (необязательно)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          MaterialSelector(
            initialMaterials: _selectedMaterials,
            onMaterialsChanged: (materials) {
              setState(() {
                _selectedMaterials = materials;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Photos() {
    return PhotoGalleryField(
      initialPhotoPaths: _selectedPhotoPaths,
      onPhotosChanged: (paths) {
        setState(() {
          _selectedPhotoPaths = paths;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<RepairsBloc, RepairsState>(
      listener: (context, state) {
        if (state is RepairsOperationSuccess && mounted) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is RepairsLoading;

        return Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.9,
          ),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.repair == null ? Icons.build_circle : Icons.edit,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.repair == null ? 'Новый ремонт' : 'Редактировать',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Step Indicator
              StepIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                stepLabels: _shouldSkipClientCarStep
                    ? const ['Детали', 'Фото']
                    : const ['Клиент/Авто', 'Детали', 'Фото'],
              ),

              // Step Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 24),
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: 24),

              // Navigation Buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _previousStep,
                        child: const Text('Назад'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isLoading
                          ? null
                          : (_currentStep < _totalSteps - 1
                                ? _nextStep
                                : _submitForm),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _currentStep < _totalSteps - 1
                                  ? 'Далее'
                                  : (widget.repair == null
                                        ? 'Добавить'
                                        : 'Сохранить'),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
