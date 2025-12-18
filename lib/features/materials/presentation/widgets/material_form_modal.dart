import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/material.dart' as material_entity;
import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';

class MaterialFormModal extends StatefulWidget {
  final material_entity.Material? material;

  const MaterialFormModal({Key? key, this.material}) : super(key: key);

  @override
  State<MaterialFormModal> createState() => _MaterialFormModalState();
}

class _MaterialFormModalState extends State<MaterialFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _minQuantityController;
  late TextEditingController _costController;
  late material_entity.MaterialUnit _selectedUnit;
  final _formKey = GlobalKey<FormState>();

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
    _selectedUnit = widget.material?.unit ?? material_entity.MaterialUnit.pcs;
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
    final theme = Theme.of(context);
    final borderRadius = theme.cardTheme.shape is RoundedRectangleBorder
        ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
        : BorderRadius.circular(12);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            borderRadius.resolve(Directionality.of(context)).topLeft.x,
          ),
        ),
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
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildTextField(
                  _nameController,
                  'Название',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Введите название';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        _quantityController,
                        'Количество',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(flex: 1, child: _buildUnitDropdown(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _minQuantityController,
                  'Минимальный остаток',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _costController,
                  'Закупочная цена (₽)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          widget.material == null ? Icons.add_shopping_cart : Icons.edit,
          color: theme.colorScheme.secondary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.material == null
                ? 'Новый материал'
                : 'Редактировать материал',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  Widget _buildUnitDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<material_entity.MaterialUnit>(
      initialValue: _selectedUnit,
      decoration: const InputDecoration(labelText: 'Ед. изм.'),
      dropdownColor: theme.colorScheme.surface,
      items: material_entity.MaterialUnit.values.map((unit) {
        return DropdownMenuItem(value: unit, child: Text(unit.displayName));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedUnit = value);
        }
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Отмена',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _submitForm,
          style: theme.elevatedButtonTheme.style,
          child: Text(widget.material == null ? 'Добавить' : 'Сохранить'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final quantity = double.tryParse(_quantityController.text) ?? 0;
      final minQuantity = double.tryParse(_minQuantityController.text) ?? 0;
      final cost = double.tryParse(_costController.text) ?? 0;

      if (widget.material == null) {
        context.read<MaterialBloc>().add(
          AddMaterialEvent(
            name: name,
            quantity: quantity,
            unit: _selectedUnit,
            minQuantity: minQuantity,
            cost: cost,
          ),
        );
      } else {
        final updatedMaterial = widget.material!.copyWith(
          name: name,
          quantity: quantity,
          unit: _selectedUnit,
          minQuantity: minQuantity,
          cost: cost,
        );
        context.read<MaterialBloc>().add(
          UpdateMaterialEvent(material: updatedMaterial),
        );
      }
      Navigator.pop(context);
    }
  }
}
