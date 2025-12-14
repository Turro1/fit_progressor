import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart'; // Keep AppColors for info
import '../../../../injection_container.dart' as di;
import '../../../../features/materials/domain/entities/material.dart' as entities_material; // Alias for materials entity
import '../../../../features/materials/presentation/bloc/material_bloc.dart';
import '../../../../features/materials/presentation/bloc/material_event.dart';
import '../../../../features/materials/presentation/bloc/material_state.dart' as my_material_state;


class SelectMaterialModal extends StatefulWidget {
  final List<entities_material.Material> selectedMaterials;

  const SelectMaterialModal({Key? key, required this.selectedMaterials}) : super(key: key);

  @override
  State<SelectMaterialModal> createState() => _SelectMaterialModalState();
}

class _SelectMaterialModalState extends State<SelectMaterialModal> {
  late List<entities_material.Material> _currentSelectedMaterials;

  @override
  void initState() {
    super.initState();
    _currentSelectedMaterials = List.from(widget.selectedMaterials);
  }

  void _toggleMaterialSelection(entities_material.Material material) {
    setState(() {
      if (_currentSelectedMaterials.any((m) => m.id == material.id)) {
        _currentSelectedMaterials.removeWhere((m) => m.id == material.id);
      } else {
        _currentSelectedMaterials.add(material.copyWith(quantity: 1)); // Default to 1 when adding
      }
    });
  }

  void _updateMaterialQuantity(entities_material.Material material, double quantity) {
    setState(() {
      final index =
          _currentSelectedMaterials.indexWhere((m) => m.id == material.id);
      if (index != -1) {
        _currentSelectedMaterials[index] =
            _currentSelectedMaterials[index].copyWith(quantity: quantity.toDouble());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = theme.cardTheme.shape is RoundedRectangleBorder
        ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
        : BorderRadius.circular(12); // Default to 12 if shape is not RoundedRectangleBorder

    return BlocProvider(
      create: (context) => di.sl<MaterialBloc>()..add(LoadMaterials()),
      child: BlocBuilder<MaterialBloc, my_material_state.MaterialState>(
        builder: (context, state) {
          List<entities_material.Material> availableMaterials = [];
          if (state is my_material_state.MaterialLoaded) {
            availableMaterials = state.materials;
          }

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor, // Use theme scaffold background
                borderRadius: BorderRadius.vertical(top: Radius.circular((borderRadius as BorderRadius).topLeft.x)), // Use theme border radius
              ),
              child: Column(
                children: [
                  _buildHeader(context, borderRadius.topLeft.x), // Pass context and border radius
                  Expanded(
                    child: availableMaterials.isEmpty
                        ? Center(
                            child: Text(
                              'Нет доступных материалов',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: availableMaterials.length,
                            itemBuilder: (context, index) {
                              final material = availableMaterials[index];
                              final bool isSelected = _currentSelectedMaterials
                                  .any((m) => m.id == material.id);
                              final double selectedQuantity = isSelected
                                  ? _currentSelectedMaterials
                                      .firstWhere((m) => m.id == material.id)
                                      .quantity
                                  : 0;

                              return Card(
                                color: isSelected
                                    ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                                    : theme.cardTheme.color, // Use theme card color
                                margin:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: ExpansionTile(
                                  onExpansionChanged: (expanded) {
                                    if (expanded && !isSelected) {
                                      _toggleMaterialSelection(material);
                                    }
                                  },
                                  leading: Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      _toggleMaterialSelection(material);
                                    },
                                    activeColor: theme.colorScheme.secondary, // Use theme secondary
                                  ),
                                  title: Text(material.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                          color: theme.colorScheme.onSurface)),
                                  subtitle: Text(
                                      'На складе: ${material.quantity}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                                  trailing: isSelected
                                      ? SizedBox(
                                          width: 100,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove,
                                                    color: AppColors.info), // Still using AppColors.info
                                                onPressed: selectedQuantity > 1.0
                                                    ? () => _updateMaterialQuantity(
                                                        material,
                                                        selectedQuantity - 1.0)
                                                    : null,
                                              ),
                                              Text(
                                                selectedQuantity.toStringAsFixed(0), // Display as integer
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: theme.colorScheme.onSurface),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add,
                                                    color: AppColors.info), // Still using AppColors.info
                                                onPressed: selectedQuantity < material.quantity
                                                    ? () => _updateMaterialQuantity(
                                                        material,
                                                        selectedQuantity + 1.0)
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      child: Text(
                                        'Цена за ед.: ${material.cost}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop(_currentSelectedMaterials);
                      },
                      style: theme.elevatedButtonTheme.style, // Use theme button style
                      child: Text(
                        'Готово',
                        style: theme.elevatedButtonTheme.style?.textStyle?.resolve({}), // Use theme button text style
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double borderRadius) { // Added BuildContext and borderRadius
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Use theme surface
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)), // Use theme border radius
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Выбрать материалы',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface), // Use theme onSurface color
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
