class Explosion {
  double x;
  double y;
  int currentFrame;
  final int totalFrames;
  double frameDuration;
  double timeSinceLastFrame;

  Explosion({
    required this.x,
    required this.y,
    required this.totalFrames,
    required this.frameDuration,
  })  : currentFrame = 0,
        timeSinceLastFrame = 0;
}
