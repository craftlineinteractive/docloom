import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField renders label, hint and accepts input', (tester) async {
    final controller = TextEditingController();
    String changedValue = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            label: 'Document Name',
            hint: 'Enter document name',
            onChanged: (val) => changedValue = val,
          ),
        ),
      ),
    );

    expect(find.text('Document Name'), findsOneWidget);
    expect(find.text('Enter document name'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'My New Scan');
    await tester.pump();

    expect(controller.text, equals('My New Scan'));
    expect(changedValue, equals('My New Scan'));
  });

  testWidgets('AppTextField displays errorText when invalid', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppTextField(
            errorText: 'Name is required',
          ),
        ),
      ),
    );

    expect(find.text('Name is required'), findsOneWidget);
  });
}
