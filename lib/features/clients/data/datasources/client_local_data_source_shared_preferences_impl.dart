import 'dart:convert';

import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/features/clients/data/datasources/client_local_data_source.dart';
import 'package:fit_progressor/features/clients/data/models/client_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientLocalDataSourceSharedPreferencesImpl implements ClientLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CLIENTS_KEY = 'CACHED_CLIENTS';

  ClientLocalDataSourceSharedPreferencesImpl({required this.sharedPreferences});

  @override
  Future<void> deleteClient(String id) async{
    try{
      final clients = await getAllClients();
    clients.removeWhere((c) => c.id == id);
    await _saveClients(clients);
    }
    catch(e){
      throw CacheException(message: 'Failed to delete client from cache: $e');
    }
  }

  @override
  Future<List<ClientModel>> getAllClients() async
  {
    try{
        final jsonString = sharedPreferences.getString(CLIENTS_KEY);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => ClientModel.fromJson(json)).toList();
    }
    catch(e){
    throw CacheException(message: 'Failed to load clients from cache: $e');
    }
}


  @override
  Future<ClientModel> getClientById(String id) async {
    try{ 
        final clients = await getAllClients();
        return clients.where((client) => client.id == id).first;
    }
    catch(e){
        throw CacheException(message: 'Failed to load client from cache: $e');
    }
  }

  @override
  Future<ClientModel> saveClient(ClientModel client) async {
    try{
        final clients = await getAllClients();
        clients.add(client);
        await _saveClients(clients);
        return client;
    }
    catch(e){
        throw CacheException(message: 'Failed to save client to cache: $e');
    }
  }

  @override
  Future<List<ClientModel>> searchClients(String query) async {
  try
  {
    final clients = await getAllClients();
    final lowercaseQuery = query.toLowerCase();
    return clients.where((car) {
        return car.phone.toLowerCase().contains(lowercaseQuery) 
        || car.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  catch(e){
     throw CacheException(message: 'Failed to search clients in cache: $e');
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try{
      final clients = await getAllClients();
    final index = clients.indexWhere((c) => c.id == client.id);
    if (index == -1) {
      throw Exception('Car not found');
    }
    clients[index] = client;
    await _saveClients(clients);
    return client;
    }
    catch(e){
        throw CacheException(message: 'Failed to update client in cache: $e');
    }
  }

  Future<void> _saveClients(List<ClientModel> clients) async {
    final jsonList = clients.map((c) => c.toJson()).toList();
    await sharedPreferences.setString(CLIENTS_KEY, json.encode(jsonList));
  }
}