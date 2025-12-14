import 'package:flutter/material.dart';

class BaseFormModal extends StatelessWidget {
  final Widget titleIcon;
  final String titleText;
  final GlobalKey<FormState> formKey;
  final List<Widget> formFields;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;
  final String submitButtonText;
  final String cancelButtonText;

  const BaseFormModal({
    Key? key,
    required this.titleIcon,
    required this.titleText,
    required this.formKey,
    required this.formFields,
    required this.onSubmit,
    this.onCancel,
    required this.submitButtonText,
    this.cancelButtonText = 'Отмена',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = theme.cardTheme.shape is RoundedRectangleBorder
        ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
        : BorderRadius.circular(12); // Default to 12 if shape is not RoundedRectangleBorder

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular((borderRadius as BorderRadius).topLeft.x), // Apply top radii from theme
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconTheme(
                      data: theme.iconTheme.copyWith(
                          color: theme.colorScheme.primary,
                          size: theme.iconTheme.size, // Use theme icon size
                      ),
                      child: titleIcon,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        titleText,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...formFields,
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel ?? () => Navigator.pop(context),
                      child: Text(cancelButtonText),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onSubmit,
                      child: Text(submitButtonText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}