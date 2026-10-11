import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/settings_row.dart';

void main() {
  testWidgets('SettingsRow.nav fires onTap when tapped', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SettingsRow.nav(
            title: 'Account',
            subtitle: 'Manage profile',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Manage profile'), findsOneWidget);
    await tester.tap(find.text('Account'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('SettingsRow.value shows value text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SettingsRow.value(
            title: 'Language',
            value: 'English',
            subtitle: 'Select app language',
          ),
        ),
      ),
    );

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('SettingsRow.toggle switch changes and fires onChanged', (tester) async {
    bool toggleVal = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SettingsRow.toggle(
                title: 'Notifications',
                value: toggleVal,
                onChanged: (val) => setState(() => toggleVal = val),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Notifications'), findsOneWidget);
    final switchFinder = find.byType(Switch);
    expect(tester.widget<Switch>(switchFinder).value, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(toggleVal, isTrue);
    expect(tester.widget<Switch>(switchFinder).value, isTrue);
  });

  testWidgets('SettingsRow disabled does not fire callback', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SettingsRow.nav(
            title: 'Disabled Option',
            enabled: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Disabled Option'));
    await tester.pump();
    expect(tapped, isFalse);
  });
}
