import 'dart:ui';

import 'package:flutter/material.dart';

import 'draw_line.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;

  Sketcher({required this.lines});

  final PictureRecorder pictureRecorder = new PictureRecorder();
  late Canvas recordingCanvas;
  late Canvas canvas;

  @override
  void paint(Canvas canvas, Size size) {
    canvas = canvas;
    recordingCanvas = new Canvas(pictureRecorder);

    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
          paint.color = lines[i].color;
          paint.strokeWidth = lines[i].width;
          canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);

          // recordingCanvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
        }
      }
    }
    // pictureRecorder.endRecording();
  }


  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }

  void getColorOfCoordinate() {}
}
