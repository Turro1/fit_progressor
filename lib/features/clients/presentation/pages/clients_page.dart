import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_bloc.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_event.dart';
import 'package:fit_progressor/features/cars/presentation/bloc/car_state.dart';
import 'package:fit_progressor/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import '../widgets/client_card.dart';
import '../widgets/client_cars_modal.dart';
import '../widgets/client_form_modal.dart';
import 'package:fit_progressor/shared/widgets/app_search_bar.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({Key? key}) : super(key: key);

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  @override
  void initState() {
    super.initState();
    // Load clients and cars on init
    context.read<ClientBloc>().add(LoadClients());
    context.read<CarBloc>().add(LoadCars());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientModal(context),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with icon and title
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: theme.colorScheme.onSurface,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text('Клиенты', style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: AppSearchBar(
                hintText: 'Поиск по имени или телефону...',
                onSearch: (query) {
                  context.read<ClientBloc>().add(
                    SearchClientsEvent(query: query),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            // Content
            Expanded(
              child: BlocConsumer<ClientBloc, ClientState>(
                listener: (context, state) {
                  if (state is ClientError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  if (state is ClientOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    );
                    // Перезагружаем список после успешной операции
                    context.read<ClientBloc>().add(LoadClients());
                  }
                },
                builder: (context, clientState) {
                  if (clientState is ClientLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (clientState is ClientLoaded) {
                    if (clientState.clients.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<ClientBloc>().add(LoadClients());
                        },
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const EmptyState(
                                icon: Icons.people_outline,
                                title: 'Нет клиентов',
                                message:
                                    'Добавьте первого клиента, нажав кнопку "Добавить"',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return BlocBuilder<CarBloc, CarState>(
                      builder: (context, carState) {
                        // Подсчет автомобилей для каждого клиента
                        Map<String, int> carsCountByClient = {};
                        if (carState is CarLoaded) {
                          for (final car in carState.cars) {
                            carsCountByClient[car.clientId] =
                                (carsCountByClient[car.clientId] ?? 0) + 1;
                          }
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<ClientBloc>().add(LoadClients());
                            context.read<CarBloc>().add(LoadCars());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: clientState.clients.length,
                            itemBuilder: (context, index) {
                              final client = clientState.clients[index];
                              return ClientCard(
                                client: client,
                                carsCount: carsCountByClient[client.id] ?? 0,
                                onEdit: () => _showClientModal(context, client),
                                onDelete: () => _confirmDelete(context, client),
                                onTap: () =>
                                    _showClientCarsModal(context, client),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClientModal(BuildContext context, [Client? client]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientFormModal(client: client),
    );
  }

  void _showClientCarsModal(BuildContext context, Client client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientCarsModal(client: client),
    );
  }

  void _confirmDelete(BuildContext context, Client client) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить клиента?'),
        content: Text(
          'Это также удалит ВСЕ его автомобили и ремонты!',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<ClientBloc>().add(
                DeleteClientEvent(clientId: client.id),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Удалить',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
