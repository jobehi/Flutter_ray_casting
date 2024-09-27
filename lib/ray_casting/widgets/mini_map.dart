import 'dart:math';

import 'package:flutter/material.dart';

import '../game_engine/models/enemy.dart';
import '../game_engine/models/player.dart';

class Minimap extends StatelessWidget {
  final List<List<int>> map;
  final Player player;
  final List<Enemy> enemies;

  const Minimap({
    super.key,
    required this.map,
    required this.player,
    required this.enemies,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MinimapPainter(
        map: map,
        player: player,
        enemies: enemies,
      ),
      size: const Size(150, 150), // Adjust the size as needed
    );
  }
}

class MinimapPainter extends CustomPainter {
  final List<List<int>> map;
  final Player player;
  final List<Enemy> enemies;

  MinimapPainter({
    required this.map,
    required this.player,
    required this.enemies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final mapHeight = map.length;
    final mapWidth = map[0].length;

    // Determine the scale factor to fit the map into the minimap size
    final scaleX = size.width / mapWidth;
    final scaleY = size.height / mapHeight;
    final scale = min(scaleX, scaleY);

    // Draw maze walls
    paint.color = Colors.grey;
    for (int y = 0; y < mapHeight; y++) {
      for (int x = 0; x < mapWidth; x++) {
        if (map[y][x] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * scale,
              y * scale,
              scale,
              scale,
            ),
            paint,
          );
        }
      }
    }

    // Draw player
    paint.color = Colors.blue;
    canvas.drawCircle(
      Offset(player.x * scale, player.y * scale),
      scale / 4, // Adjust size of the player dot
      paint,
    );

    // Draw player's viewing direction
    final double dirLength = scale;
    final playerDirX = cos(player.angle) * dirLength;
    final playerDirY = sin(player.angle) * dirLength;
    paint.strokeWidth = 2;
    canvas.drawLine(
      Offset(player.x * scale, player.y * scale),
      Offset(
        (player.x * scale) + playerDirX,
        (player.y * scale) + playerDirY,
      ),
      paint,
    );

    // Draw enemies
    paint.color = Colors.red;
    for (Enemy enemy in enemies) {
      canvas.drawCircle(
        Offset(enemy.x * scale, enemy.y * scale),
        scale / 4, // Adjust size of the enemy dot
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
