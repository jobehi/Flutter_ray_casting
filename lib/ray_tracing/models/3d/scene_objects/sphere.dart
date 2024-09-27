// Sphere class
import 'dart:math';

import '../../maths/ray.dart';
import '../../maths/vector_3.dart';
import 'scene_object.dart';

class Sphere extends SceneObject {
  final Vector3 center;
  final double radius;

  Sphere({
    required this.center,
    required this.radius,
    required super.color,
  });

  @override
  double? intersect(Ray ray) {
    Vector3 rayToCenter = ray.origin.subtract(center);
    double directionDot = ray.direction.dot(ray.direction);
    double rayOriginDot = 2.0 * rayToCenter.dot(ray.direction);
    double centerDistanceSquared =
        rayToCenter.dot(rayToCenter) - radius * radius;
    double discriminant =
        rayOriginDot * rayOriginDot - 4 * directionDot * centerDistanceSquared;

    if (discriminant < 0) {
      return null;
    }

    double sqrtDiscriminant = sqrt(discriminant);
    double intersection1 =
        (-rayOriginDot - sqrtDiscriminant) / (2.0 * directionDot);
    double intersection2 =
        (-rayOriginDot + sqrtDiscriminant) / (2.0 * directionDot);

    if (intersection1 > 0.001) return intersection1;
    if (intersection2 > 0.001) return intersection2;
    return null;
  }
}

class Cube extends SceneObject {
  final Vector3 minCorner; // Minimum corner (xMin, yMin, zMin)
  final Vector3 maxCorner; // Maximum corner (xMax, yMax, zMax)

  Cube({
    required this.minCorner,
    required this.maxCorner,
    required super.color,
  });

  @override
  double? intersect(Ray ray) {
    // Calculate intersection distances for each axis
    double tMinX = (minCorner.x - ray.origin.x) / ray.direction.x;
    double tMaxX = (maxCorner.x - ray.origin.x) / ray.direction.x;

    if (tMinX > tMaxX) {
      double temp = tMinX;
      tMinX = tMaxX;
      tMaxX = temp;
    }

    double tMinY = (minCorner.y - ray.origin.y) / ray.direction.y;
    double tMaxY = (maxCorner.y - ray.origin.y) / ray.direction.y;

    if (tMinY > tMaxY) {
      double temp = tMinY;
      tMinY = tMaxY;
      tMaxY = temp;
    }

    // Check if there's any overlap in the t values for X and Y
    if ((tMinX > tMaxY) || (tMinY > tMaxX)) {
      return null;
    }

    // Find the intersection interval on the XY plane
    double tMin = max(tMinX, tMinY);
    double tMax = min(tMaxX, tMaxY);

    double tMinZ = (minCorner.z - ray.origin.z) / ray.direction.z;
    double tMaxZ = (maxCorner.z - ray.origin.z) / ray.direction.z;

    if (tMinZ > tMaxZ) {
      double temp = tMinZ;
      tMinZ = tMaxZ;
      tMaxZ = temp;
    }

    // Check if there's any overlap in the t values for the XYZ planes
    if ((tMin > tMaxZ) || (tMinZ > tMax)) {
      return null;
    }

    tMin = max(tMin, tMinZ);
    tMax = min(tMax, tMaxZ);

    // Return the nearest valid intersection point
    if (tMin > 0.001) return tMin;
    if (tMax > 0.001) return tMax;

    return null;
  }
}
