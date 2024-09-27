import 'package:flutter/material.dart';

import '../models/wall.dart';

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ray Casting - Walls'),
      ),
      body: CustomPaint(
        painter: WallsPainter(),
        child: Container(),
      ),
    );
  }
}

class WallsPainter extends CustomPainter {
  final List<Wall> walls = [
    Wall(const Offset(100, 100), const Offset(300, 100)),
    Wall(const Offset(300, 100), const Offset(300, 300)),
    Wall(const Offset(300, 300), const Offset(100, 300)),
    Wall(const Offset(100, 300), const Offset(100, 100)),
    Wall(const Offset(600, 600), const Offset(650, 650)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var wall in walls) {
      canvas.drawLine(wall.start, wall.end, wallPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
