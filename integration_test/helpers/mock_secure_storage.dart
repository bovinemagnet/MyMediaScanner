// Mock FlutterSecureStorage for integration tests.
//
// Author: Paul Snow
// Since: 0.0.0

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

MockFlutterSecureStorage createMockSecureStorage() {
  final storage = MockFlutterSecureStorage();

  when(() => storage.read(key: any(named: 'key')))
      .thenAnswer((_) async => null);
  when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});
  when(() => storage.delete(key: any(named: 'key')))
      .thenAnswer((_) async {});
  when(() => storage.readAll()).thenAnswer((_) async => {});

  return storage;
}
