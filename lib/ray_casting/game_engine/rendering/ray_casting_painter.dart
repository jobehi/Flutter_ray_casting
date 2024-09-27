import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ray_something/ray_casting/game_engine/models/bullet.dart';
import 'package:ray_something/ray_casting/game_engine/models/enemy.dart';
import 'package:ray_something/ray_casting/game_engine/models/explosion.dart';
import 'package:ray_something/ray_casting/game_engine/models/player.dart';

class RayCastingPainter extends CustomPainter {
  final List<List<int>> map;
  final Player player;
  final List<Enemy> enemies;
  final ui.Image? enemyImage;
  final List<Bullet> bullets;
  final List<Explosion> explosions;
  final List<ui.Image> explosionImages;
  final ui.Image? wallTexture;
  final ui.Image? floorTexture;

  RayCastingPainter({
    required this.map,
    required this.player,
    required this.enemies,
    required this.enemyImage,
    required this.bullets,
    required this.explosions,
    required this.explosionImages,
    required this.wallTexture,
    required this.floorTexture,
  });

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
    // Draw floor and ceiling with gradient effect
    for (int y = screenHeight ~/ 2; y < screenHeight; y++) {
      double depth = (screenHeight / (2.0 * y - screenHeight));
      double brightness = 1.0 - (depth / maxDepth);
      if (brightness < 0) brightness = 0;

      // Floor
      paint.color = Color.lerp(Colors.brown, Colors.black, 1 - brightness)!;
      canvas.drawLine(
        Offset(0, y.toDouble()),
        Offset(screenWidth, y.toDouble()),
        paint,
      );

      // Ceiling (mirror the y-coordinate)
      paint.color =
          Color.lerp(Colors.lightBlueAccent, Colors.black, 1 - brightness)!;
      canvas.drawLine(
        Offset(0, (screenHeight - y).toDouble()),
        Offset(screenWidth, (screenHeight - y).toDouble()),
        paint,
      );
    }
    List<double> depthBuffer = List.filled(numRays, double.infinity);

    for (int i = 0; i < numRays; i++) {
      final rayAngle = (player.angle - halfFov) + (i * angleStep);

      double distanceToWall = 0.0;
      bool hitWall = false;
      bool isVerticalHit = false;

      final eyeX = cos(rayAngle);
      final eyeY = sin(rayAngle);

      double hitX = 0.0;
      double hitY = 0.0;

      while (!hitWall && distanceToWall < maxDepth) {
        /// adjust this value to increase the raycasting resolution
        distanceToWall += 0.01;

        hitX = player.x + eyeX * distanceToWall;
        hitY = player.y + eyeY * distanceToWall;

        final testX = hitX.toInt();
        final testY = hitY.toInt();

        if (testX < 0 ||
            testX >= map[0].length ||
            testY < 0 ||
            testY >= map.length) {
          hitWall = true;
          distanceToWall = maxDepth;
        } else {
          if (map[testY][testX] == 1) {
            hitWall = true;

            // Determine if the hit was vertical or horizontal
            double blockMidX = testX + 0.5;
            double blockMidY = testY + 0.5;

            double hitX = player.x + eyeX * distanceToWall;
            double hitY = player.y + eyeY * distanceToWall;

            double angleBetween = atan2(hitY - blockMidY, hitX - blockMidX);
            angleBetween = angleBetween % (pi / 2);

            if (angleBetween < 0.0001 || angleBetween > (pi / 2) - 0.0001) {
              isVerticalHit = true;
            } else {
              isVerticalHit = false;
            }
          }
        }
      }

      final correctedDistance =
          distanceToWall * cos(player.angle - rayAngle + 0.0001);

      final wallHeight = screenHeight / (correctedDistance + 0.0001);

      double brightness = (1 - (correctedDistance / maxDepth)).clamp(0.0, 1.0);

      // Further adjust shade based on hit orientation
      if (isVerticalHit) {
        brightness *= 0.7; // Darken vertical walls
      }

      final x = i * (screenWidth / numRays);
      if (wallTexture != null && hitWall) {
        // Texture mapping
        double wallX;
        if (isVerticalHit) {
          wallX = hitY % 1;
        } else {
          wallX = hitX % 1;
        }
        int texX = (wallX * wallTexture!.width).toInt();
        texX = texX.clamp(0, wallTexture!.width - 1);

        Rect srcRect = Rect.fromLTWH(
          texX.toDouble(),
          0,
          1,
          wallTexture!.height.toDouble(),
        );

        Rect dstRect = Rect.fromLTWH(
          x,
          (screenHeight - wallHeight) / 2,
          (screenWidth / numRays) + 1,
          wallHeight,
        );

        paint.color = Colors.white;
        paint.colorFilter = ColorFilter.mode(
          Colors.black.withOpacity(1 - brightness),
          BlendMode.multiply,
        );

        canvas.drawImageRect(wallTexture!, srcRect, dstRect, paint);

        paint.colorFilter = null; // Reset color filter
      } else {
        // Use solid color if texture is not available
        int shade = (255 * brightness).toInt();

        paint.color = Color.fromARGB(255, shade, shade, shade);

        canvas.drawLine(
          Offset(x, (screenHeight - wallHeight) / 2),
          Offset(x, (screenHeight + wallHeight) / 2),
          paint..strokeWidth = (screenWidth / numRays) + 1,
        );
      }
      // Save the distance to the wall for this ray
      depthBuffer[i] = correctedDistance;
    }
    // Render enemies

