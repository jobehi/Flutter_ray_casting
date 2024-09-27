import 'dart:math';

import 'package:flutter/material.dart';

class Step1 extends StatefulWidget {
  const Step1({super.key});

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  Offset origin = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    origin = Offset(width / 2, height / 2);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ray Casting - drawing rays'),
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

        child: SizedBox(
          width: 500,
          height: 500,
          child: CustomPaint(
            painter: RayCastingPainter(origin),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class RayCastingPainter extends CustomPainter {
  final Offset _origin;

  RayCastingPainter(Offset? origin) : _origin = origin ?? const Offset(0, 0);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // Define the origin point (e.g., light source or camera)
    final origin = _origin;
    const maxRayLength = 1000;

    // Paint object for rays
    final rayPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    // Draw rays in multiple directions
    for (double angle = 0; angle < 360; angle += 5) {
      final radian = angle * (pi / 180);
      final rayEnd = Offset(
        origin.dx + maxRayLength * cos(radian),
        origin.dy + maxRayLength * sin(radian),
      );
      canvas.drawLine(origin, rayEnd, rayPaint);
    }

    // Draw a circle to represent the light source
    canvas.drawCircle(origin, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
