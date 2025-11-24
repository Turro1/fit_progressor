import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';

abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object?> get props => [];
}

class LoadClients extends ClientEvent {}

class AddClientEvent extends ClientEvent {
  final String name;
  final String phone;

  const AddClientEvent({
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, phone];
}

class UpdateClientEvent extends ClientEvent {
  final Client client;

  const UpdateClientEvent({required this.client});

  @override
  List<Object?> get props => [client];
}

class DeleteClientEvent extends ClientEvent {
  final String clientId;

  const DeleteClientEvent({required this.clientId});

  @override
  List<Object?> get props => [clientId];
}

class SearchClientsEvent extends ClientEvent {
  final String query;

  const SearchClientsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}