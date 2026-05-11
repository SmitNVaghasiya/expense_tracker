import 'package:shared_preferences/shared_preferences.dart';
import 'storage_interface.dart';

class MobileStorage implements StorageInterface {
  late SharedPreferences _prefs;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveData(String key, String data) async {
    await _prefs.setString(key, data);
  }

  @override
  Future<String?> getData(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> deleteData(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  @override
  Future<List<String>> getAllKeys() async {
    return _prefs.getKeys().toList();
  }
}
