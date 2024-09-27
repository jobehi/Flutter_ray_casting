// image_painter.dart

import 'package:flutter/material.dart';

import '../models/3d/camera.dart';
import '../models/3d/light.dart';
import '../models/3d/scene/scene.dart';
import '../models/maths/ray.dart';
import '../models/maths/vector_3.dart';

class ImagePainter extends CustomPainter {
  final Vector3 lightPosition;
  final Camera camera;
  final Light light;
  final Scene scene;
  final int lowResFactor;

  ImagePainter({
    required this.lightPosition,
    required this.camera,
    required this.light,
    required this.scene,
    this.lowResFactor = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a paint object
    Paint paint = Paint();

    // Define the internal scene with objects and lighting
    final internalScene = Scene(
      objects: scene.objects,
      light: light,
      backgroundColor: scene.backgroundColor,
      maxDepth: scene.maxDepth,
    );

    final double horizontalTiltAngle = camera.horizontalTiltAngle;
    final double verticalTiltAngle = camera.verticalIiltAngle;

    // Iterate over each pixel on the canvas
    for (int y = 0; y < size.height; y = y + lowResFactor) {
      for (int x = 0; x < size.width; x = x + lowResFactor) {
        // Compute normalized device coordinates (NDC)
        double ndcX = (x + 0.5) / size.width;
        double ndcY = (y + 0.5) / size.height;

        // Screen space coordinates in camera's viewport
        double screenX = (2 * ndcX - 1) * camera.viewportWidth;
        double screenY = (1 - 2 * ndcY) * camera.viewportHeight;

        // Create the direction vector
        Vector3 direction = Vector3(screenX, screenY, camera.focalLength)
            .rotateYawPitch(horizontalTiltAngle, verticalTiltAngle)
            .normalize();

        // Create the ray from the camera
        Ray ray = Ray(origin: camera.position, direction: direction);

        // Trace the ray and get the color
        Color pixelColor = internalScene.trace(ray, 0);

        // Set the paint color to the calculated pixel color
        paint.color = pixelColor;

        // Draw the pixel as a tiny rectangle
        canvas.drawRect(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), lowResFactor.toDouble(),
              lowResFactor.toDouble()),
          paint,
        );
      }
    }

    // Project the light's 3D position to 2D screen coordinates
    Offset light2D = projectTo2D(lightPosition, camera, size);

    // Check if the projected position is within the image bounds
    if (light2D.dx >= 0 &&
        light2D.dx <= size.width &&
        light2D.dy >= 0 &&
        light2D.dy <= size.height) {
      // Draw a small white circle to represent the light source
      Paint lightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      const double lightRadius = 5.0; // Radius of the light dot
      canvas.drawCircle(light2D, lightRadius, lightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ImagePainter oldDelegate) {
    return lightPosition != oldDelegate.lightPosition ||
        camera.horizontalTiltAngle != oldDelegate.camera.horizontalTiltAngle ||
        camera.verticalIiltAngle != oldDelegate.camera.verticalIiltAngle;
  }

  // Helper method to project 3D point to 2D
  Offset projectTo2D(Vector3 point, Camera camera, Size size) {
    Vector3 direction = point.subtract(camera.position).normalize();
    if (direction.z == 0) direction = Vector3(direction.x, direction.y, 1e-6);

    double scale = camera.focalLength / direction.z;
    double screenX = direction.x * scale;
    double screenY = direction.y * scale;

    double ndcX = (screenX / camera.viewportWidth) * 0.5 + 0.5;
    double ndcY = (-screenY / camera.viewportHeight) * 0.5 + 0.5;

    double pixelX = ndcX * size.width;
    double pixelY = (ndcY * size.height);

    return Offset(pixelX, pixelY); // Corrected projection
  }
}
