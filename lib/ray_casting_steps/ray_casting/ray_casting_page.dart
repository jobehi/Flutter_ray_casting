import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_engine/models/bullet.dart';
import 'game_engine/models/enemy.dart';
import 'game_engine/models/explosion.dart';
import 'game_engine/models/player.dart';
import 'game_engine/rendering/ray_casting_painter.dart';
import 'widgets/mini_map.dart';

class MazeGamePage extends StatefulWidget {
  const MazeGamePage({super.key});

  @override
  MazeGamePageState createState() => MazeGamePageState();
}

class MazeGamePageState extends State<MazeGamePage> {
  List<Bullet> bullets = [];

  final List<List<int>> mazeMap = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1], // y = 0
    [1, 0, 0, 0, 0, 0, 0, 0, 1], // y = 1
    [1, 0, 1, 0, 1, 0, 0, 1, 1], // y = 2
    [1, 0, 1, 0, 1, 0, 1, 0, 1], // y = 3
    [1, 0, 0, 0, 0, 0, 0, 0, 1], // y = 4
    [1, 1, 1, 1, 1, 1, 1, 1, 1], // y = 5
  ];

  late Player player;
  List<Enemy> enemies = [];
  Timer? _gameLoopTimer;
  ui.Image? enemyImage;
  List<Explosion> explosions = [];
  List<ui.Image> explosionImages = [];
  bool gameOver = false;
  String gameOverMessage = '';
  ui.Image? wallTexture;
  ui.Image? floorTexture;

  void onGameWon() {
    // Stop the game loop timer
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;

    setState(() {
      gameOver = true;
      gameOverMessage = 'You Win!';
    });
  }

  void restartGame() {
    setState(() {
      // Reset game state
      player = Player(x: 1.5, y: 1.5, angle: 0.3);
      enemies.clear();
      initializeEnemies();
      bullets.clear();
      explosions.clear();
      gameOver = false;
      gameOverMessage = '';
      setGameLoop();
    });
  }

  void setGameLoop() {
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      setState(() {
        updateEnemies();
        updateBullets();
        updateExplosions();
        checkBulletCollisions();
      });
    });
  }

  void initializeEnemies() {
    enemies
        .add(Enemy(x: 7.5, y: 1.5, angle: 0.0)); // Initial angle is 0.0 radians
  }

  @override
  void initState() {
    super.initState();
    player = Player(x: 1.5, y: 1.5, angle: 0.3);
    initializeEnemies();
    loadEnemyImage();
    loadExplosionImages();
    loadTextures();

    setGameLoop();
  }

  void checkBulletCollisions() {
    bullets.removeWhere((bullet) {
      bool bulletHit = false;
      enemies.removeWhere((enemy) {
        double dx = enemy.x - bullet.x;
        double dy = enemy.y - bullet.y;
        double distance = sqrt(dx * dx + dy * dy);
        if (distance < 0.5) {
          bulletHit = true;
          return true; // Remove enemy
        }
        return false; // Keep enemy
      });
      // Check if all enemies are defeated
      if (enemies.isEmpty) {
        onGameWon();
      }
      return bulletHit; // Remove bullet if it hit an enemy
    });
  }

  void updateBullets() {
    const double bulletSpeed = 0.2; // Adjust bullet speed as needed
    bullets.removeWhere((bullet) {
      // Move bullet forward
      bullet.x += cos(bullet.angle) * bulletSpeed;
      bullet.y += sin(bullet.angle) * bulletSpeed;

      // Remove bullet if it hits a wall or goes out of bounds
      if (bullet.x < 0 ||
          bullet.x >= mazeMap[0].length ||
          bullet.y < 0 ||
          bullet.y >= mazeMap.length ||
          mazeMap[bullet.y.toInt()][bullet.x.toInt()] == 1) {
        return true; // Remove bullet
      }
      return false; // Keep bullet
    });
  }

  void updateExplosions() {
    explosions.removeWhere((explosion) {
      explosion.timeSinceLastFrame +=
          0.016; // Assuming 60 FPS, adjust if necessary
      if (explosion.timeSinceLastFrame >= explosion.frameDuration) {
        explosion.timeSinceLastFrame = 0;
        explosion.currentFrame++;
        if (explosion.currentFrame >= explosion.totalFrames) {
          return true; // Remove explosion when animation is complete
        }
      }
      return false; // Keep explosion
    });
  }

  void loadEnemyImage() async {
    final image = await getImageFromPath('assets/sprites/sprite1.png');
    setState(() {
      enemyImage = image;
    });
  }

  void loadTextures() async {
    final imageWall =
        await getImageFromPath('assets/textures/wall_texture.jpg');
    final imageFloor =
        await getImageFromPath('assets/textures/floor_texture.jpg');

    setState(() {
      wallTexture = imageWall;
      floorTexture = imageFloor;
    });
  }

  void loadExplosionImages() async {
    List<String> explosionImagePaths = [
      'assets/sprites/exploz.png',
    ];

    for (String path in explosionImagePaths) {
      final image = await getImageFromPath(path);
      explosionImages.add(image);
    }
  }

  Future<ui.Image> getImageFromPath(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  void updateEnemies() {
    for (Enemy enemy in enemies) {
      // Calculate direction to player
      double dx = player.x - enemy.x;
      double dy = player.y - enemy.y;
      double distance = sqrt(dx * dx + dy * dy);

      if (distance > 1.0) {
        // Update enemy's angle to face the player
        enemy.angle = atan2(dy, dx);

        // Move towards player
        double moveSpeed = 0.01; // Adjust as needed
        double newX = enemy.x + cos(enemy.angle) * moveSpeed;
        double newY = enemy.y + sin(enemy.angle) * moveSpeed;

        // Collision detection with walls
        if (mazeMap[newY.toInt()][newX.toInt()] == 0) {
          enemy.x = newX;
          enemy.y = newY;
        }
      }
    }
  }

  void move(double moveSpeed) {
    final newX = player.x + cos(player.angle) * moveSpeed;
    final newY = player.y + sin(player.angle) * moveSpeed;

    // Collision detection
    if (mazeMap[newY.toInt()][newX.toInt()] == 0) {
      /// If the player walks in the permitted area, update the player's position
      // Collision detection with enemies
      bool collisionWithEnemy = false;
      for (Enemy enemy in enemies) {
        double dx = enemy.x - newX;
        double dy = enemy.y - newY;
        double distance = sqrt(dx * dx + dy * dy);

        if (distance < 0.5) {
          collisionWithEnemy = true;
          break;
        }
      }

      if (!collisionWithEnemy) {
        // If no collision, update the player's position
        setState(() {
          player.x = newX;
          player.y = newY;
        });
      }
    }
  }

  void rotate(double rotSpeed) {
    setState(() {
      player.angle += rotSpeed;
    });
  }

  void shoot() {
    setState(() {
      bullets.add(
        Bullet(
          x: player.x,
          y: player.y,
          angle: player.angle,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            /// move the player on drag
            /// take into account the angle of the player

            onVerticalDragUpdate: (details) {
              final primaryDelta = details.primaryDelta;
              if (primaryDelta == null) {
                return;
              }
              move(primaryDelta > 0 ? 0.05 : -0.05);
            },

            onHorizontalDragUpdate: (details) {
              final primaryDelta = details.primaryDelta;
              if (primaryDelta == null) {
                return;
              }
              rotate(primaryDelta * 0.001);
            },
            child: CustomPaint(
              painter: RayCastingPainter(
                map: mazeMap,
                player: player,
                enemies: enemies,
                bullets: bullets,
                explosions: explosions,
                explosionImages: explosionImages,
                enemyImage: enemyImage,
                wallTexture: wallTexture,
                floorTexture: floorTexture,
              ),
            ),
          ),
          if (!gameOver) ...[
            // Your existing control buttons
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
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: FloatingActionButton(
                onPressed: shoot,
                child: const Icon(Icons.whatshot),
              ),
            ),
            // Add the minimap if you have one
            Positioned(
              top: 20,
              right: 20,
              child: Minimap(
                map: mazeMap,
                player: player,
                enemies: enemies,
              ),
            ),
          ],
          if (gameOver)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      gameOverMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: restartGame,
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
