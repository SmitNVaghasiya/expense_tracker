import 'storage_interface.dart';
// Conditional import selects platform implementation at compile time
import 'storage_impl_mobile.dart'
    if (dart.library.html) 'storage_impl_web.dart';

class StorageService {
  static late final StorageInterface _storage;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _storage = createPlatformStorage();
    await _storage.initialize();
    _initialized = true;
  }

  static Future<void> saveData(String key, String data) async {
    await _storage.saveData(key, data);
  }

  static Future<String?> getData(String key) async {
    return await _storage.getData(key);
  }

  static Future<void> deleteData(String key) async {
    await _storage.deleteData(key);
  }

  static Future<void> clearAll() async {
    await _storage.clearAll();
  }

  static Future<List<String>> getAllKeys() async {
    return await _storage.getAllKeys();
  }
}
