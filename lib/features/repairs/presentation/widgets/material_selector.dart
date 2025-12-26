import 'package:flutter/material.dart' hide MaterialState;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart'
    as mat;
import 'package:fit_progressor/features/materials/presentation/bloc/material_bloc.dart';
import 'package:fit_progressor/features/materials/presentation/bloc/material_event.dart';
import 'package:fit_progressor/features/materials/presentation/bloc/material_state.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';

class MaterialSelector extends StatefulWidget {
  final List<RepairMaterial> initialMaterials;
  final ValueChanged<List<RepairMaterial>> onMaterialsChanged;

  const MaterialSelector({
    super.key,
    this.initialMaterials = const [],
    required this.onMaterialsChanged,
  });

  @override
  State<MaterialSelector> createState() => _MaterialSelectorState();
}

class _MaterialSelectorState extends State<MaterialSelector> {
  late List<RepairMaterial> _selectedMaterials;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedMaterials = List.from(widget.initialMaterials);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MaterialBloc>().add(LoadMaterials());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addMaterial(mat.Material material) {
    _showQuantityDialog(
      material: material,
      onConfirm: (quantity) {
        final repairMaterial = RepairMaterial(
          materialId: material.id,
          materialName: material.name,
          quantity: quantity,
          unit: material.unit,
          unitCost: material.cost,
        );
        setState(() {
          _selectedMaterials.add(repairMaterial);
        });
        widget.onMaterialsChanged(_selectedMaterials);
        _searchController.clear();
      },
    );
  }

  void _editMaterial(int index) {
    final material = _selectedMaterials[index];
    _showQuantityDialog(
      materialName: material.materialName,
      initialQuantity: material.quantity,
      unit: material.unit,
      onConfirm: (quantity) {
        setState(() {
          _selectedMaterials[index] = material.copyWith(quantity: quantity);
        });
        widget.onMaterialsChanged(_selectedMaterials);
      },
    );
  }

  void _removeMaterial(int index) {
    setState(() {
      _selectedMaterials.removeAt(index);
    });
    widget.onMaterialsChanged(_selectedMaterials);
  }

  void _showQuantityDialog({
    mat.Material? material,
    String? materialName,
    double? initialQuantity,
    mat.MaterialUnit? unit,
    required ValueChanged<double> onConfirm,
  }) {
    final controller = TextEditingController(
      text: initialQuantity?.toString() ?? '',
    );
    final name = materialName ?? material?.name ?? '';
    final unitName = (unit ?? material?.unit)?.displayName ?? '';
    final maxQuantity = material?.quantity;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            initialQuantity != null ? 'Изменить количество' : 'Добавить материал'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            if (maxQuantity != null) ...[
              const SizedBox(height: 4),
              Text(
                'Доступно: ${maxQuantity.toStringAsFixed(2)} $unitName',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Количество ($unitName)',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final quantity = double.tryParse(controller.text);
              if (quantity != null && quantity > 0) {
                Navigator.pop(context);
                onConfirm(quantity);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  List<mat.Material> _filterMaterials(
      List<mat.Material> materials, String query) {
    final excludeIds = _selectedMaterials.map((m) => m.materialId).toSet();

    return materials
        .where((m) => !excludeIds.contains(m.id))
        .where((m) => m.quantity > 0)
        .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  double get _totalCost =>
      _selectedMaterials.fold(0.0, (sum, m) => sum + m.totalCost);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Материалы', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),

        // Autocomplete поле поиска
        BlocBuilder<MaterialBloc, MaterialState>(
          builder: (context, state) {
            final allMaterials =
                state is MaterialLoaded ? state.materials : <mat.Material>[];

            return Autocomplete<mat.Material>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.length < 2) {
                  return const Iterable<mat.Material>.empty();
                }
                return _filterMaterials(allMaterials, textEditingValue.text);
              },
              displayStringForOption: (mat.Material option) => option.name,
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController fieldController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Поиск материала...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: fieldController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              fieldController.clear();
                            },
                          )
                        : null,
                  ),
                );
              },
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<mat.Material> onSelected,
                Iterable<mat.Material> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 250,
                        maxWidth: MediaQuery.of(context).size.width - 72,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final material = options.elementAt(index);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              radius: 18,
                              child: Icon(
                                Icons.inventory_2,
                                size: 18,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              material.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${material.quantity.toStringAsFixed(1)} ${material.unit.displayName} • ${material.cost.toStringAsFixed(0)} ₽',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Icon(
                              Icons.add_circle_outline,
                              color: theme.colorScheme.primary,
                            ),
                            onTap: () => onSelected(material),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              onSelected: (mat.Material selection) {
                _addMaterial(selection);
              },
            );
          },
        ),

        const SizedBox(height: 8),
        Text(
          'Введите минимум 2 символа для поиска',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        // Список выбранных материалов
        if (_selectedMaterials.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  'Материалы не добавлены',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedMaterials.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final material = _selectedMaterials[index];
              return _MaterialListItem(
                material: material,
                onEdit: () => _editMaterial(index),
                onRemove: () => _removeMaterial(index),
              );
            },
          ),
        if (_selectedMaterials.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Итого материалов:',
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '${_totalCost.toStringAsFixed(2)} ₽',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MaterialListItem extends StatelessWidget {
  final RepairMaterial material;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _MaterialListItem({
    required this.material,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.materialName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${material.quantity} ${material.unit.displayName} × ${material.unitCost.toStringAsFixed(2)} ₽ = ${material.totalCost.toStringAsFixed(2)} ₽',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: theme.colorScheme.error,
            ),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
