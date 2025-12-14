import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/repair.dart';
import 'status_tag.dart';

class RepairCard extends StatelessWidget {
  final Repair repair;
  final VoidCallback onTap; // Это будет использоваться как кнопка редактирования
  final VoidCallback onDelete;

  const RepairCard({
    Key? key,
    required this.repair,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Allow the car/client info to take available space
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_car, color: AppColors.accent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${repair.carMake ?? 'Неизвестно'} ${repair.carModel ?? 'Неизвестно'} (${repair.carPlate ?? 'N/A'})',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Prevent overflow
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.person, color: AppColors.textSecondary, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  repair.clientName ?? 'Неизвестно',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Prevent overflow
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10), // Space between info and status
                    StatusTag(status: repair.status),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: AppColors.cardBorder), // Visual separator
                const SizedBox(height: 10),
                _buildDetailAndPosition(repair.description),
                const SizedBox(height: 10),
                Text(
                  CurrencyFormatter.format(repair.totalCost),
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // Space between content and buttons
          Column( // Кнопки справа
            children: [
              IconButton(
                onPressed: onTap, // Используем onTap для редактирования
                icon: Icon(Icons.edit, color: AppColors.accent),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero, // Remove extra padding
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap area
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete, color: AppColors.error),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to parse and display detail and position
  Widget _buildDetailAndPosition(String description) {
    String detail = 'Не указано';
    String position = 'Не указано';

    final detailMatch = RegExp(r'Деталь: ([^,]+)').firstMatch(description);
    if (detailMatch != null && detailMatch.groupCount > 0) {
      detail = detailMatch.group(1)!.trim();
    }

    final positionMatch = RegExp(r'Позиция: (.+)').firstMatch(description);
    if (positionMatch != null && positionMatch.groupCount > 0) {
      position = positionMatch.group(1)!.trim();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.handyman, color: AppColors.textPrimary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                detail,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                position,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );}
}