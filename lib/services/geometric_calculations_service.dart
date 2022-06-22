import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math.dart';

import '../model/line.dart';
import '../model/segment_offset.dart';
import '../model/segment_widget/segment.dart';

/// All calculations involving points (offsets) in a the coordinate system of
/// the application.
class GeometricCalculationsService {
  /// Returns sorted Map according to distance of [offset] to each element
  /// in [offsets].
  Map<Offset, double> _getOffsetsByDistance(
      Offset offset, List<Offset> offsets) {
    Map<Offset, double> distances = {};
    offsets.forEach((currentOffset) {
      distances.addEntries(
          [MapEntry(currentOffset, (currentOffset - offset).distance)]);
    });

    var mapEntries = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    distances
      ..clear()
      ..addEntries(mapEntries);

    return distances;
  }

  /// Returns nearest nearest offsets of [offset] in [offsets].
  /// Number of nearest offsets is determined by [numberOfOffsets].
  List<Offset> getNNearestOffsets(
      Offset offset, List<Offset> offsets, int numberOfOffsets) {
    return _getOffsetsByDistance(offset, offsets)
        .keys
        .toList()
        .getRange(0, numberOfOffsets)
        .toList();
  }

  Offset _changeLengthOfOffset(Offset start, Offset end, double length) {
    double lengthAB = (start - end).distance;
    double x = end.dx + (end.dx - start.dx) / lengthAB * length;
    double y = end.dy + (end.dy - start.dy) / lengthAB * length;

    return new Offset(x, y);
  }

  /// Changes the  length of a segment consisting of two Offsets [start]  and
  /// [end] by given [length]. Can handle negative lengths!
  ///
  /// With [shortStart] and [shortEnd] it is possible to set the ends which
  /// should be shorted. It is possible to short only one end or both.
  ///
  /// Always two offsets are returned. Only one end got shorted one of the
  /// results will be  the same offset.
  List<Offset> changeLengthOfSegment(
      Offset start, Offset end, double length, bool shortStart, bool shortEnd) {
    List<Offset> result = [];

    Offset newStart = _changeLengthOfOffset(start, end, length);
    Offset newEnd = _changeLengthOfOffset(end, start, length);
    if (shortStart && shortEnd) {
      result.addAll([newStart, newEnd]);
    } else if (shortStart) {
      result.addAll([newStart, end]);
    } else {
      result.addAll([start, newEnd]);
    }
    return result;
  }

  Line changeLengthOfSegment2(
      Offset start, Offset end, double length, bool shortStart, bool shortEnd) {
    SegmentOffset newStart = new SegmentOffset(
        offset: _changeLengthOfOffset(start, end, length), isSelected: false);
    SegmentOffset newEnd = new SegmentOffset(
        offset: _changeLengthOfOffset(end, start, length), isSelected: false);

    Line result = Line(start: newStart, end: newEnd);
    if (shortStart) {
      result.copyWith(end: new SegmentOffset(offset: end, isSelected: false));
    } else if (shortEnd) {
      result.copyWith(
          start: new SegmentOffset(offset: start, isSelected: false));
    }
    return result;
  }

  /*
       Distance(point1, currPoint)
     + Distance(currPoint, point2)
    == Distance(point1, point2)

    https://stackoverflow.com/questions/11907947/how-to-check-if-a-point-lies-on-a-line-between-2-other-points/11912171#11912171
  */
  double getDistanceToSegment(DragDownDetails details, Segment segment) {
    Point currentPoint =
        new Point(details.globalPosition.dx, details.globalPosition.dy - 80);
    Point startPoint =
        new Point(segment.path.first.offset.dx, segment.path.first.offset.dy);
    Point endPoint =
        new Point(segment.path.last.offset.dx, segment.path.last.offset.dy);

    return startPoint.distanceTo(currentPoint) +
        currentPoint.distanceTo(endPoint) -
        startPoint.distanceTo(endPoint);
  }

  /// Given two offsets of a line starting is [offsetA] and ending is [offsetB]
  /// find out the mid-point of a line.
  Offset getMiddle(Offset offsetA, Offset offsetB) {
    double x = (offsetA.dx + offsetB.dx) / 2;
    double y = (offsetA.dy + offsetB.dy) / 2;

    return new Offset(x, y);
  }

  // section Angles & Radians

  /// Returns the angle between a [centre] offset and another [offset]
  ///
  /// Dot product u dot v = mag u * mag v * cos theta
  /// Therefore theta = cos -1 ((u dot v) / (mag u * mag v))
  /// Horizontal v = (1, 0)
  /// therefore theta = cos -1 (u.x / mag u)
  /// nb, there are 2 possible angles and if u.y is positive then angle is in first quadrant, negative then second
  ///
  /// https://stackoverflow.com/a/38024982/7127837
  double getAngle(Offset centre, Offset offset) {
    double x = offset.dx - centre.dx;
    double y = offset.dy - centre.dy;

    double magnitude = sqrt(x * x + y * y);
    double angle = 0;
    if (magnitude > 0) {
      angle = acos(x / magnitude);
    }

    angle = angle * 180 / pi;
    if (y < 0) {
      angle = 360 - angle;
    }

    return angle;
  }

