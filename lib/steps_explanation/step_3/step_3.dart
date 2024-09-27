import 'dart:math';

import 'package:flutter/material.dart';

import '../models/wall.dart';

class Step3 extends StatefulWidget {
  const Step3({super.key});

  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  Offset origin = const Offset(0, 0);

  @override
  void initState() {
    const width = 400;
    const height = 400;

    origin = const Offset(width / 2, height / 2);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 3: Ray Casting with Collision'),
      ),
      body: GestureDetector(
        /// update the origin point when the user drag the screen
        /// to simulate the light source movement
        onPanUpdate: (details) {
          setState(() {
            origin += details.delta;
          });
        },

        onPanEnd: (details) {
          setState(() {
            origin += details.velocity.pixelsPerSecond / 10;
          });
        },

        // get the tap position
        onTapDown: (details) {
          setState(() {
            origin = details.localPosition;
          });
        },
        child: CustomPaint(
          painter: RayCastingWithWallsPainter(origin),
          child: Container(),
        ),
      ),
    );
  }
}

class RayCastingWithWallsPainter extends CustomPainter {
  final Offset _origin;

  RayCastingWithWallsPainter(Offset? origin)
      : _origin = origin ?? const Offset(0, 0);
  final List<Wall> walls = [
    Wall(const Offset(100, 100), const Offset(300, 100)),
    Wall(const Offset(300, 100), const Offset(300, 300)),
    Wall(const Offset(300, 300), const Offset(100, 300)),
    Wall(const Offset(100, 300), const Offset(100, 100)),
    Wall(const Offset(600, 600), const Offset(650, 650)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // sets the background color
    canvas.drawColor(Colors.black.withOpacity(0.9), BlendMode.src);

    // Origin point at the center
    final origin = _origin;

    // Paint for the rays
    final rayPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    // Draw rays with collision detection
    for (double angle = 0; angle < 360; angle += 1) {
      final radian = angle * (pi / 180);
      final rayDir = Offset(cos(radian), sin(radian));

      Offset? closestIntersection;
      double minDist = double.infinity;

      for (var wall in walls) {
        final intersection = getIntersection(origin, rayDir, wall);
        if (intersection != null) {
          final dist = (intersection - origin).distance;
          if (dist < minDist) {
            minDist = dist;
            closestIntersection = intersection;
          }
        }
      }
      final rayEnd = Offset(
        origin.dx + rayDir.dx * size.width * 2,
        origin.dy + rayDir.dy * size.height * 2,
      );
      if (closestIntersection != null) {
        canvas.drawLine(origin, closestIntersection, rayPaint);

        /// draw shadow
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..strokeWidth = 1;
        canvas.drawLine(closestIntersection, rayEnd, shadowPaint);
      } else {
        // Draw the ray to the edge of the canvas

        canvas.drawLine(origin, rayEnd, rayPaint);
      }
    }

    // Draw the walls
    final wallPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var wall in walls) {
      canvas.drawLine(wall.start, wall.end, wallPaint);
    }

    // Draw the origin point
    canvas.drawCircle(origin, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Offset? getIntersection(Offset origin, Offset dir, Wall wall) {
    final x1 = wall.start.dx;
    final y1 = wall.start.dy;
    final x2 = wall.end.dx;
    final y2 = wall.end.dy;

    final x3 = origin.dx;
    final y3 = origin.dy;
    final x4 = origin.dx + dir.dx * 1000;
    final y4 = origin.dy + dir.dy * 1000;

    final denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);

    if (denom == 0) {
      return null; // Lines are parallel
    }

    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    final u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom;

    if (t >= 0 && t <= 1 && u >= 0) {
      final intersectX = x1 + t * (x2 - x1);
      final intersectY = y1 + t * (y2 - y1);
      return Offset(intersectX, intersectY);
    }

    return null; // No valid intersection
  }
}
