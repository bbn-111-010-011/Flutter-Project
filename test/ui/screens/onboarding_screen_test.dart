import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/ui/screens/onboarding_screen.dart';
import 'package:flutter_projet/providers/onboarding_provider.dart';
import 'package:flutter_projet/repositories/local_storage.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders title and continue button', (tester) async {
      final storage = MockLocalStorage();
      when(() => storage.getOnboardingSeen()).thenReturn(false);
      when(() => storage.setOnboardingSeen(any())).thenAnswer((_) async {});

      final provider = OnboardingProvider(storage, initiallySeen: false);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const OnboardingScreen(),
          ),
        ),
      );

      expect(find.textContaining('Bienvenue sur Marketplace'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);

      // Toggle checkbox should not crash
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      // We do not tap "Commencer" here to avoid depending on go_router in this widget test.
    });
  });
}
