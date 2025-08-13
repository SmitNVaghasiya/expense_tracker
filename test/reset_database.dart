import 'package:spendwise/services/database_service.dart';

void main() async {
  print('Resetting database...');
  await DatabaseService.clearAllData();
  print('Database reset complete!');
  print(
    'You can now run: flutter test test/comprehensive_functionality_test.dart',
  );
}
