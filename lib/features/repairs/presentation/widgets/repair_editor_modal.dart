
import 'package:fit_progressor/features/materials/domain/entities/material.dart' as entities_material; // Alias for materials entity
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_history.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_material.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_part.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repair_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repair_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repair_state.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/select_material_modal_widget.dart' as select_material_modal;
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class RepairEditorModal extends flutter_material.StatefulWidget {
  final Repair repair;

  const RepairEditorModal({flutter_material.Key? key, required this.repair}) : super(key: key);

  @override
  flutter_material.State<RepairEditorModal> createState() => _RepairEditorModalState();
}

class _RepairEditorModalState extends flutter_material.State<RepairEditorModal> {
  int _currentStep = 0;
  late flutter_material.TextEditingController _descriptionController;
  late flutter_material.TextEditingController _costWorkController;
  late RepairStatus _selectedStatus;
  late List<RepairMaterial> _currentMaterials;
  late List<RepairPart> _currentParts;
  late List<String> _currentPhotos;
  DateTime? _plannedAt;
  final _formKey = flutter_material.GlobalKey<flutter_material.FormState>();

  @override
  void initState() {
    super.initState();
    _descriptionController =
        flutter_material.TextEditingController(text: widget.repair.description);
    _costWorkController =
        flutter_material.TextEditingController(text: widget.repair.costWork.toString());
    _selectedStatus = widget.repair.status;
    _currentMaterials = List<RepairMaterial>.from(widget.repair.materials);
    _currentParts = List<RepairPart>.from(widget.repair.parts);
    _currentPhotos = List<String>.from(widget.repair.photos);
    _plannedAt = widget.repair.plannedAt;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _costWorkController.dispose();
    super.dispose();
  }

  void _saveRepair() {
    List<RepairHistory> updatedHistory = List<RepairHistory>.from(widget.repair.history);
    final now = DateTime.now();

    // Check for status change
    if (_selectedStatus != widget.repair.status) {
      updatedHistory.add(RepairHistory(
        id: 'history_${now.millisecondsSinceEpoch}',
        timestamp: now,
        type: HistoryType.statusChange,
        description:
            'Статус изменен с "${widget.repair.status.displayName}" на "${_selectedStatus.displayName}"',
      ));
    }
    // TODO: Add history for other changes (description, costs, materials, parts, photos)

    final updatedRepair = widget.repair.copyWith(
      description: _descriptionController.text,
      costWork: double.parse(_costWorkController.text),
      status: _selectedStatus,
      materials: _currentMaterials,
      parts: _currentParts,
      photos: _currentPhotos,
      history: updatedHistory,
      plannedAt: _plannedAt,
    );
    context.read<RepairBloc>().add(UpdateRepairEvent(repair: updatedRepair));
    context.pop(); // Close modal
  }

  void _showSelectMaterialModal() async {
    final List<entities_material.Material>? result = await flutter_material.showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: flutter_material.Colors.transparent,
      builder: (context) => select_material_modal.SelectMaterialModal(
        selectedMaterials: _currentMaterials
            .map((e) => entities_material.Material(
                  id: e.materialId,
                  name: e.name,
                  quantity: e.quantity.toDouble(),
                  cost: e.price,
                  minQuantity: 0, // Placeholder
                  unit: entities_material.MaterialUnit.pcs, // Default unit
                ))
            .toList(),
      ),
    );

