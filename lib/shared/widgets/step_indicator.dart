import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive || isCompleted
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.surface,
                      border: Border.all(
                        color: isActive || isCompleted
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: theme.colorScheme.onSecondary,
                            )
                          : Text(
                              '${index + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isActive
                                    ? theme.colorScheme.onSecondary
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stepLabels[index],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}
