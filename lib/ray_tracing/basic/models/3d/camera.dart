// Camera class
import '../maths/vector_3.dart';

class Camera {
  final Vector3 position;
  final double viewportWidth;
  final double viewportHeight;
  final double focalLength;
  final double verticalIiltAngle; // Added tilt angle in radians
  final double horizontalTiltAngle; // Added horizontal tilt angle in radians

  Camera({
    required this.position,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.focalLength,
    this.verticalIiltAngle = 0.0, // Default to no tilt
    this.horizontalTiltAngle = 0.0, // Default to no tilt
  });

  Camera copyWith({
    Vector3? position,
    double? viewportWidth,
    double? viewportHeight,
    double? focalLength,
    double? verticalIiltAngle,
    double? horizontalTiltAngle,
  }) {
    return Camera(
      position: position ?? this.position,
      viewportWidth: viewportWidth ?? this.viewportWidth,
      viewportHeight: viewportHeight ?? this.viewportHeight,
      focalLength: focalLength ?? this.focalLength,
      verticalIiltAngle: verticalIiltAngle ?? this.verticalIiltAngle,
      horizontalTiltAngle: horizontalTiltAngle ?? this.horizontalTiltAngle,
    );
  }
}
