import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'scanner_spike_runner.dart';

class ScannerSpikeScreen extends StatefulWidget {
  const ScannerSpikeScreen({super.key});

  @override
  State<ScannerSpikeScreen> createState() => _ScannerSpikeScreenState();
}

class _ScannerSpikeScreenState extends State<ScannerSpikeScreen> {
  bool _isRunning = false;
  final _results = <SpikeResult>[];
  double _meanIoU = 0.0, _worstIoU = 1.0, _avgMs = 0.0;
  String _worstFile = '', _status = 'Ready to run spike benchmark';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runBenchmark());
  }

  Future<void> _runBenchmark() async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _results.clear();
      _status = 'Running benchmark on 19 fixtures...';
    });

    double totalIoU = 0, worst = 1.0, totalMs = 0;
    String worstName = '';

    for (final name in ScannerSpikeRunner.fixtureNames) {
      Uint8List jpgBytes;
      String jsonStr;
      final localFile = File('test/fixtures/documents/$name.jpg');
      if (localFile.existsSync()) {
        jpgBytes = await localFile.readAsBytes();
        jsonStr = await File('test/fixtures/documents/$name.json').readAsString();
      } else {
        final b = await rootBundle.load('test/fixtures/documents/$name.jpg');
        jpgBytes = b.buffer.asUint8List();
        jsonStr = await rootBundle.loadString('test/fixtures/documents/$name.json');
      }

      final res = await ScannerSpikeRunner.evaluateFixture(name: name, jpgBytes: jpgBytes, jsonStr: jsonStr);
      _results.add(res);
      totalIoU += res.iou;
      totalMs += res.ms;
      if (res.iou < worst) {
        worst = res.iou;
        worstName = res.fileName;
      }
      setState(() {});
    }

    _status = 'Rendering filter contact sheets...';
    final appDir = await getApplicationDocumentsDirectory();
    final reportDir = Directory('${appDir.path}/filter_report');
    final contactFixtures = ['01_baseline', '04_tilted_page', '08_shadow_page', '10_dim_light', '12_patterned_desk'];
    for (final name in contactFixtures) {
      Uint8List jpgBytes;
      final localFile = File('test/fixtures/documents/$name.jpg');
      if (localFile.existsSync()) {
        jpgBytes = await localFile.readAsBytes();
      } else {
        final b = await rootBundle.load('test/fixtures/documents/$name.jpg');
        jpgBytes = b.buffer.asUint8List();
      }
      await ScannerSpikeRunner.renderFiltersForFixture(name: name, jpgBytes: jpgBytes, outDir: reportDir);
    }

    final mIoU = _results.isEmpty ? 0.0 : totalIoU / _results.length;
    final aMs = _results.isEmpty ? 0.0 : totalMs / _results.length;
    debugPrint('SPIKE_BENCHMARK_START');
    for (final r in _results) {
      debugPrint('SPIKE_ROW|${r.fileName}|${r.iou.toStringAsFixed(4)}|${r.ms.toStringAsFixed(1)}|${r.detected}');
    }
    debugPrint('SPIKE_SUMMARY|${mIoU.toStringAsFixed(4)}|$worstName|${worst.toStringAsFixed(4)}|${aMs.toStringAsFixed(1)}');
    debugPrint('SPIKE_BENCHMARK_END');

    setState(() {
      _isRunning = false;
      _meanIoU = mIoU;
      _worstIoU = worst;
      _worstFile = worstName;
      _avgMs = aMs;
      _status = 'Completed. Mean IoU: ${_meanIoU.toStringAsFixed(4)}, Avg: ${_avgMs.toStringAsFixed(1)} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scanner Spike (/dev/scanner-spike)'),
        backgroundColor: AppColors.surface,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _isRunning ? null : _runBenchmark)],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.primaryTint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text('Mean IoU: ${_meanIoU.toStringAsFixed(4)} | Worst: $_worstFile (${_worstIoU.toStringAsFixed(4)}) | Avg: ${_avgMs.toStringAsFixed(1)} ms'),
              ],
            ),
          ),
          if (_isRunning) const LinearProgressIndicator(),
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final r = _results[i];
                return ListTile(
                  dense: true,
                  title: Text(r.fileName),
                  subtitle: Text('Detection: ${r.ms.toStringAsFixed(1)} ms'),
                  trailing: Text(
                    r.detected ? 'IoU: ${r.iou.toStringAsFixed(4)}' : 'NULL (0.0)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: r.iou >= 0.85 ? AppColors.autoDetectGreen : (r.detected ? AppColors.folderOrange : AppColors.danger),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