    if (result != null) {
      setState(() {
        _currentMaterials = result
            .map((m) => RepairMaterial(
                  materialId: m.id,
                  name: m.name,
                  quantity: m.quantity.toInt(),
                  price: m.cost,
                ))
            .toList();
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _currentPhotos.add(image.path);
      });
    }
  }

  @override
  flutter_material.Widget build(flutter_material.BuildContext context) {
    final theme = flutter_material.Theme.of(context);
    final borderRadius = theme.cardTheme.shape is flutter_material.RoundedRectangleBorder
        ? (theme.cardTheme.shape as flutter_material.RoundedRectangleBorder).borderRadius
        : flutter_material.BorderRadius.circular(12); // Default to 12 if shape is not RoundedRectangleBorder

    return BlocListener<RepairBloc, RepairState>(
      listener: (context, state) {
        if (state is RepairOperationSuccess) {
          flutter_material.ScaffoldMessenger.of(context).showSnackBar(
            flutter_material.SnackBar(content: flutter_material.Text(state.message)),
          );
          context.pop(); // Close the modal
        } else if (state is RepairError) {
          flutter_material.ScaffoldMessenger.of(context).showSnackBar(
            flutter_material.SnackBar(content: flutter_material.Text(state.message)),
          );
        }
      },
      child: flutter_material.Padding(
        padding:
            flutter_material.EdgeInsets.only(bottom: flutter_material.MediaQuery.of(context).viewInsets.bottom),
        child: flutter_material.Container(
          height: flutter_material.MediaQuery.of(context).size.height * 0.9,
          decoration: flutter_material.BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: flutter_material.BorderRadius.vertical(top: flutter_material.Radius.circular(borderRadius.resolve(flutter_material.Directionality.of(context)).topLeft.x)),
          ),
          child: flutter_material.Column(
            children: [
              _buildHeader(context, borderRadius.resolve(flutter_material.Directionality.of(context)).topLeft.x),
              flutter_material.Expanded(
                child: flutter_material.Stepper(
                  type: flutter_material.StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    // Validate only the 'Details' step, as it contains form fields
                    if (_currentStep == 0 && !_formKey.currentState!.validate()) {
                      return;
                    }

                    if (_currentStep < _getSteps().length - 1) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else {
                      _saveRepair();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    } else {
                      context.pop();
                    }
                  },
                  steps: _getSteps(),
                  controlsBuilder: (context, details) {
                    final theme = flutter_material.Theme.of(context);
                    return flutter_material.Padding(
                      padding: const flutter_material.EdgeInsets.only(top: 20.0),
                      child: flutter_material.Row(
                        children: [
                          flutter_material.Expanded(
                            child: flutter_material.ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: flutter_material.ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                padding: const flutter_material.EdgeInsets.symmetric(vertical: 15),
                                shape: flutter_material.RoundedRectangleBorder(
                                  borderRadius: flutter_material.BorderRadius.circular(10),
                                ),
                              ),
                              child: flutter_material.Text(
                                _currentStep == _getSteps().length - 1
                                    ? 'Сохранить изменения'
                                    : 'Продолжить',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            const flutter_material.SizedBox(width: 10),
                            flutter_material.Expanded(
                              child: flutter_material.OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: flutter_material.OutlinedButton.styleFrom(
                                  padding: const flutter_material.EdgeInsets.symmetric(vertical: 15),
                                  side: flutter_material.BorderSide(color: theme.colorScheme.secondary),
                                  shape: flutter_material.RoundedRectangleBorder(
                                    borderRadius: flutter_material.BorderRadius.circular(10),
                                  ),
                                ),
                                child: flutter_material.Text(
                                  'Назад',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  flutter_material.Widget _buildHeader(flutter_material.BuildContext context, double borderRadius) {
    final theme = flutter_material.Theme.of(context);
    return flutter_material.Container(
      padding: const flutter_material.EdgeInsets.all(15),
      decoration: flutter_material.BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        borderRadius: flutter_material.BorderRadius.vertical(top: flutter_material.Radius.circular(borderRadius)),
      ),
      child: flutter_material.Row(
        mainAxisAlignment: flutter_material.MainAxisAlignment.spaceBetween,
        children: [
          flutter_material.Text(
            'Редактировать ремонт',
            style: theme.textTheme.headlineSmall?.copyWith(color: theme.appBarTheme.titleTextStyle?.color),
          ),
          flutter_material.IconButton(
            icon: flutter_material.Icon(flutter_material.Icons.close, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  List<flutter_material.Step> _getSteps() {
    return [
      flutter_material.Step(
        title: const flutter_material.Text('Детали'),
        content: _buildRepairDetailsStep(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? flutter_material.StepState.complete : flutter_material.StepState.indexed,
      ),
      flutter_material.Step(
        title: const flutter_material.Text('Материалы'),
        content: _buildMaterialsSelectionStep(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? flutter_material.StepState.complete : flutter_material.StepState.indexed,
      ),
      flutter_material.Step(
        title: const flutter_material.Text('Запчасти'),
        content: _buildRepairPartsStep(),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? flutter_material.StepState.complete : flutter_material.StepState.indexed,
      ),
      flutter_material.Step(
        title: const flutter_material.Text('Фото'),
        content: _buildPhotosStep(),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? flutter_material.StepState.complete : flutter_material.StepState.indexed,
      ),
      flutter_material.Step(
        title: const flutter_material.Text('История'),
        content: _buildHistoryStep(),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? flutter_material.StepState.complete : flutter_material.StepState.indexed,
      ),
    ];
  }

  flutter_material.Widget _buildRepairDetailsStep() {
    final theme = flutter_material.Theme.of(context);
    return flutter_material.Form(
      key: _formKey,
      child: flutter_material.Column(
        crossAxisAlignment: flutter_material.CrossAxisAlignment.start,
        children: [
          const flutter_material.SizedBox(height: 20),
          flutter_material.TextFormField(
            controller: _descriptionController,
            decoration: const flutter_material.InputDecoration(
              labelText: 'Описание ремонта',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите описание ремонта';
              }
              return null;
            },
          ),
          const flutter_material.SizedBox(height: 15),
          flutter_material.TextFormField(
            controller: _costWorkController,
            decoration: const flutter_material.InputDecoration(
              labelText: 'Стоимость работ',
            ),
            keyboardType: flutter_material.TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите стоимость работ';
              }
              if (double.tryParse(value) == null) {
                return 'Пожалуйста, введите числовое значение';
              }
              return null;
            },
          ),
          const flutter_material.SizedBox(height: 15),
          flutter_material.DropdownButtonFormField<RepairStatus>(
            initialValue: _selectedStatus,
            decoration: const flutter_material.InputDecoration(
              labelText: 'Статус ремонта',
            ),
            dropdownColor: theme.colorScheme.surface,
            items: RepairStatus.values.map((status) {
              return flutter_material.DropdownMenuItem(
                value: status,
                child: flutter_material.Text(status.displayName),
              );
            }).toList(),
            onChanged: (status) {
              if (status != null) {
                setState(() {
                  _selectedStatus = status;
                });
              }
            },
          ),
          const flutter_material.SizedBox(height: 15),
          flutter_material.InkWell(
            onTap: () async {
              final DateTime? picked = await flutter_material.showDatePicker(
                context: context,
                initialDate: _plannedAt ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != _plannedAt) {
                setState(() {
                  _plannedAt = picked;
                });
              }
            },
            child: flutter_material.InputDecorator(
              decoration: const flutter_material.InputDecoration(
                labelText: 'Запланировано на',
              ),
              child: flutter_material.Text(
                _plannedAt != null
                    ? DateFormat('d MMMM y', 'ru').format(_plannedAt!)
                    : 'Не выбрана',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  flutter_material.Widget _buildMaterialsSelectionStep() {
    final theme = flutter_material.Theme.of(context);
    return flutter_material.Column(
      crossAxisAlignment: flutter_material.CrossAxisAlignment.start,
      children: [
        const flutter_material.SizedBox(height: 10),
        if (_currentMaterials.isEmpty)
          flutter_material.Text(
            'Нет используемых материалов',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          )
        else
          ..._currentMaterials.map((material) {
            return flutter_material.Card(
              color: theme.cardTheme.color,
              margin: const flutter_material.EdgeInsets.symmetric(vertical: 5),
              child: flutter_material.ListTile(
                title: flutter_material.Text(
                    '${material.name} (${material.quantity} шт.)',
                    style:
                    theme.textTheme.titleMedium),
                trailing: flutter_material.IconButton(
                  icon: flutter_material.Icon(flutter_material.Icons.remove_circle,
                      color: theme.colorScheme.error),
                  onPressed: () {
                    setState(() {
                      _currentMaterials.remove(material);
                    });
                  },
                ),
              ),
            );
          }),
        const flutter_material.SizedBox(height: 15),
        flutter_material.ElevatedButton(
          onPressed: _showSelectMaterialModal,
          style: theme.elevatedButtonTheme.style,
          child: flutter_material.Text(
            'Выбрать материалы',
          ),
        ),
      ],
    );
  }

  flutter_material.Widget _buildRepairPartsStep() {
    final theme = flutter_material.Theme.of(context);
    return flutter_material.Column(
      crossAxisAlignment: flutter_material.CrossAxisAlignment.start,
      children: [
        const flutter_material.SizedBox(height: 10),
        // TODO: Implement dynamic parts selection/editing
        flutter_material.Text(
          'Раздел для динамических запчастей будет реализован позднее.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  flutter_material.Widget _buildPhotosStep() {
    final theme = flutter_material.Theme.of(context);
    return flutter_material.Column(
      crossAxisAlignment: flutter_material.CrossAxisAlignment.start,
      children: [
        const flutter_material.SizedBox(height: 10),
        if (_currentPhotos.isEmpty)
          flutter_material.Text('Нет прикрепленных фото',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
        flutter_material.Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _currentPhotos
              .map((path) => flutter_material.Stack(
            children: [
              flutter_material.Image.file(
                File(path),
                width: 100,
                height: 100,
                fit: flutter_material.BoxFit.cover,
              ),
              flutter_material.Positioned(
                top: 0,
                right: 0,
                child: flutter_material.GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentPhotos.remove(path);
                    });
                  },
                  child: flutter_material.CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.error,
                    child: flutter_material.Icon(flutter_material.Icons.close,
                        size: 16,
                        color: theme.colorScheme.onError),
                  ),
                ),
              ),
            ],
          ))
              .toList(),
        ),
        const flutter_material.SizedBox(height: 15),
        flutter_material.ElevatedButton.icon(
          onPressed: _pickImage,
          icon:
          flutter_material.Icon(flutter_material.Icons.add_a_photo),
          label: flutter_material.Text('Добавить фото'),
          style: theme.elevatedButtonTheme.style,
        ),
      ],
    );
  }

  flutter_material.Widget _buildHistoryStep() {
    final theme = flutter_material.Theme.of(context);
    return flutter_material.Column(
      crossAxisAlignment: flutter_material.CrossAxisAlignment.start,
      children: [
        const flutter_material.SizedBox(height: 10),
        if (widget.repair.history.isEmpty)
          flutter_material.Text(
            'История пуста',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          )
        else
          ...widget.repair.history.reversed.map((item) {
            return flutter_material.Padding(
              padding:
              const flutter_material.EdgeInsets.symmetric(vertical: 4.0),
              child: flutter_material.Row(
                crossAxisAlignment: flutter_material.CrossAxisAlignment.start,
                children: [
                  flutter_material.Text(
                    '${item.timestamp.toLocal().toString().split(' ')[0]} - ',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                  flutter_material.Expanded(
                    child: flutter_material.Text(
                      '${item.type.displayName}: ${item.description}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}