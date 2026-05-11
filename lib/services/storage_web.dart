import 'package:web/web.dart' as web;
import 'storage_interface.dart';

class WebStorage implements StorageInterface {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> saveData(String key, String data) async {
    try {
      web.window.localStorage.setItem(key, data);
    } catch (e) {
      web.window.sessionStorage.setItem(key, data);
    }
  }

  @override
  Future<String?> getData(String key) async {
    try {
      final data = web.window.localStorage.getItem(key);
      return data;
    } catch (e) {
      return web.window.sessionStorage.getItem(key);
    }
  }

  @override
  Future<void> deleteData(String key) async {
    try {
      web.window.localStorage.removeItem(key);
    } catch (e) {
      web.window.sessionStorage.removeItem(key);
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      web.window.localStorage.clear();
    } catch (e) {
      web.window.sessionStorage.clear();
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    try {
      final storage = web.window.localStorage;
      final keys = <String>[];
      for (int i = 0; i < storage.length; i++) {
        final key = storage.key(i);
        if (key != null) keys.add(key);
      }
      return keys;
    } catch (e) {
      final storage = web.window.sessionStorage;
      final keys = <String>[];
      for (int i = 0; i < storage.length; i++) {
        final key = storage.key(i);
        if (key != null) keys.add(key);
      }
      return keys;
    }
  }
}
