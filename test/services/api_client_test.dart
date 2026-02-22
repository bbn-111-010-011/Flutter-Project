import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/services/api_client.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('ApiClient', () {
    late MockHttpClient httpClient;
    late ApiClient api;

    setUp(() {
      httpClient = MockHttpClient();
      api = ApiClient(
        tokenProvider: () async => 'abc123',
        httpClient: httpClient,
      );
    });

    test('GET returns List when server responds with 200 and a JSON array', () async {
      when(() => httpClient.get(any(that: isA<Uri>()), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode([{'id': 1}, {'id': 2}]), 200));

      final data = await api.get('/products');

      expect(data, isA<List>());
      expect((data as List).length, 2);
      verify(() => httpClient.get(any(that: isA<Uri>()), headers: any(named: 'headers'))).called(1);
    });

    test('GET returns Map when server responds with 200 and a JSON map', () async {
      when(() => httpClient.get(any(that: isA<Uri>()), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'hello': 'world'}), 200));

      final data = await api.get('/status');

      expect(data, isA<Map>());
      expect((data as Map)['hello'], 'world');
    });

    test('POST attaches Authorization header when auth=true', () async {
      Map<String, String>? capturedHeaders;

      when(() => httpClient.post(any(that: isA<Uri>()), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((invocation) async {
        capturedHeaders = invocation.namedArguments[#headers] as Map<String, String>?;
        return http.Response(jsonEncode({'ok': true}), 200);
      });

      final res = await api.post('/secure', body: {'a': 1}, auth: true);
      expect((res as Map)['ok'], true);
      expect(capturedHeaders, isNotNull);
      expect(capturedHeaders!['Authorization'], startsWith('Bearer '));
    });

    test('throws ApiException on non-2xx with message extracted', () async {
      when(() => httpClient.get(any(that: isA<Uri>()), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'message': 'Invalid token'}), 401));

      expect(
        () => api.get('/auth/profile', auth: true),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
      );
    });
  });
}
