import 'dart:convert';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/features/clients/data/datasources/client_local_data_source.dart';
import 'package:fit_progressor/features/clients/data/models/client_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class ClientLocalDataSourceSharedPreferencesImpl
    implements ClientLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String clientsKey = 'cachedClients';

  ClientLocalDataSourceSharedPreferencesImpl({required this.sharedPreferences});

  @override
  Future<void> deleteClient(String id) async {
    try {
      final clients = await getAllClients();
      clients.removeWhere((c) => c.id == id);
      await _saveClients(clients);
    } catch (e) {
      debugPrint('DEBUG: Error deleting client: $e'); // Added debugPrint
      throw CacheException(message: 'Failed to delete client from cache: $e');
    }
  }

  @override
  Future<List<ClientModel>> getAllClients() async {
    try {
      final jsonString = sharedPreferences.getString(clientsKey);
      debugPrint(
        'DEBUG: getAllClients - Retrieved jsonString: $jsonString',
      ); // Added debugPrint
      if (jsonString == null) {
        debugPrint(
          'DEBUG: getAllClients - No cached clients, returning empty list.',
        ); // Added debugPrint
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      debugPrint(
        'DEBUG: getAllClients - Decoded JSON list: ${jsonList.length} clients.',
      ); // Added debugPrint
      return jsonList.map((json) => ClientModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint(
        'DEBUG: Error loading clients from cache: $e',
      ); // Added debugPrint
      throw CacheException(message: 'Failed to load clients from cache: $e');
    }
  }

  @override
  Future<ClientModel> getClientById(String id) async {
    try {
      final clients = await getAllClients();
      return clients.where((client) => client.id == id).first;
    } catch (e) {
      debugPrint(
        'DEBUG: Error loading client by ID from cache: $e',
      ); // Added debugPrint
      throw CacheException(message: 'Failed to load client from cache: $e');
    }
  }

  @override
  Future<ClientModel> saveClient(ClientModel client) async {
    try {
      debugPrint(
        'DEBUG: saveClient - Attempting to save client: ${client.id}',
      ); // Added debugPrint
      final clients = await getAllClients();
      debugPrint(
        'DEBUG: saveClient - Clients before adding: ${clients.length}',
      ); // Added debugPrint
      clients.add(client);
      debugPrint(
        'DEBUG: saveClient - Clients after adding: ${clients.length}',
      ); // Added debugPrint
      await _saveClients(clients);
      debugPrint(
        'DEBUG: saveClient - Client saved successfully: ${client.id}',
      ); // Added debugPrint
      return client;
    } catch (e) {
      debugPrint('DEBUG: Error saving client to cache: $e'); // Added debugPrint
      throw CacheException(message: 'Failed to save client to cache: $e');
    }
  }

  @override
  Future<List<ClientModel>> searchClients(String query) async {
    try {
      final clients = await getAllClients();
      final lowercaseQuery = query.toLowerCase();
      return clients.where((car) {
        return car.phone.toLowerCase().contains(lowercaseQuery) ||
            car.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      debugPrint(
        'DEBUG: Error searching clients in cache: $e',
      ); // Added debugPrint
      throw CacheException(message: 'Failed to search clients in cache: $e');
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final clients = await getAllClients();
      final index = clients.indexWhere((c) => c.id == client.id);
      if (index == -1) {
        throw Exception('Car not found');
      }
      clients[index] = client;
      await _saveClients(clients);
      return client;
    } catch (e) {
      debugPrint(
        'DEBUG: Error updating client in cache: $e',
      ); // Added debugPrint
      throw CacheException(message: 'Failed to update client in cache: $e');
    }
  }

  Future<void> _saveClients(List<ClientModel> clients) async {
    debugPrint(
      'DEBUG: _saveClients - Saving ${clients.length} clients.',
    ); // Added debugPrint
    final jsonList = clients.map((c) => c.toJson()).toList();
    final success = await sharedPreferences.setString(
      clientsKey,
      json.encode(jsonList),
    );
    debugPrint(
      'DEBUG: _saveClients - setString successful: $success',
    ); // Added debugPrint
    if (!success) {
      debugPrint(
        'DEBUG: _saveClients - Failed to save clients to SharedPreferences.',
      );
    }
  }
}
