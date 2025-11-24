import 'package:fit_progressor/features/repairs/presentation/widgets/repair_wizard_modal.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/clients/presentation/widgets/client_form_modal.dart';
import '../features/cars/presentation/widgets/car_form_modal.dart';

class FloatingActionButtonHandler extends StatelessWidget {
  final String currentPath;

  const FloatingActionButtonHandler({Key? key, required this.currentPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _handleFabTap(context),
      backgroundColor: AppColors.accentPrimary,
      child: const Icon(Icons.add, color: Colors.black, size: 32),
    );
  }

  void _handleFabTap(BuildContext context) {
    switch (currentPath) {
      case '/clients':
        _showClientModal(context);
        break;
      case '/cars':
        _showCarModal(context);
        break;
      case '/repairs':
      _showRepairWizard(context);
      break;
      case '/materials':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material modal - TODO'),
            backgroundColor: AppColors.accentPrimary,
          ),
        );
        break;
      case '/dashboard':
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repair wizard - TODO'),
            backgroundColor: AppColors.accentPrimary,
          ),
        );
    }
  }

  void _showClientModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ClientFormModal(),
    );
  }

  void _showCarModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CarFormModal(),
    );
  }

    void _showRepairWizard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RepairWizardModal(),
    );
  }
}