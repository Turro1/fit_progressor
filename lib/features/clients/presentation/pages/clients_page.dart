import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import '../widgets/client_card.dart';
import '../widgets/client_form_modal.dart';
import '../widgets/client_search_bar.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
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
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Клиенты',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                  if (state is ClientOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.accentSecondary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ClientLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPrimary,
                      ),
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
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Нет клиентов',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Нажмите "+" для добавления клиента',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
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

  void _confirmDelete(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text(
          'Удалить клиента?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Это также удалит ВСЕ его автомобили и ремонты!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
