// Plane class

import '../../maths/ray.dart';
import '../../maths/vector_3.dart';
import 'scene_object.dart';

class Plane extends SceneObject {
  final Vector3 point; // A point on the plane
  final Vector3 normal;

  Plane({
    required this.point,
    required this.normal,
    required super.color,
  });

  @override
  double? intersect(Ray ray) {
    double denom = normal.dot(ray.direction);
    if (denom.abs() > 1e-6) {
      double t = (point.subtract(ray.origin)).dot(normal) / denom;
      if (t >= 0.001) return t;
    }
    return null;
  }
}
