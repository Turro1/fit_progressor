import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/repair_status.dart';

class StatusFilterChips extends StatefulWidget {
  final Function(RepairStatus?) onFilterChanged;

  const StatusFilterChips({Key? key, required this.onFilterChanged})
      : super(key: key);

  @override
  State<StatusFilterChips> createState() => _StatusFilterChipsState();
}

class _StatusFilterChipsState extends State<StatusFilterChips> {
  RepairStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Все', null),
          const SizedBox(width: 8),
          _buildChip(RepairStatus.inProgress.displayName, RepairStatus.inProgress),
          const SizedBox(width: 8),
          _buildChip(RepairStatus.waitingParts.displayName, RepairStatus.waitingParts),
          const SizedBox(width: 8),
          _buildChip(RepairStatus.completed.displayName, RepairStatus.completed),
        ],
      ),
    );
  }

  Widget _buildChip(String label, RepairStatus? status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        widget.onFilterChanged(status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary : AppColors.bgHeader,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}