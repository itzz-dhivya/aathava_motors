import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freelancing/core/localization/translations.dart';

void main() {
  testWidgets('AppTranslations and Text rendering smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(AppTranslations.get('app_title', locale: 'en')),
          ),
        ),
      ),
    );

    expect(find.text('AutoSpare Pro'), findsOneWidget);
  });
}
