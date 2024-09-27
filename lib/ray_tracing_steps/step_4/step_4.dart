import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Step4 extends StatefulWidget {
  const Step4({super.key});

  @override
  State<Step4> createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  final FocusNode _focusNode = FocusNode();

  List<List<int>> map = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
  ];

  Offset playerPosition = const Offset(64 * 2, 64 * 2);
  double playerAngle = 0;
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RayCasting -  Players enters the map'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event.logicalKey == LogicalKeyboardKey.keyA) {
            setState(() {
              playerAngle -= 0.1;
            });
          }
          if (event.logicalKey == LogicalKeyboardKey.keyE) {
            setState(() {
              playerAngle += 0.1;
            });
          }

          if (event.logicalKey == LogicalKeyboardKey.keyZ) {
            setState(() {
              playerPosition += Offset(
                cos(playerAngle) * 5,
                sin(playerAngle) * 5,
              );
            });
          }

          if (event.logicalKey == LogicalKeyboardKey.keyS) {
            setState(() {
              playerPosition -= Offset(
                cos(playerAngle) * 5,
                sin(playerAngle) * 5,
              );
            });
          }

          if (event.logicalKey == LogicalKeyboardKey.keyQ) {
            setState(() {
              playerPosition += Offset(
                cos(playerAngle + pi / 2) * 5,
                sin(playerAngle + pi / 2) * 5,
              );
            });
          }

          if (event.logicalKey == LogicalKeyboardKey.keyD) {
            setState(() {
              playerPosition -= Offset(
                cos(playerAngle + pi / 2) * 5,
                sin(playerAngle + pi / 2) * 5,
              );
            });
          }
        },
        child: GestureDetector(
          onTapDown: (details) {
            if (isEditMode) {
              final cellSize =
                  MediaQuery.of(context).size.width / map[0].length;
              final x = (details.localPosition.dx / cellSize).floor();
              final y = (details.localPosition.dy / cellSize).floor();

              setState(() {
                map[y][x] = map[y][x] == 1 ? 0 : 1;
              });
              return;
            }
            setState(() {
              playerPosition = details.localPosition;
            });
          },

          /// drag a wall
          onPanUpdate: (details) {
            if (isEditMode) {
              final cellSize =
                  MediaQuery.of(context).size.width / map[0].length;
              final x = (details.localPosition.dx / cellSize).floor();
              final y = (details.localPosition.dy / cellSize).floor();

              setState(() {
                map[y][x] = 1;
              });
              return;
            }
            setState(() {
              playerPosition = details.localPosition;
            });
          },

          child: CustomPaint(
            painter: MapPainter(
                map: map,
                playerPosition: playerPosition,
                playerAngle: playerAngle),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final List<List<int>> map;
  final Offset playerPosition;
  final double playerAngle;

  MapPainter(
      {required this.map,
      required this.playerPosition,
      required this.playerAngle});
  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / map[0].length;
    final wallPaint = Paint()..color = Colors.orange;
    final emptyPaint = Paint()..color = Colors.black;

    // Draw the map
    for (int y = 0; y < map.length; y++) {
      for (int x = 0; x < map[0].length; x++) {
        final rect = Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize,
        );
        canvas.drawRect(
          rect,
          map[y][x] == 1 ? wallPaint : emptyPaint,
        );
      }
    }

    // Draw the player
    canvas.drawCircle(playerPosition, 5, Paint()..color = Colors.blue);

    // Cast rays
    const numRays = 20;
    const fov = pi / 3; // 60 degrees field of view
    final startAngle = playerAngle - fov / 2;

    for (int i = 0; i < numRays; i++) {
      final rayAngle = startAngle + (i * fov) / numRays;
      castRay(canvas, playerPosition, rayAngle, cellSize);
    }
  }

  void castRay(Canvas canvas, Offset position, double angle, double cellSize) {
    double sinAngle = sin(angle);
    double cosAngle = cos(angle);

    double distance = 0;
    bool hitWall = false;

    while (!hitWall && distance < 1000) {
      distance += 1;

      int testX = ((position.dx + cosAngle * distance) / cellSize).floor();
      int testY = ((position.dy + sinAngle * distance) / cellSize).floor();

      // Check if ray is outside map bounds
      if (testX < 0 ||
          testX >= map[0].length ||
          testY < 0 ||
          testY >= map.length) {
        hitWall = true;
        distance = 1000;
      } else if (map[testY][testX] == 1) {
        /// draw a text to show the distance over the ray, rotate the text to match the ray angle
        /// and draw it on top of the ray not on the wall to avoid overlapping

        final textPainter = TextPainter(
          text: TextSpan(
            text: distance.toStringAsFixed(0),
            style: const TextStyle(color: Colors.red),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final textOffset = Offset(
          position.dx + cosAngle * distance / 2,
          position.dy + sinAngle * distance / 2,
        );

        canvas.save();

        canvas.translate(textOffset.dx, textOffset.dy);

        canvas.rotate(angle);

        textPainter.paint(
            canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

        canvas.restore();

        hitWall = true;
      }
    }

    // Draw the ray
    final rayEnd = Offset(
      position.dx + cosAngle * distance,
      position.dy + sinAngle * distance,
    );

    canvas.drawLine(
      position,
      rayEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
