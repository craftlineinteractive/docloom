import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/app/app.dart';

void main() {
  testWidgets('DocLoomApp boots and displays docLoom in app bar', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DocLoomApp()));
    await tester.pumpAndSettle();

    expect(find.text('docLoom'), findsOneWidget);
    expect(find.text('Folders (3)'), findsOneWidget);
    expect(find.text('Documents (4)'), findsOneWidget);
  });
}
