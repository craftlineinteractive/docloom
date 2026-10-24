// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: OcrSpikeRunner()));
}

class OcrSpikeRunner extends StatefulWidget {
  const OcrSpikeRunner({super.key});

  @override
  State<OcrSpikeRunner> createState() => _OcrSpikeRunnerState();
}

class _OcrSpikeRunnerState extends State<OcrSpikeRunner> {
  String status = 'Initializing...';
  String resultText = '';
  int durationMs = 0;

  @override
  void initState() {
    super.initState();
    _runOcr();
  }

  Future<void> _runOcr() async {
    try {
      setState(() => status = 'Loading fixture asset to device disk...');
      final byteData =
          await rootBundle.load('test/fixtures/ocr/english_page.jpg');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/english_page.jpg');
      await file.writeAsBytes(byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));

      setState(() => status = 'Running FlutterTesseractOcr.extractText...');
      final stopwatch = Stopwatch()..start();
      final text = await FlutterTesseractOcr.extractText(
        file.path,
        language: 'eng',
        args: {'preserve_interword_spaces': '1'},
      );
      stopwatch.stop();

      print('=== OCR SPIKE RESULT ===');
      print('TIME_MS: ${stopwatch.elapsedMilliseconds}');
      print('TEXT_START');
      print(text);
      print('TEXT_END');
      print('=== END OCR SPIKE RESULT ===');

      setState(() {
        status = 'Done';
        durationMs = stopwatch.elapsedMilliseconds;
        resultText = text;
      });
    } catch (e, st) {
      print('OCR SPIKE ERROR: $e');
      print(st);
      setState(() => status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Spike Runner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: $status',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (durationMs > 0)
                Text(
                  'Time: ${durationMs}ms',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Extracted Text:'),
              const SizedBox(height: 8),
              SelectableText(resultText),
            ],
          ),
        ),
      ),
    );
  }
}
