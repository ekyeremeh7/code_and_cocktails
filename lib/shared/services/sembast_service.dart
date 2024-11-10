import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class SembastService {
  static final SembastService _instance = SembastService._internal();
  factory SembastService() => _instance;

  Database? _database;
  final _userStore = intMapStoreFactory.store('userStore');

  SembastService._internal();

  Future<void> init() async {
    try {
      if (_database != null) return;
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = '${dir.path}/app_data.db';
      _database = await databaseFactoryIo.openDatabase(dbPath);
      debugPrint("Sembast service started!...");
    } catch (e) {
      debugPrint("Sembast init error ${e.toString()}");
    }
  }

  Future<void> clearStore(StoreRef<int, Map<String, dynamic>> store) async {
    await store.delete(_database!);
  }

  Future<void> saveUserResponse(Map<String, dynamic> userResponse) async {
    await clearStore(_userStore);
    await _userStore.add(_database!, userResponse);
    debugPrint("Saving and/or Refreshing...");
  }

  Future<Map<String, dynamic>?> getUserResponse() async {
    final records = await _userStore.find(_database!);
    if (records.isNotEmpty) {
      return records.first.value as Map<String, dynamic>;
    }
    return {};
  }

  clearUserStore() async {
    try {
      await clearStore(_userStore);
      debugPrint("Successfully cleared store");
    } catch (e) {
      debugPrint("err clearing store ${e.toString()}");
    }
  }
}
