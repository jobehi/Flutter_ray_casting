import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ray_something/steps_explanation/ray_casting/game_engine/models/player.dart';
import 'package:ray_something/steps_explanation/ray_casting/widgets/mini_map.dart';

import 'data/level.dart';
import 'models/3d/camera.dart';
import 'models/3d/light.dart';
import 'models/3d/scene/scene.dart';
import 'models/3d/scene_objects/plane.dart';
import 'models/3d/scene_objects/scene_object.dart';
import 'models/3d/scene_objects/sphere.dart';
import 'models/maths/vector_3.dart';
import 'scene_painter/scene_painter.dart';

enum ThreeDObject {
  sphere,
  cube,
  none,
}

class LevelBuilder {
  final List<List<ThreeDObject>> levelMapMatrix;

  LevelBuilder({required this.levelMapMatrix});

  Scene buildScene() {
    final List<SceneObject> objects = [];
    for (int i = 0; i < levelMapMatrix.length; i++) {
      for (int j = 0; j < levelMapMatrix[i].length; j++) {
        final ThreeDObject object = levelMapMatrix[i][j];
        if (object == ThreeDObject.sphere) {
          objects.add(Sphere(
            center: Vector3(j.toDouble(), 0, i.toDouble()),
            radius: 1,
            color: const ui.Color.fromARGB(255, 255, 213, 0),
          ));
        } else if (object == ThreeDObject.cube) {
          objects.add(Cube(
            minCorner: Vector3(j.toDouble(), -1, i.toDouble()),
            maxCorner: Vector3(j.toDouble() + 1, 3, i.toDouble() + 1),
            color: Colors.white,
          ));
        }
      }
    }

    return Scene(
      objects: objects
        ..add(Plane(
          point: Vector3(0, -1, 0),
          normal: Vector3(0, 1, 0),
          color: Colors.white,
        )),
      light: Light(
        position: Vector3(8, 20, -10),
        color: const Color(0xFFFFFFFF),
        intensity: 1,
      ),
      backgroundColor: Colors.lightBlue,
    );
  }
}

class BasicRayTracingWidget extends StatefulWidget {
  const BasicRayTracingWidget({super.key});

  @override
  RayTracingWidgetState createState() => RayTracingWidgetState();
}

class RayTracingWidgetState extends State<BasicRayTracingWidget> {
  late double screenWidth;
  late double screenHeight;

  ui.Image? image;
  bool isRendering = true;
  late Scene scene;
  // Light parameters
  double lightPosX = 8.0;
  double lightPosY = 8.0;
  double lightPosZ = -10.0;
  double lightIntensity = 0.5;
  double cameraTilt = 0;
  int lowResMultiplier = 8;

  // Debounce timer
  Timer? _debounce;

  // Define camera as a state variable
  Camera camera = Camera(
    position: Vector3(2, 0.1, -4),
    viewportWidth: 1.0,
    viewportHeight: 1.0,
    focalLength: 1,
    verticalIiltAngle: 0.0,
    horizontalTiltAngle: 0,
  );

  // Variables to handle dragging
  bool isDragging = false;
  Offset? dragStart;
  double? initialLightPosX;
  double? initialLightPosY;
  late List<List<ThreeDObject>> levelMap;

  @override
  void initState() {
    levelMap = Level.level1;
    scene = LevelBuilder(levelMapMatrix: levelMap).buildScene();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final size = MediaQuery.of(context).size;
    super.didChangeDependencies();
    screenWidth = size.width;
    screenHeight = size.width;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Function to trigger image rendering with debounce
  void onChange() {
    setState(() {});
  }

  // Function to handle dragging of the light source

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text('Reduce Resolution: $lowResMultiplier'),
                Slider(
                  value: lowResMultiplier.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: lowResMultiplier.toString(),
                  onChanged: (value) {
                    setState(() {
                      lowResMultiplier = value.toInt();
                    });
                    onChange(); // Debounced renderImage call
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: GestureDetector(
              /// move the player on drag
              /// take into account the angle of the player

              onVerticalDragUpdate: (details) {
                final primaryDelta = details.primaryDelta;
                if (primaryDelta == null) {
                  return;
                }
                setState(() {
                  /// move forwards and take into consideration the camera tilt
                  camera = camera.copyWith(
                      position: camera.position.add(
                          Vector3(0, 0, primaryDelta > 0 ? 0.01 : -0.01)
                              .rotateYawPitch(camera.horizontalTiltAngle,
                                  camera.verticalIiltAngle)));
                });
              },

              onHorizontalDragUpdate: (details) {
                final primaryDelta = details.primaryDelta;
                if (primaryDelta == null) {
                  return;
                }

                /// rotate the camera
                setState(() {
                  camera = camera.copyWith(
                      horizontalTiltAngle:
                          camera.horizontalTiltAngle + primaryDelta * 0.01);
                });
              },
              child: CustomPaint(
                size: Size(screenWidth, screenHeight),
                painter: ImagePainter(
                  lowResFactor: lowResMultiplier,
                  scene: scene,
                  lightPosition: Vector3(lightPosX, lightPosY, lightPosZ),
                  camera: camera,
                  light: Light(
                    position: Vector3(lightPosX, lightPosY, lightPosZ),
                    color: const ui.Color.fromARGB(255, 255, 240, 240),
                    intensity: lightIntensity,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Minimap(
              map: levelMap.map((e) {
                return e.map((e) {
                  if (e == ThreeDObject.cube) {
                    return 1;
                  }

                  return 0;
                }).toList();
              }).toList(),
              player: Player(
                  x: camera.position.x,
                  y: camera.position.z,
                  angle: camera.horizontalTiltAngle),
              enemies: const []),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                        'Vertical camera tilt: ${camera.verticalIiltAngle.toStringAsFixed(1)}'),
                    Slider(
                      value: camera.verticalIiltAngle,
                      min: -pi / 2,
                      max: pi / 2,
                      divisions: 100,
                      label: camera.verticalIiltAngle.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          /// update the camera tilt
                          camera = camera.copyWith(verticalIiltAngle: value);
                        });
                        onChange(); // Debounced renderImage call
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text('Light Position X: ${lightPosX.toStringAsFixed(1)}'),
                    Slider(
                      value: lightPosX,
                      min: -20.0,
                      max: 20.0,
                      divisions: 400,
                      label: lightPosX.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          lightPosX = value;
                        });
                        onChange(); // Debounced renderImage call
                      },
                    ),
                  ],
                ),
              ),

              /// Move camera position with buttons

              /// forwad button

              // Slider for Light Z Position
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 33.0),
                child: Column(
                  children: [
                    Text('Light Position Z: ${lightPosZ.toStringAsFixed(1)}'),
                    Slider(
                      value: lightPosZ,
                      min: -20.0,
                      max: 0.0,
                      divisions: 200,
                      label: lightPosZ.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          lightPosZ = value;
                        });
                        onChange(); // Debounced renderImage call
                      },
                    ),
                  ],
                ),
              ),
              // Slider for Light Intensity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                        'Light Intensity: ${lightIntensity.toStringAsFixed(1)}'),
                    Slider(
                      value: lightIntensity,
                      min: 0.1,
                      max: 5.0,
                      divisions: 100,
                      label: lightIntensity.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          lightIntensity = value;
                        });
                        onChange(); // Debounced renderImage call
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
