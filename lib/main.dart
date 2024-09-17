import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MazeGameApp());

class Player {
  double x;
  double y;
  double angle;

  Player({required this.x, required this.y, required this.angle});
}

class MazeGameApp extends StatelessWidget {
  const MazeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MazeGamePage(),
    );
  }
}

class MazeGamePage extends StatefulWidget {
  const MazeGamePage({super.key});

  @override
  MazeGamePageState createState() => MazeGamePageState();
}

class MazeGamePageState extends State<MazeGamePage> {
  final List<List<int>> mazeMap = [
    [1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 1, 0, 1],
    [1, 0, 1, 0, 1, 0, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1],
  ];

  late Player player;

  @override
  void initState() {
    super.initState();
    player = Player(x: 1.5, y: 1.5, angle: 0.3);
  }

  void move(double moveSpeed) {
    final newX = player.x + cos(player.angle) * moveSpeed;
    final newY = player.y + sin(player.angle) * moveSpeed;

    // Collision detection
    if (mazeMap[newY.toInt()][newX.toInt()] == 0) {
      /// If the player walks in the permitted area, update the player's position
      setState(() {
        player.x = newX;
        player.y = newY;
      });
    }
  }

  void rotate(double rotSpeed) {
    setState(() {
      player.angle += rotSpeed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: RayCastingPainter(map: mazeMap, player: player),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () => move(0.1), // Move forward
                  child: const Icon(Icons.arrow_upward),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => move(-0.1), // Move backward
                  child: const Icon(Icons.arrow_downward),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () => rotate(-0.1), // Rotate left
                  child: const Icon(Icons.rotate_left),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => rotate(0.1), // Rotate right
                  child: const Icon(Icons.rotate_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RayCastingPainter extends CustomPainter {
  final List<List<int>> map;
  final Player player;

  RayCastingPainter({required this.map, required this.player});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final screenWidth = size.width;
    final screenHeight = size.height;

    const fov = pi / 3; // 60 degrees field of view
    const halfFov = fov / 2;

    final numRays = screenWidth.toInt();
    final angleStep = fov / numRays;

    const maxDepth = 20.0;

    for (int i = 0; i < numRays; i++) {
      final rayAngle = (player.angle - halfFov) + (i * angleStep);

      double distanceToWall = 0.0;
      bool hitWall = false;

      final eyeX = cos(rayAngle);
      final eyeY = sin(rayAngle);

      while (!hitWall && distanceToWall < maxDepth) {
        /// adjust this value to increase the raycasting resolution
        distanceToWall += 0.01;

        final testX = (player.x + eyeX * distanceToWall).toInt();
        final testY = (player.y + eyeY * distanceToWall).toInt();

        if (testX < 0 ||
            testX >= map[0].length ||
            testY < 0 ||
            testY >= map.length) {
          hitWall = true;
          distanceToWall = maxDepth;
        } else {
          if (map[testY][testX] == 1) {
            hitWall = true;
          }
        }
      }

      final correctedDistance = distanceToWall * cos(player.angle - rayAngle);

      final wallHeight = screenHeight / correctedDistance;

      final shade = (255 - (correctedDistance * 30)).clamp(0, 255).toInt();

      paint.color = Color.fromARGB(255, shade, shade, shade);

      final x = i * (screenWidth / numRays);
      canvas.drawLine(
        Offset(x, (screenHeight - wallHeight) / 2),
        Offset(x, (screenHeight + wallHeight) / 2),
        paint..strokeWidth = (screenWidth / numRays) + 1,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
