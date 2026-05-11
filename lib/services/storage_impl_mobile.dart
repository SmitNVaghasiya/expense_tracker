import 'storage_interface.dart';
import 'storage_mobile.dart';

StorageInterface createPlatformStorage() {
  return MobileStorage();
}


