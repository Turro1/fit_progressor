
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/clients/domain/usecases/add_client.dart';
import 'package:fit_progressor/features/clients/domain/usecases/delete_client.dart';
import 'package:fit_progressor/features/clients/domain/usecases/get_clients.dart';
import 'package:fit_progressor/features/clients/domain/usecases/search_clients.dart';
import 'package:fit_progressor/features/clients/domain/usecases/update_client.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_event.dart';
import 'package:fit_progressor/features/clients/presentation/bloc/client_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final GetClients getClients;
  final AddClient addClient;
  final UpdateClient updateClient;
  final DeleteClient deleteClient;
  final SearchClients searchClients;

  ClientBloc({
    required this.getClients,
    required this.addClient,
    required this.updateClient,
    required this.deleteClient,
    required this.searchClients,
  }) : super(ClientInitial()) {
    on<LoadClients>(_onLoadClients);
    on<AddClientEvent>(_onAddClient);
    on<UpdateClientEvent>(_onUpdateClient);
    on<DeleteClientEvent>(_onDeleteClient);
    on<SearchClientsEvent>(_onSearchClients);
  }

  Future<void> _onLoadClients(
    LoadClients event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    final result = await getClients(NoParams());
    result.fold(
      (failure) => emit(const ClientError(message: 'Не удалось загрузить автомобили')),
      (clients) => emit(ClientLoaded(clients: clients)),
    );
  }

  Future<void> _onAddClient(
    AddClientEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    final params = AddClientParams(
      phone: event.phone,
      name: event.name,
    );
    final result = await addClient(params);
    
    await result.fold(
      (failure) async {
        emit(const ClientError(message: 'Не удалось добавить автомобиль'));
      },
      (client) async {
        emit(const ClientOperationSuccess(message: 'Автомобиль добавлен'));
        add(LoadClients());
      },
    );
  }

  Future<void> _onUpdateClient(
    UpdateClientEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    final result = await updateClient(event.client);
    
    await result.fold(
      (failure) async {
        emit(const ClientError(message: 'Не удалось обновить автомобиль'));
      },
      (client) async {
        emit(const ClientOperationSuccess(message: 'Автомобиль обновлен'));
        add(LoadClients());
      },
    );
  }

  Future<void> _onDeleteClient(
    DeleteClientEvent event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    final result = await deleteClient(event.clientId);
    
    await result.fold(
      (failure) async {
        emit(const ClientError(message: 'Не удалось удалить автомобиль'));
      },
      (_) async {
        emit(const ClientOperationSuccess(message: 'Автомобиль удален'));
        add(LoadClients());
      },
    );
  }

  Future<void> _onSearchClients(
    SearchClientsEvent event,
    Emitter<ClientState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadClients());
      return;
    }

    emit(ClientLoading());
    final result = await searchClients(event.query);
    result.fold(
      (failure) => emit(const ClientError(message: 'Ошибка поиска')),
      (clients) => emit(ClientLoaded(clients: clients, searchQuery: event.query)),
    );
  }
}