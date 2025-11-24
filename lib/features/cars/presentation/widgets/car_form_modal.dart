import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../clients/presentation/bloc/client_bloc.dart';
import '../../../clients/presentation/bloc/client_event.dart';
import '../../../clients/presentation/bloc/client_state.dart';
import '../../domain/entities/car.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import 'car_dropdown_field.dart';

class CarFormModal extends StatefulWidget {
  final Car? car;

  const CarFormModal({Key? key, this.car}) : super(key: key);

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
      
      // Загружаем модели для выбранной марки
      context.read<CarBloc>().add(LoadCarModels(make: _selectedMake));
    }
    
    // Загружаем клиентов если их нет
    context.read<ClientBloc>().add(LoadClients());
    
    // Загружаем доступные марки
    context.read<CarBloc>().add(LoadCarMakes());
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.car == null ? Icons.directions_car : Icons.edit,
                      color: AppColors.accentPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.car == null ? 'Новый автомобиль' : 'Редактировать авто',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Выбор владельца через CarDropdownField
                BlocBuilder<ClientBloc, ClientState>(
                  builder: (context, state) {
                    if (state is ClientLoaded) {
                      _availableClients = state.clients;
                      
                      // Если редактируем и еще не установили имя владельца
                      if (widget.car != null && _selectedClientName.isEmpty) {
                        final owner = _availableClients.firstWhere(
                          (c) => c.id == widget.car!.clientId,
                        );
                        if (owner.id.isNotEmpty) {
                          _selectedClientName = owner.name;
                        }
                      }
                    }
                    
                    return CarDropdownField(
                      label: 'Владелец (поиск)',
                      hint: 'Начните вводить имя владельца...',
                      items: _availableClients.map((c) => c.name).toList(),
                      value: _selectedClientName.isEmpty ? null : _selectedClientName,
                      onChanged: (value) {
                        setState(() {
                          _selectedClientName = value;
                          // Находим ID клиента по имени
                          var  client = _availableClients.where(
                            (c) => c.name == value).first;
                           _selectedClientId = client.id;
                        });
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Выбор марки
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
                        _selectedModel = ''; // Сбрасываем модель
                        _availableModels = []; // Очищаем список моделей
                      });
                      
                      // Загружаем модели для выбранной марки
                      if (value.isNotEmpty) {
                        context.read<CarBloc>().add(
                          LoadCarModels(make: value.toUpperCase()),
                        );
                      }
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Выбор модели
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
                
                // Гос. номер
                TextFormField(
                  controller: _plateController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Гос. номер',
                    hintText: 'А123ВВ 777',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.bgMain,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.accentPrimary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.badge,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Кнопки
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.car == null ? 'Добавить' : 'Сохранить',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Валидация владельца
      if (_selectedClientId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Пожалуйста, выберите владельца из списка'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      // Валидация марки и модели
      if (_selectedMake.isEmpty || _selectedModel.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Пожалуйста, введите марку и модель'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      // Валидация марки и модели
      if (_plateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Пожалуйста, введите номер автомобиля'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      if (widget.car == null) {
        // Добавление нового автомобиля
        context.read<CarBloc>().add(
          AddCarEvent(
            clientId: _selectedClientId,
            make: _selectedMake,
            model: _selectedModel,
            plate: _plateController.text,
          ),
        );
      } else {
        // Обновление существующего
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
}