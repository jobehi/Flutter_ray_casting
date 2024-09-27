import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Step6 extends StatefulWidget {
  const Step6({super.key});

  @override
  Step6State createState() => Step6State();
}

class Step6State extends State<Step6> {
  Offset playerPosition = const Offset(70, 70);
  double playerAngle = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('page6 - 3D Doom-like view'),
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
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
              playerPosition -= Offset(
                cos(playerAngle + pi / 2) * 5,
                sin(playerAngle + pi / 2) * 5,
              );
            });
          }

          if (event.logicalKey == LogicalKeyboardKey.keyD) {
            setState(() {
              playerPosition += Offset(
                cos(playerAngle + pi / 2) * 5,
                sin(playerAngle + pi / 2) * 5,
              );
            });
          }
        },
        child: GestureDetector(
          /// move the player on drag
          /// take into account the angle of the player

          onVerticalDragUpdate: (details) {
            final primaryDelta = details.primaryDelta;
            if (primaryDelta == null) {
              return;
            }

            final isForward = primaryDelta > 0;

            final newX =
                playerPosition.dx + cos(playerAngle) * (isForward ? 1 : -1);

            final newY =
                playerPosition.dy + sin(playerAngle) * (isForward ? 1 : -1);

            setState(() {
              playerPosition = Offset(newX, newY);
            });
          },

          onHorizontalDragUpdate: (details) {
            setState(() {
              playerAngle += details.delta.dx * 0.001;
            });
          },
          child: CustomPaint(
            painter: DoomLikeViewPainter(playerPosition, playerAngle),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class DoomLikeViewPainter extends CustomPainter {
  final Offset playerPosition;
  final double playerAngle;
  final List<List<int>> map;

  DoomLikeViewPainter(this.playerPosition, this.playerAngle)
      : map = [
          [1, 1, 1, 1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 0, 1],
          [1, 0, 1, 0, 0, 1, 0, 1],
          [1, 0, 1, 0, 0, 1, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 1],
          [1, 0, 1, 1, 1, 1, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 1],
          [1, 1, 1, 1, 1, 1, 1, 1],
        ];

  @override
  void paint(Canvas canvas, Size size) {
    final screenWidth = size.width;

    // Number of rays
    final numRays = screenWidth.toInt();
    const cellSize = 64.0;
    final columnWidth = screenWidth / numRays;

    const fov = pi / 3; // 60 degrees field of view
    final startAngle = playerAngle - fov / 2;

    for (int i = 0; i < numRays; i++) {
      final rayAngle = startAngle + (i * fov) / numRays;
      final distance = castRay(playerPosition, rayAngle, cellSize);

      // Correct fish-eye distortion

      final correctedDistance = distance * cos(rayAngle - playerAngle);

      // Calculate the projected wall height
      final projectionPlaneDistance = (size.width / 2) / tan(fov / 2);
      final wallSliceHeight =
          (cellSize / correctedDistance) * projectionPlaneDistance;

      // Determine wall color based on distance (simple shading)
      final shade = 255 - min(255, correctedDistance * 255 ~/ 500);
      final wallPaint = Paint()
        ..color =
            Color.fromARGB(255, shade.toInt(), shade.toInt(), shade.toInt());

      // Draw the wall slice
      canvas.drawRect(
        Rect.fromLTWH(
          i * columnWidth,
          (size.height / 2) - (wallSliceHeight / 2),
          columnWidth,
          wallSliceHeight,
        ),
        wallPaint,
      );
    }
  }

  double castRay(Offset position, double angle, double cellSize) {
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
        hitWall = true;
      }
    }

    return distance;
  }

  @override
  bool shouldRepaint(covariant DoomLikeViewPainter oldDelegate) =>
      oldDelegate.playerPosition != playerPosition ||
      oldDelegate.playerAngle != playerAngle;
}
