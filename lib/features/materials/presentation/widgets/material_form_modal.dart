import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/material.dart' as entity;
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as material_state;

class MaterialFormModal extends StatefulWidget {
  final entity.Material? material;

  const MaterialFormModal({Key? key, this.material}) : super(key: key);

  @override
  State<MaterialFormModal> createState() => _MaterialFormModalState();
}

class _MaterialFormModalState extends State<MaterialFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _costController;

  final _formKey = GlobalKey<FormState>();
  entity.MaterialUnit _selectedUnit = entity.MaterialUnit.pcs;
  double _quantity = 0;
  double _minQuantity = 0;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _costController = TextEditingController(
      text: widget.material?.cost.toString() ?? '',
    );

    if (widget.material != null) {
      _selectedUnit = widget.material!.unit;
      _quantity = widget.material!.quantity;
      _minQuantity = widget.material!.minQuantity;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity += _getStep();
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity >= _getStep()) {
        _quantity -= _getStep();
      } else {
        _quantity = 0;
      }
    });
  }

  void _incrementMinQuantity() {
    setState(() {
      _minQuantity += _getStep();
    });
  }

  void _decrementMinQuantity() {
    setState(() {
      if (_minQuantity >= _getStep()) {
        _minQuantity -= _getStep();
      } else {
        _minQuantity = 0;
      }
    });
  }

  double _getStep() {
    // Для жидкостей (л) и килограммов - шаг 0.5, для остальных - 1
    switch (_selectedUnit) {
      case entity.MaterialUnit.l:
      case entity.MaterialUnit.kg:
        return 0.5;
      default:
        return 1.0;
    }
  }

  String _formatQuantity(double value) {
    if (value == value.truncate()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.material != null;

    return BlocConsumer<MaterialBloc, material_state.MaterialState>(
      listener: (context, state) {
        if (state is material_state.MaterialOperationSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is material_state.MaterialLoading;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          isEditing ? Icons.edit : Icons.inventory_2,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEditing ? 'Редактировать материал' : 'Новый материал',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Название
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        hintText: 'Масло моторное 5W-40',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      maxLength: 100,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите название';
                        }
                        if (value.trim().length < 2) {
                          return 'Минимум 2 символа';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Единица измерения - ChoiceChips
                    _buildSectionHeader(
                      context,
                      icon: Icons.straighten,
                      title: 'Единица измерения',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entity.MaterialUnit.values.map((unit) {
                        final isSelected = _selectedUnit == unit;
                        return ChoiceChip(
                          label: Text(unit.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedUnit = unit;
                              });
                            }
                          },
                          selectedColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Склад - карточка с количеством
                    _buildSectionHeader(
                      context,
                      icon: Icons.warehouse_outlined,
                      title: 'Склад',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Количество
                          Expanded(
                            child: _buildQuantityControl(
                              context,
                              label: 'Количество',
                              value: _quantity,
                              onIncrement: _incrementQuantity,
                              onDecrement: _decrementQuantity,
                              onChanged: (value) {
                                setState(() {
                                  _quantity = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 80,
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 16),
                          // Минимум
                          Expanded(
                            child: _buildQuantityControl(
                              context,
                              label: 'Минимум',
                              value: _minQuantity,
                              onIncrement: _incrementMinQuantity,
                              onDecrement: _decrementMinQuantity,
                              onChanged: (value) {
                                setState(() {
                                  _minQuantity = value;
                                });
                              },
                              isWarning: _quantity > 0 && _quantity < _minQuantity,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Индикатор запаса (если количество > 0)
                    if (_quantity > 0 || _minQuantity > 0) ...[
                      const SizedBox(height: 8),
                      _buildStockIndicator(context),
                    ],

                    const SizedBox(height: 24),

                    // Стоимость
                    _buildSectionHeader(
                      context,
                      icon: Icons.payments_outlined,
                      title: 'Стоимость',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: 'Цена за ${_selectedUnit.displayName}',
                        hintText: '500.00',
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: '₽',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

                    const SizedBox(height: 32),

                    // Кнопки действий
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading ? null : () => Navigator.pop(context),
                            child: const Text('Отмена'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submitForm,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(isEditing ? 'Сохранить' : 'Добавить'),
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
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControl(
    BuildContext context, {
    required String label,
    required double value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required ValueChanged<double> onChanged,
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isWarning
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              context,
              icon: Icons.remove,
              onPressed: value > 0 ? onDecrement : null,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showQuantityDialog(context, value, onChanged),
              child: Container(
                constraints: const BoxConstraints(minWidth: 50),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWarning
                      ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isWarning
                        ? theme.colorScheme.error
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _formatQuantity(value),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isWarning
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildCircleButton(
              context,
              icon: Icons.add,
              onPressed: onIncrement,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _selectedUnit.displayName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;

    return Material(
      color: isEnabled
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildStockIndicator(BuildContext context) {
    final theme = Theme.of(context);

    if (_minQuantity <= 0) {
      return const SizedBox.shrink();
    }

    final ratio = _quantity / _minQuantity;
    final percentage = (ratio * 100).clamp(0, 200);

    Color indicatorColor;
    String statusText;
    IconData statusIcon;

    if (ratio >= 1.5) {
      indicatorColor = Colors.green;
      statusText = 'Достаточный запас';
      statusIcon = Icons.check_circle_outline;
    } else if (ratio >= 1.0) {
      indicatorColor = Colors.orange;
      statusText = 'Запас в норме';
      statusIcon = Icons.info_outline;
    } else if (ratio > 0) {
      indicatorColor = theme.colorScheme.error;
      statusText = 'Низкий запас';
      statusIcon = Icons.warning_amber_outlined;
    } else {
      indicatorColor = theme.colorScheme.error;
      statusText = 'Нет в наличии';
      statusIcon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 16, color: indicatorColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: indicatorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (percentage / 150).clamp(0, 1),
                    backgroundColor: indicatorColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(indicatorColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showQuantityDialog(
    BuildContext context,
    double currentValue,
    ValueChanged<double> onChanged,
  ) async {
    final controller = TextEditingController(text: _formatQuantity(currentValue));

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Введите количество'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          autofocus: true,
          decoration: InputDecoration(
            suffixText: _selectedUnit.displayName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0;
              Navigator.pop(context, value);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cost = double.parse(_costController.text);

    if (widget.material == null) {
      context.read<MaterialBloc>().add(
        AddMaterialEvent(
          name: _nameController.text.trim(),
          quantity: _quantity,
          unit: _selectedUnit,
          minQuantity: _minQuantity,
          cost: cost,
        ),
      );
    } else {
      context.read<MaterialBloc>().add(
        UpdateMaterialEvent(
          material: entity.Material(
            id: widget.material!.id,
            name: _nameController.text.trim(),
            quantity: _quantity,
            unit: _selectedUnit,
            minQuantity: _minQuantity,
            cost: cost,
            createdAt: widget.material!.createdAt,
          ),
        ),
      );
    }
  }
}
