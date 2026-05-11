import 'package:spendwise/services/database_service.dart';

import 'package:flutter/foundation.dart';

void main() async {
  debugPrint('Resetting database...');
  await DatabaseService.clearAllData();
  debugPrint('Database reset complete!');
  debugPrint(
    'You can now run: flutter test test/comprehensive_functionality_test.dart',
  );
}
