import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/features/scan/domain/signature.dart';
import 'package:docloom/features/scan/domain/signature_repository.dart';
import 'package:docloom/features/scan/presentation/signature_preview_screen.dart';

class _FakeSignatureRepo implements SignatureRepository {
  final List<Signature> items = [];
  @override
  Future<void> add(Signature signature) async => items.add(signature);
  @override
  Future<List<Signature>> list() async => List.unmodifiable(items);
  @override
  Future<void> delete(String id) async => items.removeWhere((s) => s.id == id);
}

void main() {
  late Directory tempDir;
  late File samplePng;
  late _FakeSignatureRepo fakeRepo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sig_screen_test_');
    samplePng = File('${tempDir.path}/sample.png');
    await samplePng.writeAsBytes(List.filled(100, 0));
    fakeRepo = _FakeSignatureRepo();
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        signatureRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        home: SignaturePreviewScreen(processedPngPath: samplePng.path),
      ),
    );
  }

  testWidgets('renders preview header, image, and action buttons', (tester) async {
    await tester.pumpWidget(buildScreen());
    expect(find.text('Signature Preview'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);
    expect(find.text('Save Signature'), findsOneWidget);
  });

  testWidgets('tapping Retake pops the screen with false', (tester) async {
    bool? popResult;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          signatureRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                popResult = await SignaturePreviewScreen.push(context, samplePng.path);
              },
              child: const Text('Launch'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Launch'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retake'));
    await tester.pumpAndSettle();

    expect(popResult, isFalse);
  });
}
