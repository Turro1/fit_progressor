import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_state.dart';
import 'package:fit_progressor/features/clients/presentation/widgets/client_cars_modal.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_bloc.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_event.dart';
import 'package:fit_progressor/features/repairs/presentation/bloc/repairs_state.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_card.dart';
import 'package:fit_progressor/features/repairs/presentation/widgets/repair_form_modal.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fit_progressor/core/theme/app_spacing.dart';
import 'package:fit_progressor/core/utils/car_logo_helper.dart';
import 'package:fit_progressor/core/widgets/country_flag.dart';

import '../../domain/entities/car.dart';

class CarRepairsModal extends StatefulWidget {
  final Car car;
  /// Если передан - показывается кнопка "Назад" для возврата к клиенту
  final Client? sourceClient;

  const CarRepairsModal({
    Key? key,
    required this.car,
    this.sourceClient,
  }) : super(key: key);

  @override
  State<CarRepairsModal> createState() => _CarRepairsModalState();
}

class _CarRepairsModalState extends State<CarRepairsModal> {
  @override
  void initState() {
    super.initState();
    // Загружаем ремонты для конкретного автомобиля
    context.read<RepairsBloc>().add(LoadRepairs(carId: widget.car.id));
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _goBackToClient(BuildContext context) {
    if (widget.sourceClient == null) return;

    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientCarsModal(client: widget.sourceClient!),
    );
  }

  Client? _getOwner(ClientState state) {
    if (state is ClientLoaded) {
      return state.clients.firstWhere(
        (c) => c.id == widget.car.clientId,
        orElse: () => Client(
          id: '',
          name: 'Клиент не найден',
          phone: '',
          createdAt: DateTime.now(),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.lg,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
            ),
            child: Column(
              children: [
                // Drag handle + Back button row
                Row(
                  children: [
                    // Back button (только если пришли из ClientCarsModal)
                    if (widget.sourceClient != null)
                      IconButton(
                        onPressed: () => _goBackToClient(context),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Назад к клиенту',
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                      )
                    else
                      const SizedBox(width: 48), // placeholder для выравнивания
                    // Drag handle
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // placeholder для симметрии
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                // Car info
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          CarLogoHelper.getLogoPath(widget.car.make),
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.directions_car_rounded,
                              size: 32,
                              color: theme.colorScheme.primary,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.car.make} ${widget.car.model}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          PlateWithFlag(
                            plate: widget.car.plate,
                            textStyle: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Owner info
          BlocBuilder<ClientBloc, ClientState>(
            builder: (context, clientState) {
              final owner = _getOwner(clientState);
              if (owner == null || owner.id.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        radius: 20,
                        child: Text(
                          owner.name.isNotEmpty
                              ? owner.name[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              owner.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (owner.phone.isNotEmpty)
                              Text(
                                owner.phone,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (owner.phone.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () => _makePhoneCall(owner.phone),
                          tooltip: 'Позвонить',
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppSpacing.lg),

          // Заголовок секции ремонтов
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Ремонты',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                BlocBuilder<RepairsBloc, RepairsState>(
                  builder: (context, state) {
                    if (state is RepairsLoaded && state.repairs.isNotEmpty) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.repairs.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Repairs list
          Expanded(
            child: BlocConsumer<RepairsBloc, RepairsState>(
              listener: (context, state) {
                if (state is RepairsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
                if (state is RepairsOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  );
                  // Перезагружаем список ремонтов для этого автомобиля
                  context.read<RepairsBloc>().add(LoadRepairs(carId: widget.car.id));
                }
              },
              builder: (context, state) {
                if (state is RepairsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RepairsLoaded) {
                  if (state.repairs.isEmpty) {
                    return const EmptyState(
                      icon: Icons.build_circle_outlined,
                      title: 'Нет ремонтов',
                      message:
                          'У этого автомобиля пока нет зарегистрированных ремонтов',
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: state.repairs.length,
                    itemBuilder: (context, index) {
                      final repair = state.repairs[index];
                      return RepairCard(repair: repair);
                    },
                  );
                }

                return Center(
                  child: Text(
                    'Не удалось загрузить ремонты',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              },
            ),
          ),

          // Add repair button
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _addRepair(context),
                icon: const Icon(Icons.add),
                label: const Text('Добавить ремонт'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addRepair(BuildContext context) {
    // Сохраняем ссылку на bloc до закрытия окна
    final repairsBloc = context.read<RepairsBloc>();
    final carBloc = context.read<CarBloc>();
    final clientBloc = context.read<ClientBloc>();

    Navigator.pop(context);

    // Используем сохраненные ссылки
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: repairsBloc),
          BlocProvider.value(value: carBloc),
          BlocProvider.value(value: clientBloc),
        ],
        child: RepairFormModal(
          preselectedCarId: widget.car.id,
          preselectedClientId: widget.car.clientId,
        ),
      ),
    );
  }
}
