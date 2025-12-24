import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/material.dart' as entity;
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as material_state;
import 'package:fit_progressor/shared/widgets/base_form_modal.dart';

class MaterialFormModal extends StatefulWidget {
  final entity.Material? material;

  const MaterialFormModal({Key? key, this.material}) : super(key: key);

  @override
  State<MaterialFormModal> createState() => _MaterialFormModalState();
}

class _MaterialFormModalState extends State<MaterialFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _minQuantityController;
  late TextEditingController _costController;

  final _formKey = GlobalKey<FormState>();
  entity.MaterialUnit _selectedUnit = entity.MaterialUnit.pcs;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.material?.quantity.toString() ?? '0',
    );
    _minQuantityController = TextEditingController(
      text: widget.material?.minQuantity.toString() ?? '0',
    );
    _costController = TextEditingController(
      text: widget.material?.cost.toString() ?? '0',
    );

    if (widget.material != null) {
      _selectedUnit = widget.material!.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaterialBloc, material_state.MaterialState>(
      listener: (context, state) {
        if (state is material_state.MaterialOperationSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is material_state.MaterialLoading;

        return BaseFormModal(
          titleIcon: Icon(
            widget.material == null ? Icons.inventory_2 : Icons.edit,
          ),
          titleText: widget.material == null
              ? 'Новый материал'
              : 'Редактировать материал',
          showDragHandle: true,
          centeredTitle: true,
          isLoading: isLoading,
          formKey: _formKey,
          formFields: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название',
                hintText: 'Масло моторное 5W-40',
                helperText: 'Введите название материала',
                prefixIcon: const Icon(Icons.label),
                counterText: '${_nameController.text.length}/100',
              ),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                setState(() {}); // Update counter
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Пожалуйста, введите название';
                }
                if (value.trim().length < 2) {
                  return 'Название должно содержать минимум 2 символа';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Количество',
                      hintText: '10',
                      helperText: 'Текущее количество',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите количество';
                      }
                      final quantity = double.tryParse(value);
                      if (quantity == null || quantity < 0) {
                        return 'Некорректное значение';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<entity.MaterialUnit>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Ед. изм.',
                      helperText: ' ',
                    ),
                    items: entity.MaterialUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minQuantityController,
              decoration: const InputDecoration(
                labelText: 'Минимальное количество',
                hintText: '5',
                helperText: 'Уровень для предупреждения о низком запасе',
                prefixIcon: Icon(Icons.low_priority),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите минимальное количество';
                }
                final minQuantity = double.tryParse(value);
                if (minQuantity == null || minQuantity < 0) {
                  return 'Некорректное значение';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Стоимость за единицу',
                hintText: '500.00',
                helperText: 'Цена за одну единицу измерения',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: '₽',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите стоимость';
                }
                final cost = double.tryParse(value);
                if (cost == null || cost < 0) {
                  return 'Некорректное значение';
                }
                return null;
              },
            ),
          ],
          onSubmit: _submitForm,
          submitButtonText: widget.material == null ? 'Добавить' : 'Сохранить',
        );
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final minQuantity = double.parse(_minQuantityController.text);
    final cost = double.parse(_costController.text);

    if (widget.material == null) {
      context.read<MaterialBloc>().add(
        AddMaterialEvent(
          name: _nameController.text.trim(),
          quantity: quantity,
          unit: _selectedUnit,
          minQuantity: minQuantity,
          cost: cost,
        ),
      );
    } else {
      context.read<MaterialBloc>().add(
        UpdateMaterialEvent(
          material: entity.Material(
            id: widget.material!.id,
            name: _nameController.text.trim(),
            quantity: quantity,
            unit: _selectedUnit,
            minQuantity: minQuantity,
            cost: cost,
            createdAt: widget.material!.createdAt,
          ),
        ),
      );
    }
  }
}
