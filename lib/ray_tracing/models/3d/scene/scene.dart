import 'dart:math';
import 'dart:ui';

import '../../maths/ray.dart';
import '../../maths/vector_3.dart';
import '../light.dart';
import '../scene_objects/plane.dart';
import '../scene_objects/scene_object.dart';
import '../scene_objects/sphere.dart';

class Scene {
  final List<SceneObject> objects;
  final Light light;
  final Color backgroundColor;
  final int maxDepth;

  Scene({
    required this.objects,
    required this.light,
    required this.backgroundColor,
    this.maxDepth = 3,
  });

  /// The ray tracing algorithm
  // The trace method for ray tracing
  Color trace(Ray ray, int depth) {
    // If maximum recursion depth is reached, return background color
    if (depth > maxDepth) return backgroundColor;

    // Find the closest intersection
    double closestDistance = double.infinity;
    SceneObject? closestObject;
    double? closestIntersection;

    for (var object in objects) {
      double? intersectionDistance = object.intersect(ray);
      if (intersectionDistance != null &&
          intersectionDistance < closestDistance) {
        closestDistance = intersectionDistance;
        closestObject = object;
        closestIntersection = intersectionDistance;
      }
    }

    // If no object is intersected, return the background color
    if (closestObject == null) {
      return backgroundColor;
    }

    // Calculate the hit point and the normal at the intersection
    Vector3 hitPoint =
        ray.origin.add(ray.direction.multiply(closestIntersection!));
    Vector3 normal;

    if (closestObject is Sphere) {
      normal = hitPoint.subtract((closestObject).center).normalize();
    } else if (closestObject is Cube) {
      normal = calculateCubeNormal(hitPoint, closestObject);
    } else if (closestObject is Plane) {
      normal = (closestObject).normal;
    } else {
      throw UnimplementedError(
          'Normal calculation not implemented for this object type');
    }

    // Calculate lighting (ambient + diffuse shading)
    Color objectColor = closestObject.color;
    Vector3 lightDirection = light.position.subtract(hitPoint).normalize();
    double diffuseFactor = max(normal.dot(lightDirection), 0.0);

    // Calculate ambient and diffuse color contributions
    int r = (objectColor.red * light.intensity * diffuseFactor)
        .clamp(0, 255)
        .toInt();
    int g = (objectColor.green * light.intensity * diffuseFactor)
        .clamp(0, 255)
        .toInt();
    int b = (objectColor.blue * light.intensity * diffuseFactor)
        .clamp(0, 255)
        .toInt();

    // Check for shadows
    if (isInShadow(hitPoint, light, objects)) {
      r = (r * 0.3).toInt(); // Reduce color for shadow effect
      g = (g * 0.3).toInt();
      b = (b * 0.3).toInt();
    }

    return Color.fromARGB(255, r, g, b);
  }

  // Determines whether the given point is in shadow
  bool isInShadow(Vector3 point, Light light, List<SceneObject> objects) {
    // Create a shadow ray from the intersection point toward the light source
    Vector3 shadowRayDirection = light.position.subtract(point).normalize();
    Ray shadowRay = Ray(
      origin: point.add(shadowRayDirection
          .multiply(1e-4)), // Slight offset to avoid self-shadowing
      direction: shadowRayDirection,
    );

    // Check if the shadow ray intersects any object
    for (var object in objects) {
      double? intersectionDistance = object.intersect(shadowRay);
      if (intersectionDistance != null && intersectionDistance > 0) {
        return true; // The point is in shadow
      }
    }

    return false; // No object blocks the light, so the point is lit
  }

  // Calculate the normal vector at a given point on the cube
  Vector3 calculateCubeNormal(Vector3 point, Cube cube) {
    // Determine which face of the cube was hit based on the point's proximity to the cube's planes
    const double epsilon = 1e-4;

    if ((point.x - cube.minCorner.x).abs() < epsilon) {
      return Vector3(-1, 0, 0); // Hit left face
    } else if ((point.x - cube.maxCorner.x).abs() < epsilon) {
      return Vector3(1, 0, 0); // Hit right face
    } else if ((point.y - cube.minCorner.y).abs() < epsilon) {
      return Vector3(0, -1, 0); // Hit bottom face
    } else if ((point.y - cube.maxCorner.y).abs() < epsilon) {
      return Vector3(0, 1, 0); // Hit top face
    } else if ((point.z - cube.minCorner.z).abs() < epsilon) {
      return Vector3(0, 0, -1); // Hit back face
    } else if ((point.z - cube.maxCorner.z).abs() < epsilon) {
      return Vector3(0, 0, 1); // Hit front face
    }

    // Fallback in case the exact face isn't detected
    return Vector3(0, 0, 0);
  }
}