    renderEnemies(canvas, size, depthBuffer);
    renderBullets(canvas, size, depthBuffer);
    renderExplosions(canvas, size, depthBuffer);
    applyLighting(canvas, size);
  }

  void applyLighting(Canvas canvas, Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Create a radial gradient centered on the player's view direction
    Rect gradientRect = Rect.fromCircle(
      center: Offset(screenWidth / 2, screenHeight / 2),
      radius: screenHeight / 2,
    );

    Paint lightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0),
        radius: 0.8,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.8),
        ],
        stops: const [0.6, 1.0],
      ).createShader(gradientRect)
      ..blendMode = BlendMode.darken;

    // Draw the gradient overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenWidth, screenHeight),
      lightPaint,
    );
  }

  void renderExplosions(Canvas canvas, Size size, List<double> depthBuffer) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    const fov = pi / 3;
    const halfFov = fov / 2;

    for (Explosion explosion in explosions) {
      double dx = explosion.x - player.x;
      double dy = explosion.y - player.y;
      double distance = sqrt(dx * dx + dy * dy);

      double angleToExplosion = atan2(dy, dx) - player.angle;

      // Normalize angle to -pi to pi
      if (angleToExplosion < -pi) angleToExplosion += 2 * pi;
      if (angleToExplosion > pi) angleToExplosion -= 2 * pi;

      // Check if explosion is within FOV
      if (angleToExplosion > -halfFov && angleToExplosion < halfFov) {
        // Project explosion onto screen
        double screenX = (angleToExplosion + halfFov) / fov * screenWidth;

        // Scale explosion size based on distance
        double explosionSize = (screenHeight / (distance + 0.0001)) * 0.7;
        explosionSize = explosionSize.clamp(20, screenHeight / 2); // Clamp size

        int explosionScreenX = screenX.toInt();

        // Check if explosion is behind a wall at this screen position
        if (explosionScreenX >= 0 && explosionScreenX < depthBuffer.length) {
          if (depthBuffer[explosionScreenX] < distance) {
            // Wall is closer than explosion, so skip rendering
            continue;
          }
        }

        // Save the canvas state before applying transformations
        canvas.save();

        // Translate canvas to the explosion's position
        canvas.translate(screenX, screenHeight / 2);

        // Draw the current frame of the explosion
        ui.Image frameImage = explosionImages[explosion.currentFrame];

        Paint paint = Paint();
        Rect srcRect = Rect.fromLTWH(
          0,
          0,
          frameImage.width.toDouble(),
          frameImage.height.toDouble(),
        );
        Rect dstRect = Rect.fromCenter(
          center: const Offset(0, 0),
          width: explosionSize,
          height: explosionSize,
        );
        canvas.drawImageRect(frameImage, srcRect, dstRect, paint);

        // Restore canvas to previous state
        canvas.restore();
      }
    }
  }

  void renderBullets(Canvas canvas, Size size, List<double> depthBuffer) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    const fov = pi / 3;
    const halfFov = fov / 2;

    Paint paint = Paint()..color = Colors.yellow; // Bullet color

    for (Bullet bullet in bullets) {
      double dx = bullet.x - player.x;
      double dy = bullet.y - player.y;
      double distance = sqrt(dx * dx + dy * dy);

      double angleToBullet = atan2(dy, dx) - player.angle;

      // Normalize angle to -pi to pi
      if (angleToBullet < -pi) angleToBullet += 2 * pi;
      if (angleToBullet > pi) angleToBullet -= 2 * pi;

      // Check if bullet is within FOV
      if (angleToBullet > -halfFov && angleToBullet < halfFov) {
        // Project bullet onto screen
        double screenX = (angleToBullet + halfFov) / fov * screenWidth;

        // Scale bullet size based on distance
        double bulletSize = (screenHeight / (distance + 0.0001)) * 0.1;
        bulletSize = bulletSize.clamp(2, 10); // Clamp to reasonable size

        int bulletScreenX = screenX.toInt();

        // Check if bullet is behind a wall at this screen position
        if (bulletScreenX >= 0 && bulletScreenX < depthBuffer.length) {
          if (depthBuffer[bulletScreenX] < distance) {
            // Wall is closer than bullet, so skip rendering
            continue;
          }
        }

        // Draw bullet as a circle
        canvas.drawCircle(
          Offset(screenX, screenHeight / 2),
          bulletSize,
          paint,
        );
      }
    }
  }

  void renderEnemies(Canvas canvas, Size size, List<double> depthBuffer) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    const fov = pi / 3; // Same as before
    const halfFov = fov / 2;

    List<EnemyData> enemyDataList = [];

    for (Enemy enemy in enemies) {
      double dx = enemy.x - player.x;
      double dy = enemy.y - player.y;
      double distance = sqrt(dx * dx + dy * dy);

      double angleToEnemy = atan2(dy, dx) - player.angle;

      // Normalize angle to -pi to pi
      if (angleToEnemy < -pi) angleToEnemy += 2 * pi;
      if (angleToEnemy > pi) angleToEnemy -= 2 * pi;

      // Check if enemy is within FOV
      if (angleToEnemy > -halfFov && angleToEnemy < halfFov) {
        // Check if enemy is visible (not blocked by walls)
        if (isEnemyVisible(enemy, distance)) {
          enemyDataList.add(EnemyData(
            enemy: enemy,
            distance: distance,
            angleToEnemy: angleToEnemy,
          ));
        }
      }
    }

    // Sort enemies by distance (farthest first)
    enemyDataList.sort((a, b) => b.distance.compareTo(a.distance));

    // Now render enemies
    for (EnemyData enemyData in enemyDataList) {
      Enemy enemy = enemyData.enemy;

      double distance = enemyData.distance;
      double angleToEnemy = enemyData.angleToEnemy;

      // Project enemy onto screen
      double screenX = (angleToEnemy + halfFov) / fov * screenWidth;

      // Scale enemy size based on distance
      double enemySize =
          (screenHeight / distance) * 0.5; // Adjust scaling factor as needed
      enemySize =
          enemySize.clamp(20, screenHeight / 2); // Clamp to reasonable size

      int enemyScreenX = screenX.toInt();

      // Check if enemy is behind a wall at this screen position
      if (enemyScreenX >= 0 && enemyScreenX < depthBuffer.length) {
        if (depthBuffer[enemyScreenX] < distance) {
          // Wall is closer than enemy, so skip rendering
          continue;
        }
      }
      // Save the canvas state before applying transformations
      canvas.save();

      // Translate canvas to the enemy's position
      canvas.translate(screenX, screenHeight / 2);

      // Apply rotation based on enemy's angle relative to player
      double renderAngle = enemy.angle + pi; // Adjusted rotation

      canvas.rotate(renderAngle);

      if (enemyImage != null) {
        // Draw enemy image
        Paint paint = Paint();
        Rect srcRect = Rect.fromLTWH(
          0,
          0,
          enemyImage!.width.toDouble(),
          enemyImage!.height.toDouble(),
        );
        Rect dstRect = Rect.fromCenter(
          center: const Offset(0, 0),
          width: enemySize / 2,
          height: enemySize,
        );
        canvas.drawImageRect(enemyImage!, srcRect, dstRect, paint);
      } else {
        // Draw enemy as a rectangle as a fallback
        Paint paint = Paint()..color = Colors.red;
        canvas.drawRect(
          Rect.fromCenter(
            center: const Offset(0, 0),
            width: enemySize / 2,
            height: enemySize,
          ),
          paint,
        );
      }

      // Restore canvas to previous state
      canvas.restore();
    }
  }

  bool isEnemyVisible(Enemy enemy, double distance) {
    // Perform ray casting from player to enemy
    double dx = enemy.x - player.x;
    double dy = enemy.y - player.y;
    double angleToEnemy = atan2(dy, dx);

    double eyeX = cos(angleToEnemy);
    double eyeY = sin(angleToEnemy);

    double rayX = player.x;
    double rayY = player.y;
    double maxDistance = distance;

    double stepSize = 0.05; // Adjust step size as needed

    double distanceTraveled = 0.0;

    while (distanceTraveled < maxDistance) {
      rayX += eyeX * stepSize;
      rayY += eyeY * stepSize;

      distanceTraveled += stepSize;

      int mapX = rayX.toInt();
      int mapY = rayY.toInt();

      // Check if ray is out of bounds
      if (mapX < 0 || mapX >= map[0].length || mapY < 0 || mapY >= map.length) {
        return false;
      }

      if (map[mapY][mapX] == 1) {
        // Wall is blocking the enemy
        return false;
      }
    }

    return true;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class EnemyData {
  Enemy enemy;
  double distance;
  double angleToEnemy;

  EnemyData(
      {required this.enemy,
      required this.distance,
      required this.angleToEnemy});
}
