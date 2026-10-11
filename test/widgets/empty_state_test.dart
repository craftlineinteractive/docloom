import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState renders title, body, and action button fires', (tester) async {
    bool actionFired = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: EmptyState(
            icon: LucideIcons.fileText,
            title: 'No Documents',
            body: 'Scan or import your first file.',
            actionLabel: 'Scan Now',
            onAction: () => actionFired = true,
          ),
        ),
      ),
    );

    expect(find.text('No Documents'), findsOneWidget);
    expect(find.text('Scan or import your first file.'), findsOneWidget);
    expect(find.text('Scan Now'), findsOneWidget);

    await tester.tap(find.text('Scan Now'));
    await tester.pump();
    expect(actionFired, isTrue);
  });
}
