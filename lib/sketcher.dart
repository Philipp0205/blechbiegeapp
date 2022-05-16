import 'dart:ui';

import 'package:flutter/material.dart';

import 'model/segment.dart';

class Sketcher extends CustomPainter {
  final List<Segment> lines;

  Sketcher({required this.lines});

  final PictureRecorder pictureRecorder = new PictureRecorder();
  late Canvas recordingCanvas;
  late Canvas canvas;

  String lastDrawnText = '';

  Segment selectedSegment =
      new Segment([Offset(0, 0), Offset(0, 0)], Colors.black, 5.0);

  @override
  void paint(Canvas canvas, Size size) {
    print('Sketcher segments: ${lines.length}');
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
          print('Drawing line: ${lines[i].path}');
          canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);

          if (lines[i].isSelected) {
            print('line is Selected');
            togglePointSelection(lines[i], canvas);
            toggleSegmentSelection(lines[i], canvas);
          }

          if (lines[i].selectedEdge != null) {
            if (lines[i].highlightPoints) {
              print('Sketcher segment: ${lines[i].path}');
              Offset offset = new Offset(lines[i].selectedEdge!.dx - 50,
                  lines[i].selectedEdge!.dy + 20);
              if (lastDrawnText != '') {
                drawText(
                    canvas, lastDrawnText, offset, Colors.yellow[50] as Color);
              }

              String text =
                  '${lines[i].selectedEdge!.dx.toStringAsFixed(2)} / ${lines[i].selectedEdge!.dy.toStringAsFixed(2)}';
              drawText(canvas, text, offset, Colors.yellow[50] as Color);
            }
          }
        }
      }
    }
  }

  void toggleSegmentSelection(Segment line, Canvas canvas) {
    print('toggleSegmentSelection');
    Paint paint = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    if (line.isSelected) {
      if (line.selectedEdge == line.path.first) {
        canvas.drawCircle(line.path.last, 10, paint);
        paint.color = Colors.red;
        canvas.drawCircle(line.path.first, 10, paint);
      } else {
        canvas.drawCircle(line.path.first, 10, paint);
        paint.color = Colors.red;
        canvas.drawCircle(line.path.last, 10, paint);
      }
    } else {
      paint.color = Colors.yellow[50] as Color;
      canvas.drawCircle(line.path.first, 10, paint);
      canvas.drawCircle(line.path.last, 10, paint);
    }
  }

  void togglePointSelection(Segment line, Canvas canvas) {
    print('togglePointSelection');
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    if (line.selectedEdge != null) {
      paint.color = Colors.yellow[50] as Color;
      canvas.drawCircle(line.selectedEdge!, 10, paint);
      paint.color = Colors.red;
      canvas.drawCircle(line.selectedEdge!, 10, paint);
    }
  }

  void drawText(Canvas canvas, String text, Offset offset, Color color) {
    print('drawText $text');

    TextStyle style = TextStyle(
        color: Colors.black,
        backgroundColor: Colors.green[100],
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: Colors.green,
        decorationThickness: 0.25);

    TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        // TextSpan could be whole TextSpans tree :)
        textAlign: TextAlign.start,
        //maxLines: 25, // In both TextPainter and Paragraph there is no option to define max height, but there is `maxLines`
        textDirection: TextDirection
            .ltr // It is necessary for some weird reason... IMO should be LTR for default since well-known international languages (english, esperanto) are written left to right.
        )
      ..layout(
          maxWidth:
              500); // TextPainter doesn't need to have specified width (would use infinity if not defined).
    // BTW: using the TextPainter you can check size the text take to be rendered (without `paint`ing it).
    textPainter.paint(canvas, offset);
  }

  void makeSegmentSelected(Segment line, Canvas canvas) {
    print('makeSegementSelected');
  }

  void unselectSegment(Segment line, Canvas canvas) {}

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }

  void getColorOfCoordinate() {}
}