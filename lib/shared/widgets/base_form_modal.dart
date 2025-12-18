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

  // Новые Material 3 параметры
  final bool showDragHandle;
  final bool centeredTitle;
  final bool isLoading;
  final bool fullWidthActions;

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
    // Новые параметры с defaults
    this.showDragHandle = true,
    this.centeredTitle = true,
    this.isLoading = false,
    this.fullWidthActions = false,
  }) : super(key: key);

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
          top: Radius.circular((borderRadius as BorderRadius).topLeft.x),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                if (showDragHandle) ...[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
                // Title
                Row(
                  mainAxisAlignment: centeredTitle
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    IconTheme(
                      data: theme.iconTheme.copyWith(
                        color: theme.colorScheme.primary,
                        size: theme.iconTheme.size,
                      ),
                      child: titleIcon,
                    ),
                    const SizedBox(width: 12),
                    if (!centeredTitle)
                      Expanded(
                        child: Text(
                          titleText,
                          style: theme.textTheme.titleLarge,
                        ),
                      )
                    else
                      Text(titleText, style: theme.textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 24),
                // Form fields
                ...formFields,
                const SizedBox(height: 24),
                // Actions
                if (fullWidthActions)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: isLoading ? null : onSubmit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(submitButtonText),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : (onCancel ?? () => Navigator.pop(context)),
                        child: Text(cancelButtonText),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : (onCancel ?? () => Navigator.pop(context)),
                        child: Text(cancelButtonText),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: isLoading ? null : onSubmit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(submitButtonText),
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
