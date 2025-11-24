import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/repair_history.dart';
import '../../domain/entities/repair_status.dart';
import '../bloc/repair_bloc.dart';
import '../bloc/repair_event.dart';

class RepairEditorModal extends StatefulWidget {
  final Repair repair;

  const RepairEditorModal({Key? key, required this.repair}) : super(key: key);

  @override
  State<RepairEditorModal> createState() => _RepairEditorModalState();
}

class _RepairEditorModalState extends State<RepairEditorModal> {
  late TextEditingController _descriptionController;
  late TextEditingController _costWorkController;
  late TextEditingController _costPartsController;
  late TextEditingController _costPartsCostController;
  late TextEditingController _newNoteController;
  late RepairStatus _selectedStatus;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.repair.description);
    _costWorkController = TextEditingController(text: widget.repair.costWork.toString());
    _costPartsController = TextEditingController(text: widget.repair.costParts.toString());
    _costPartsCostController = TextEditingController(text: widget.repair.costPartsCost.toString());
    _newNoteController = TextEditingController();
    _selectedStatus = widget.repair.status;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _costWorkController.dispose();
    _costPartsController.dispose();
    _costPartsCostController.dispose();
    _newNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusSection(),
                    const SizedBox(height: 20),
                    _buildDescriptionSection(),
                    const SizedBox(height: 20),
                    _buildCostsSection(),
                    const SizedBox(height: 20),
                    _buildHistorySection(),
                    const SizedBox(height: 20),
                    _buildAddNoteSection(),
                    const SizedBox(height: 30),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: AppColors.accentPrimary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Детали ремонта',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Статус',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RepairStatus>(
          value: _selectedStatus,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgMain,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          dropdownColor: AppColors.bgHeader,
          style: TextStyle(color: AppColors.textPrimary),
          items: RepairStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedStatus = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание работ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgMain,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCostField(
          'Стоимость работ (₽)',
          _costWorkController,
          AppColors.accentSecondary,
        ),
        const SizedBox(height: 12),
        _buildCostField(
          'Стоимость запчастей (₽) - Продажная',
          _costPartsController,
          AppColors.accentSecondary,
        ),
        const SizedBox(height: 12),
        _buildCostField(
          'Стоимость запчастей (₽) - Закупочная',
          _costPartsCostController,
          AppColors.danger,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgMain,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Итого к оплате:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                CurrencyFormatter.format(
                  (double.tryParse(_costWorkController.text) ?? 0) +
                      (double.tryParse(_costPartsController.text) ?? 0),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostField(String label, TextEditingController controller, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgMain,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🕐 История и Заметки',
          style: TextStyle(
            color: AppColors.info,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (widget.repair.history.isEmpty)
          Text(
            'Нет записей в истории',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          ...widget.repair.history.reversed.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: item.type == HistoryType.statusChange
                        ? AppColors.accentPrimary
                        : AppColors.info,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatDateTime(item.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.type == HistoryType.statusChange
                        ? 'Статус изменен: ${item.note}'
                        : item.note,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAddNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _newNoteController,
          maxLines: 2,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Добавить новую заметку или комментарий...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.bgMain,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addNote,
          icon: Icon(Icons.add, color: AppColors.textPrimary),
          label: Text(
            'Добавить заметку',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bgHeader,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Закрыть',
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
          ),
          child: const Text(
            'Сохранить изменения',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _addNote() {
    if (_newNoteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Заметка не может быть пустой'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final updatedHistory = List<RepairHistory>.from(widget.repair.history)
      ..add(RepairHistory(
        timestamp: DateTime.now(),
        type: HistoryType.note,
        note: _newNoteController.text.trim(),
      ));

    final updatedRepair = widget.repair.copyWith(history: updatedHistory);

    context.read<RepairBloc>().add(UpdateRepairEvent(repair: updatedRepair));
    _newNoteController.clear();
    Navigator.pop(context);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      var updatedHistory = List<RepairHistory>.from(widget.repair.history);

      // Добавляем запись об изменении статуса
      if (_selectedStatus != widget.repair.status) {
        updatedHistory.add(RepairHistory(
          timestamp: DateTime.now(),
          type: HistoryType.statusChange,
          note: _selectedStatus.displayName,
        ));
      }

      final updatedRepair = widget.repair.copyWith(
        status: _selectedStatus,
        description: _descriptionController.text,
        costWork: double.tryParse(_costWorkController.text) ?? 0,
        costParts: double.tryParse(_costPartsController.text) ?? 0,
        costPartsCost: double.tryParse(_costPartsCostController.text) ?? 0,
        history: updatedHistory,
      );

      context.read<RepairBloc>().add(UpdateRepairEvent(repair: updatedRepair));
      Navigator.pop(context);
    }
  }
}