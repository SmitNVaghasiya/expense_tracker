import 'storage_interface.dart';
import 'storage_web.dart';

StorageInterface createPlatformStorage() {
  return WebStorage();
}


