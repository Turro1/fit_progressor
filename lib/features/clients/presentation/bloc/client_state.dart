import 'package:equatable/equatable.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';

abstract class ClientState extends Equatable {
  const ClientState();

  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientLoaded extends ClientState {
  final List<Client> clients;
  final String? searchQuery;

  const ClientLoaded({required this.clients, this.searchQuery});

  @override
  List<Object?> get props => [clients, searchQuery];

  ClientLoaded copyWith({
    List<Client>? clients,
    String? searchQuery,
    List<String>? availableMakes,
    List<String>? availableModels,
  }) {
    return ClientLoaded(
      clients: clients ?? this.clients,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ClientError extends ClientState {
  final String message;

  const ClientError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ClientOperationSuccess extends ClientState {
  final String message;

  const ClientOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
