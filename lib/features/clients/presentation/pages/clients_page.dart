import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import '../widgets/client_card.dart';
import '../widgets/client_cars_modal.dart';
import '../widgets/client_form_modal.dart';
import '../widgets/client_search_bar.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Dispatch LoadClients event when the page is first built.
    // This ensures that clients are loaded when the page becomes active.
    final clientBloc = context.read<ClientBloc>();
    if (clientBloc.state is! ClientLoaded &&
        clientBloc.state is! ClientLoading) {
      clientBloc.add(LoadClients());
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.groups,
                        color: theme.colorScheme.onSurface,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Клиенты',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClientSearchBar(
                    onSearch: (query) {
                      context.read<ClientBloc>().add(
                        SearchClientsEvent(query: query),
                      );
                    },
                  ),
                ],
              ),
            ),
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
                  }
                },
                builder: (context, state) {
                  if (state is ClientLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ClientLoaded) {
                    if (state.clients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add_outlined,
                              size: 80,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Нет клиентов',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Нажмите "+" для добавления клиента',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: state.clients.length,
                      itemBuilder: (context, index) {
                        final client = state.clients[index];
                        return ClientCard(
                          client: client,
                          onEdit: () => _showClientModal(context, client),
                          onDelete: () => _confirmDelete(context, client),
                          onTap: () =>
                              _showClientCarsModal(context, client),
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
            child: Text('Удалить',
                style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
