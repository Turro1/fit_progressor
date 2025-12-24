import 'package:flutter/material.dart';
import '../features/clients/presentation/widgets/client_form_modal.dart';
import '../features/cars/presentation/widgets/car_form_modal.dart';

class FloatingActionButtonHandler extends StatelessWidget {
  final String currentPath;

  const FloatingActionButtonHandler({Key? key, required this.currentPath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      onPressed: () => _handleFabTap(context),
      backgroundColor:
          theme.colorScheme.secondary, // Changed from AppColors.accentPrimary
      child: Icon(
        Icons.add,
        color: theme.colorScheme.onSecondary,
        size: 32,
      ), // Changed from Colors.black
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
      case '/dashboard':
      default:
      //  _showRepairForm(context); // Re-add this as default
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
}
