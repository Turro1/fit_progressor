import 'package:flutter/material.dart';
// import '../../../../core/theme/app_colors.dart'; // Removed direct import
import '../../domain/entities/repair_status.dart';

class StatusFilterChips extends StatefulWidget {
  final Function(RepairStatus?) onFilterChanged;
  final RepairStatus? initialStatus;

  const StatusFilterChips({
    Key? key,
    required this.onFilterChanged,
    this.initialStatus,
  }) : super(key: key);

  @override
  State<StatusFilterChips> createState() => _StatusFilterChipsState();
}

class _StatusFilterChipsState extends State<StatusFilterChips> {
  RepairStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Все', null, context), // Pass context
          const SizedBox(width: 8),
          _buildChip(RepairStatus.inProgress.displayName, RepairStatus.inProgress, context), // Pass context
          const SizedBox(width: 8),
          _buildChip(RepairStatus.waitingParts.displayName, RepairStatus.waitingParts, context), // Pass context
          const SizedBox(width: 8),
          _buildChip(RepairStatus.completed.displayName, RepairStatus.completed, context), // Pass context
          const SizedBox(width: 8),
          _buildChip(RepairStatus.cancelled.displayName, RepairStatus.cancelled, context), // Pass context
        ],
      ),
    );
  }

  Widget _buildChip(String label, RepairStatus? status, BuildContext context) { // Added BuildContext
    final theme = Theme.of(context);
    final bool isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
        widget.onFilterChanged(_selectedStatus);
      },
      selectedColor: theme.colorScheme.secondary, // Use theme accent
      backgroundColor: theme.colorScheme.surface, // Use theme surface
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface, // Use theme text colors
      ),
      side: BorderSide(
          color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.outline, // Use theme colors
      ),
    );
  }
}