  // (P1L1(x1, y1), P2L1(x2, y2) and P1L1(x1, y1), P2L3(x2, y3))
  double getInnerAngle(Line lineA, Line lineB) {
    // public static double angleBetween2Lines(Line2D line1, Line2D line2)
    // {
    //     double angle1 = Math.atan2(line1.getY1() - line1.getY2(),
    //                                line1.getX1() - line1.getX2());
    //     double angle2 = Math.atan2(line2.getY1() - line2.getY2(),
    //                                line2.getX1() - line2.getX2());
    //     return angle1-angle2;
    // }

    // double slope1 = (line1.getY1() - line1.getY2()) / (line1.getX1() - line1.getX2());
    //    double slope2 = (line2.getY1() - line2.getY2()) / (line2.getX1() - line2.getX2());

    double slopeA = (lineA.start.offset.dy - lineA.end.offset.dy) /
        (lineA.start.offset.dx - lineA.end.offset.dx);
    double slopeB = (lineB.start.offset.dy - lineB.end.offset.dy) /
        (lineB.start.offset.dx - lineB.end.offset.dx);
    print('slopeA $slopeA, sloeB $slopeB');

    double angle = atan((slopeA - slopeB) / (1 - (slopeA * slopeB)));
    print('angle $angle');

    // atan2(vector1.y - vector2.y, vector1.x - vector2.x)
    double angleA = atan2(lineA.end.offset.dx - lineA.start.offset.dx,
        lineA.end.offset.dy - lineA.start.offset.dy);

    double angleB = atan2(lineB.end.offset.dx - lineB.start.offset.dx,
        lineB.end.offset.dy - lineB.start.offset.dy);

    print('Inner angle: angleA: $angleA, angleB: $angleB');

    return (angleA - angleB).abs();
  }

  double getMagnitude(Offset centre, Offset offset) {
    double x = offset.dx - centre.dx;
    double y = offset.dy - centre.dy;

    return sqrt(x * x + y * y);
  }

  /// Determines the direction of an arc. Which means that if it is clockwise
  /// (true) or anti-clockwise (false).
  ///
  /// Three parts of the arcs are needed, the [start], [middle] and [end] Offset
  /// of the arc.
  ///
  /// https://stackoverflow.com/questions/33960924/is-arc-clockwise-or-counter-clockwise
  bool getDirection(Offset start, Offset end, Offset middle) {
    return ((end.dx - start.dx) * (middle.dy - start.dy) -
            (end.dy - start.dy) * (middle.dx - start.dx)) >
        0;
  }

  double degreesToRadians(double degrees) {
    return (degrees * pi) / 180;
  }

  /// If you are at point (x,y) and you want to move d unit in alpha
  /// angle (in radian), then formula for destination point will be:
  ///
  /// xx = x + (d * cos(alpha))
  /// yy = y + (d * sin(alpha))
  ///
  /// Angle to radian
  /// angle in radian = angle in degree * Pi / 180
  ///
  /// https://math.stackexchange.com/a/3534251/743682
  Offset calculatePointWithAngle(Offset centre, double length, double angle) {
    double radian = angle * pi / 180;

    double x = centre.dx + (length * cos(radian));
    double y = centre.dy + (length * sin(radian));

    return new Offset(x, y);
  }

  /// Changes the angle of one [Line] to another. The orientation of the first
  /// line stays the same but the second line changes.
  void _changeSegmentAngle2(Line lineA, Line lineB, double angle) {
    double angleA = getAngle(lineA.start.offset, lineB.end.offset);
    double angleB = getAngle(lineA.start.offset, lineB.end.offset);

    double currentAngle = getAngleBetweenTwoLines(angleA, angleB);
  }

  double getAngleBetweenTwoLines(double angleA, double angleB) {
    double angle;
    if (angleA > angleB) {
      angle = angleA - angleB;
      print('$angleA - $angleB = $angle');
    } else {
      angle = angleB - angleA;
      print('$angleB - $angleA = $angle');
    }

    print('angle: 180 - $angle = ${angle}');

    if (angle > 180) {
      angle = 360 - angle;
    }
    return angle;
  }

  Vector2 createVectorFromLines(Line lineA) {
    Offset a = new Offset(lineA.start.offset.dx, lineA.start.offset.dy);
    Offset b = new Offset(lineA.end.offset.dx, lineA.end.offset.dy);

    // Offset c = new Offset(lineB.start.offset.dx, lineB.start.offset.dy);
    // Offset d = new Offset(lineB.end.offset.dx, lineB.end.offset.dy);

    return new Vector2((a.dx - b.dx).abs(), (a.dy - b.dy).abs());
  }

  /// atan2(vector1.y - vector2.y, vector1.x - vector2.x)
  /// angle = arccos[(xa * xb + ya * yb) / (√(xa2 + ya2) * √(xb2 + yb2))]
  double getAngleFromVectors(Vector2 vector1, Vector2 vector2) {

    double angle = atan2(vector2.y, vector2.x) - atan2(vector1.y, vector1.x);

    if (angle > pi) {
      angle -= 2 * pi;
    } else if (angle <= -pi) {
      angle += 2 * pi;
    }

    return (angle * radians2Degrees).abs();
  }
}