import 'dart:io';
import 'package:fit_progressor/core/utils/car_logo_helper.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair_status.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/photo_viewer.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/shared/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Детальный просмотр ремонта с галереей фото
class RepairDetailSheet extends StatefulWidget {
  final Repair repair;
  /// Имя клиента (опционально, для отображения в карточке)
  final String? clientName;
  /// Телефон клиента (опционально, для возможности позвонить)
  final String? clientPhone;

  const RepairDetailSheet({
    super.key,
    required this.repair,
    this.clientName,
    this.clientPhone,
  });

  /// Показать детальный просмотр ремонта
  static Future<void> show(
    BuildContext context,
    Repair repair, {
    String? clientName,
    String? clientPhone,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<RepairsBloc>(),
        child: RepairDetailSheet(
          repair: repair,
          clientName: clientName,
          clientPhone: clientPhone,
        ),
      ),
    );
  }

  @override
  State<RepairDetailSheet> createState() => _RepairDetailSheetState();
}

class _RepairDetailSheetState extends State<RepairDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late PageController _photoPageController;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _photoPageController = PageController();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _photoPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repair = widget.repair;
    final hasPhotos = repair.photoPaths.isNotEmpty;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: hasPhotos ? 0.85 : 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      _buildDragHandle(theme),
                      // Content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            // Photo gallery or placeholder
                            _buildPhotoSection(theme, hasPhotos),
                            // Repair info
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(theme),
                                  const SizedBox(height: 16),
                                  _buildInfoSection(theme),
                                  if (repair.description.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    _buildDescriptionSection(theme),
                                  ],
                                  if (repair.materials.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    _buildMaterialsSection(theme),
                                  ],
                                  const SizedBox(height: 24),
                                  _buildActionButtons(context, theme),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Секция фото - галерея или плейсхолдер
  Widget _buildPhotoSection(ThemeData theme, bool hasPhotos) {
    if (hasPhotos) {
      return _buildPhotoGallery(theme);
    }
    return _buildAddPhotoPlaceholder(theme);
  }

  /// Плейсхолдер "Добавить фото" когда нет фотографий
  Widget _buildAddPhotoPlaceholder(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showEditModal(context);
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Добавить фото',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(ThemeData theme) {
    final photos = widget.repair.photoPaths;

    return Column(
      children: [
        // Photo carousel
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              // Photos
              PageView.builder(
                controller: _photoPageController,
                itemCount: photos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPhotoIndex = index;
                  });
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  final file = File(photos[index]);
                  return GestureDetector(
                    onTap: () => _openFullscreenPhoto(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: file.existsSync()
                            ? Hero(
                                tag: 'repair_photo_${widget.repair.id}_$index',
                                child: Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPhotoErrorPlaceholder(theme),
                                ),
                              )
                            : _buildPhotoErrorPlaceholder(theme),
                      ),
                    ),
                  );
                },
              ),
              // Add photo button
              Positioned(
                top: 12,
                left: 24,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showEditModal(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_a_photo,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Добавить',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Photo counter badge
              Positioned(
                top: 12,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentPhotoIndex + 1}/${photos.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Fullscreen button
              Positioned(
                bottom: 12,
                right: 24,
                child: GestureDetector(
                  onTap: () => _openFullscreenPhoto(_currentPhotoIndex),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Page indicators (dots)
        if (photos.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPhotoIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPhotoIndex == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoErrorPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final repair = widget.repair;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car logo
        if (repair.carMake.isNotEmpty)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                CarLogoHelper.getLogoPath(repair.carMake),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        const SizedBox(width: 16),
        // Title and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                repair.partType,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (repair.partPosition.isNotEmpty)
                Text(
                  repair.partPosition,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
        // Status badge
        _buildStatusBadge(theme),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final status = widget.repair.status;
    Color badgeColor;
    Color textColor;

    switch (status) {
      case RepairStatus.pending:
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case RepairStatus.inProgress:
        badgeColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
      case RepairStatus.completed:
        badgeColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case RepairStatus.cancelled:
        badgeColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
    }

    return GestureDetector(
      onTap: () => _showStatusChangeDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status.displayName,
          style: theme.textTheme.labelMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    final repair = widget.repair;
    final hasClientInfo = widget.clientName != null && widget.clientName!.isNotEmpty;
    final hasPhone = widget.clientPhone != null && widget.clientPhone!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Client info with call button
          if (hasClientInfo)
            _buildClientRow(theme, hasPhone),
          // Car info
          if (repair.carMake.isNotEmpty)
            _buildInfoRow(
              theme,
              Icons.directions_car_outlined,
              'Автомобиль',
              '${repair.carMake} ${repair.carModel}',
            ),
          // Date & Time
          _buildInfoRow(
            theme,
            Icons.event_outlined,
            'Дата и время',
            DateFormat('dd MMMM yyyy, HH:mm', 'ru').format(repair.date),
          ),
          // Cost - оранжевый цвет как на скриншоте
          _buildInfoRow(
            theme,
            Icons.payments_outlined,
            'Стоимость работы',
            '${repair.cost.toStringAsFixed(0)} ₽',
            valueColor: Colors.orange.shade600,
          ),
          // Materials cost - также оранжевый
          if (repair.materials.isNotEmpty)
            _buildInfoRow(
              theme,
              Icons.inventory_2_outlined,
              'Материалы',
              '${repair.materialsCost.toStringAsFixed(0)} ₽',
              valueColor: Colors.orange.shade600,
            ),
          // Total profit - показываем всегда
          _buildInfoRow(
            theme,
            Icons.trending_up,
            'Прибыль',
            '${repair.profit >= 0 ? '' : ''}${repair.profit.toStringAsFixed(0)} ₽',
            valueColor: repair.profit >= 0 ? Colors.green.shade600 : Colors.red.shade600,
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Строка с информацией о клиенте и кнопкой звонка
  Widget _buildClientRow(ThemeData theme, bool hasPhone) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Клиент',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      widget.clientName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              // Кнопка звонка
              if (hasPhone)
                GestureDetector(
                  onTap: _callClient,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.phone,
                      size: 22,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  /// Позвонить клиенту
  Future<void> _callClient() async {
    if (widget.clientPhone == null || widget.clientPhone!.isEmpty) return;

    final phoneNumber = widget.clientPhone!.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Описание',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.repair.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(ThemeData theme) {
    final materials = widget.repair.materials;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Использованные материалы',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...materials.map((material) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        material.materialName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${material.quantity} × ${material.unitCost.toStringAsFixed(0)} ₽',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${material.totalCost.toStringAsFixed(0)} ₽',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Edit button
        Expanded(
          child: _ActionButton(
            icon: Icons.edit_outlined,
            label: 'Изменить',
            color: theme.colorScheme.primary,
            onTap: () {
              Navigator.pop(context);
              _showEditModal(context);
            },
          ),
        ),
        const SizedBox(width: 12),
        // Status button
        Expanded(
          child: _ActionButton(
            icon: Icons.sync_alt,
            label: 'Статус',
            color: theme.colorScheme.secondary,
            onTap: () => _showStatusChangeDialog(context),
          ),
        ),
        const SizedBox(width: 12),
        // Delete button
        Expanded(
          child: _ActionButton(
            icon: Icons.delete_outline,
            label: 'Удалить',
            color: theme.colorScheme.error,
            onTap: () => _confirmDelete(context),
          ),
        ),
      ],
    );
  }

  void _openFullscreenPhoto(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewer(
          photoPaths: widget.repair.photoPaths,
          initialIndex: index,
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<RepairsBloc>(),
        child: RepairFormModal(repair: widget.repair),
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    final repairsBloc = context.read<RepairsBloc>();
    final repair = widget.repair;

    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      data: DeleteConfirmationData(
        title: 'Удалить ремонт?',
        itemName: repair.partType,
        itemSubtitle:
            '${repair.carMake} ${repair.carModel} • ${DateFormat('dd.MM.yyyy').format(repair.date)}',
        icon: Icons.build_outlined,
        warnings: [
          'Стоимость: ${repair.cost.toStringAsFixed(0)} ₽',
          'Это действие нельзя отменить',
        ],
      ),
    );

    if (confirmed && context.mounted) {
      Navigator.pop(context);
      repairsBloc.add(DeleteRepairEvent(repairId: repair.id));
    }
  }

  void _showStatusChangeDialog(BuildContext context) {
    final repair = widget.repair;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Изменить статус'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RepairStatus.values.map((status) {
            final isSelected = status == repair.status;
            return ListTile(
              selected: isSelected,
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(status.displayName),
              onTap: () {
                Navigator.pop(dialogContext);
                if (status != repair.status) {
                  context.read<RepairsBloc>().add(
                        UpdateRepairEvent(repair: repair.copyWith(status: status)),
                      );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }
}

/// Кнопка действия
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(widget.icon, color: widget.color, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
