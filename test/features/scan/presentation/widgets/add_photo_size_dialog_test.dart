import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/photo_size.dart';
import 'package:docloom/features/scan/presentation/widgets/add_photo_size_dialog.dart';

void main() {
  testWidgets('AddPhotoSizeDialog returns custom PhotoSize on valid input', (tester) async {
    PhotoSize? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await AddPhotoSizeDialog.show(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(AddPhotoSizeDialog), findsOneWidget);
    expect(find.text('Add Custom Size'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.width, equals(35.0));
    expect(result!.height, equals(45.0));
    expect(result!.unit, equals(PhotoUnit.mm));
    expect(result!.dpi, equals(300));
  });

  testWidgets('AddPhotoSizeDialog displays error on invalid dimensions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => AddPhotoSizeDialog.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final widthField = find.widgetWithText(TextField, 'Width');
    await tester.enterText(widthField, '-5');

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Enter valid dimensions (1-10000)'), findsOneWidget);
  });
}
