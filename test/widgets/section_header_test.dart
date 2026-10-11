import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/section_header.dart';

void main() {
  testWidgets('SectionHeader displays title and count format', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SectionHeader(
            title: 'Folders',
            count: 3,
          ),
        ),
      ),
    );

    expect(find.text('Folders (3)'), findsOneWidget);
  });

  testWidgets('SectionHeader renders without count and with trailing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SectionHeader(
            title: 'Documents',
            trailing: Text('Trailing Action'),
          ),
        ),
      ),
    );

    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Trailing Action'), findsOneWidget);
  });
}
