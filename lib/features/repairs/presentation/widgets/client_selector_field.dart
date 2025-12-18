import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_bloc.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_event.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_state.dart';

class ClientSelectorField extends StatefulWidget {
  final String? initialClientId;
  final Function(Client?) onClientSelected;

  const ClientSelectorField({
    Key? key,
    this.initialClientId,
    required this.onClientSelected,
  }) : super(key: key);

  @override
  State<ClientSelectorField> createState() => _ClientSelectorFieldState();
}

class _ClientSelectorFieldState extends State<ClientSelectorField> {
  Client? _selectedClient;

  @override
  void initState() {
    super.initState();
    // Load clients if not already loaded
    final clientBloc = context.read<ClientBloc>();
    if (clientBloc.state is! ClientLoaded) {
      clientBloc.add(LoadClients());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        List<Client> clients = [];

        if (state is ClientLoaded) {
          clients = state.clients;
          // Set initial client if provided
          if (widget.initialClientId != null && _selectedClient == null) {
            _selectedClient = clients
                .where((c) => c.id == widget.initialClientId)
                .firstOrNull;
          }
        }

        return DropdownButtonFormField<Client>(
          initialValue: _selectedClient,
          decoration: const InputDecoration(
            labelText: 'Клиент',
            helperText: 'Выберите клиента',
            prefixIcon: Icon(Icons.person),
          ),
          items: clients.map((client) {
            return DropdownMenuItem<Client>(
              value: client,
              child: Text(client.name),
            );
          }).toList(),
          onChanged: (client) {
            setState(() {
              _selectedClient = client;
            });
            widget.onClientSelected(client);
          },
          validator: (value) {
            if (value == null) {
              return 'Выберите клиента';
            }
            return null;
          },
        );
      },
    );
  }
}
