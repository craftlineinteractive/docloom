import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toast.dart';
import '../scan/data/edge_detector_debug_trace.dart';
import '../scan/data/opencv_edge_detector.dart';
import '../scan/domain/quad.dart';
import 'edge_debug_tab_views.dart';

class EdgeDebugScreen extends StatefulWidget {
  const EdgeDebugScreen({super.key, this.initialImagePath});
  final String? initialImagePath;

  @override
  State<EdgeDebugScreen> createState() => _EdgeDebugScreenState();
}

class _EdgeDebugScreenState extends State<EdgeDebugScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _detector = OpencvEdgeDetector();
  EdgeDetectionDebugTrace? _trace;
  Quad? _finalQuad;
  bool _isLoading = false;
  String _currentPath = 'test/fixtures/documents/01_baseline.jpg';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    if (widget.initialImagePath != null) _currentPath = widget.initialImagePath!;
    _runDetection();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _runDetection() async {
    if (!File(_currentPath).existsSync()) return;
    setState(() => _isLoading = true);
    final (quad, trace) = await _detector.detectFromFileWithTrace(_currentPath);
    if (mounted) setState(() { _finalQuad = quad; _trace = trace; _isLoading = false; });
  }

  Future<void> _exportDebugPngs() async {
    if (_trace == null) return;
    final outDir = Directory('documents/debug');
    await _trace!.writeToDirectory(outDir.path);
    if (mounted) showAppToastGlobal('Exported debug images to documents/debug');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edge Detection Debugger', style: TextStyle(fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Gray'), Tab(text: 'Blurred'), Tab(text: 'Edges'),
            Tab(text: 'Mask'), Tab(text: 'Candidates'), Tab(text: 'Final Quad'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export PNGs to documents/debug',
            icon: const Icon(Icons.download),
            onPressed: _trace != null ? _exportDebugPngs : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trace == null
              ? const Center(child: Text('No trace available', style: TextStyle(color: AppColors.textSecondary)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    Center(child: Image.memory(_trace!.grayBytes)),
                    Center(child: Image.memory(_trace!.blurredBytes)),
                    Center(child: Image.memory(_trace!.edgesBytes)),
                    Center(child: Image.memory(_trace!.maskBytes)),
                    CandidateListView(candidates: _trace!.candidates),
                    FinalQuadOverlayView(sourceBytes: _trace!.sourceBytes, quad: _finalQuad),
                  ],
                ),
    );
  }
}
