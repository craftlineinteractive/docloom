import 'dart:typed_data';
import 'dart:ui' as ui;

Future<Uint8List> generatePagePng({
  required String label,
  required ui.Color headerColor,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 600, 800));

  final bgPaint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
  canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 600, 800), bgPaint);

  final headerPaint = ui.Paint()..color = headerColor;
  canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 600, 160), headerPaint);

  final pb = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      fontSize: 26,
      fontWeight: ui.FontWeight.bold,
    ),
  )
    ..pushStyle(ui.TextStyle(color: const ui.Color(0xFFFFFFFF)))
    ..addText(label);
  final paragraph = pb.build()..layout(const ui.ParagraphConstraints(width: 560));
  canvas.drawParagraph(paragraph, const ui.Offset(20, 60));

  final picture = recorder.endRecording();
  final image = await picture.toImage(600, 800);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
