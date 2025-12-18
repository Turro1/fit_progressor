import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/repairs_bloc.dart';
import '../bloc/repairs_event.dart';
import '../bloc/repairs_state.dart';
import 'package:fit_progressor/shared/widgets/base_form_modal.dart';
import 'package:fit_progressor/core/theme/app_spacing.dart';
import 'client_selector_field.dart';
import 'car_selector_field.dart';

class RepairFormModal extends StatefulWidget {
  final Repair? repair;

  const RepairFormModal({Key? key, this.repair}) : super(key: key);

  @override
  State<RepairFormModal> createState() => _RepairFormModalState();
}

class _RepairFormModalState extends State<RepairFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;
  late TextEditingController _dateController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Client? _selectedClient;
  Car? _selectedCar;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.repair?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.repair?.description ?? '',
    );
    _costController = TextEditingController(
      text: widget.repair?.cost.toString() ?? '',
    );
    _selectedDate = widget.repair?.date ?? DateTime.now();
    _dateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(_selectedDate),
    );

    // Слушаем изменения для обновления character counter
    _nameController.addListener(() {
      setState(() {});
    });
    _descriptionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RepairsBloc, RepairsState>(
      listener: (context, state) {
        if (state is RepairsOperationSuccess) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        } else if (state is RepairsError) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: BaseFormModal(
        titleIcon: Icon(widget.repair == null ? Icons.add_circle : Icons.edit),
        titleText: widget.repair == null
            ? 'Новый ремонт'
            : 'Редактировать ремонт',
        formKey: _formKey,
        showDragHandle: true,
        centeredTitle: true,
        isLoading: _isLoading,
        formFields: [
          // Name field
          TextFormField(
            controller: _nameController,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: 'Название ремонта',
              helperText: 'Например: Замена масла, Ремонт двигателя',
              prefixIcon: const Icon(Icons.build),
              counterText: '${_nameController.text.length}/100',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Введите название';
              }
              if (value.trim().length < 3) {
                return 'Название должно содержать минимум 3 символа';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.lg),
          // Description field
          TextFormField(
            controller: _descriptionController,
            maxLength: 500,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Описание (необязательно)',
              helperText: 'Детали ремонта',
              prefixIcon: const Icon(Icons.description),
              counterText: '${_descriptionController.text.length}/500',
              alignLabelWithHint: true,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // Date field
          TextFormField(
            controller: _dateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Дата ремонта',
              prefixIcon: Icon(Icons.calendar_today),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                  _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Выберите дату';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.lg),
          // Cost field
          TextFormField(
            controller: _costController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              labelText: 'Стоимость',
              helperText: 'Введите стоимость в рублях',
              prefixIcon: Icon(Icons.attach_money),
              suffixText: '₽',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите стоимость';
              }
              final cost = double.tryParse(value);
              if (cost == null || cost < 0) {
                return 'Введите корректную стоимость';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.lg),
          // Client selector
          ClientSelectorField(
            initialClientId: widget.repair?.clientId,
            onClientSelected: (client) {
              setState(() {
                _selectedClient = client;
                _selectedCar = null; // Reset car when client changes
              });
            },
          ),
          if (_selectedClient != null) ...[
            SizedBox(height: AppSpacing.lg),
            // Car selector (only shown when client is selected)
            CarSelectorField(
              clientId: _selectedClient!.id,
              initialCarId: widget.repair?.carId,
              onCarSelected: (car) {
                setState(() {
                  _selectedCar = car;
                });
              },
            ),
          ],
        ],
        onSubmit: _submitForm,
        submitButtonText: widget.repair == null ? 'Добавить' : 'Сохранить',
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Additional validation for client and car
      if (_selectedClient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выберите клиента'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedCar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выберите автомобиль'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final cost = double.parse(_costController.text);

      if (widget.repair == null) {
        context.read<RepairsBloc>().add(
          AddRepairEvent(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            date: _selectedDate,
            cost: cost,
            clientId: _selectedClient!.id,
            carId: _selectedCar!.id,
          ),
        );
      } else {
        context.read<RepairsBloc>().add(
          UpdateRepairEvent(
            repair: Repair(
              id: widget.repair!.id,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              date: _selectedDate,
              cost: cost,
              clientId: _selectedClient!.id,
              carId: _selectedCar!.id,
              createdAt: widget.repair!.createdAt,
            ),
          ),
        );
      }
    }
  }
}
