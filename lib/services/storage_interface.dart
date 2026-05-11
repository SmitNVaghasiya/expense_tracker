abstract class StorageInterface {
  Future<void> initialize();
  Future<void> saveData(String key, String data);
  Future<String?> getData(String key);
  Future<void> deleteData(String key);
  Future<void> clearAll();
  Future<List<String>> getAllKeys();
}
