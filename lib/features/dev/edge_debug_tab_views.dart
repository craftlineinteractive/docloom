import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../scan/data/edge_detector_evaluator.dart';
import '../scan/domain/quad.dart';

class CandidateListView extends StatelessWidget {
  const CandidateListView({super.key, required this.candidates});
  final List<CandidateQuad> candidates;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const Center(child: Text('No candidate contours evaluated', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: candidates.length,
      separatorBuilder: (_, _) => const Divider(color: AppColors.divider),
      itemBuilder: (context, i) {
        final c = candidates[i];
        final isAcc = c.isAccepted;
        return ListTile(
          dense: true,
          leading: Icon(
            isAcc ? Icons.check_circle : Icons.cancel,
            color: isAcc ? AppColors.folderGreen : AppColors.danger,
          ),
          title: Text(
            '#$i Score: ${c.score.toStringAsFixed(4)} (${(c.areaRatio * 100).toStringAsFixed(1)}% area)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          subtitle: Text(
            isAcc
                ? 'Rect: ${c.rectScore.toStringAsFixed(2)} | Ang: ${c.angleScore.toStringAsFixed(2)} | Edge: ${c.edgeSupport.toStringAsFixed(2)}'
                : 'Rejected: ${c.rejectionReason ?? "unknown"}',
            style: TextStyle(
              color: isAcc ? AppColors.textSecondary : AppColors.danger,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}

class FinalQuadOverlayView extends StatelessWidget {
  const FinalQuadOverlayView({super.key, required this.sourceBytes, required this.quad});
  final Uint8List? sourceBytes;
  final Quad? quad;

  @override
  Widget build(BuildContext context) {
    if (sourceBytes == null || sourceBytes!.isEmpty) {
      return const Center(child: Text('No source image', style: TextStyle(color: AppColors.textSecondary)));
    }
    return Center(
      child: Stack(
        fit: StackFit.loose,
        children: [
          Image.memory(sourceBytes!),
          if (quad != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _DebugQuadPainter(quad!),
              ),
            ),
        ],
      ),
    );
  }
}

class _DebugQuadPainter extends CustomPainter {
  const _DebugQuadPainter(this.quad);
  final Quad quad;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final p = Path()
      ..moveTo(quad.tl.dx * size.width, quad.tl.dy * size.height)
      ..lineTo(quad.tr.dx * size.width, quad.tr.dy * size.height)
      ..lineTo(quad.br.dx * size.width, quad.br.dy * size.height)
      ..lineTo(quad.bl.dx * size.width, quad.bl.dy * size.height)
      ..close();

    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(_DebugQuadPainter oldDelegate) => oldDelegate.quad != quad;
}
