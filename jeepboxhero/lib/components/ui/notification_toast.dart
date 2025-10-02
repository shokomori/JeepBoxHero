import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NotificationToast extends PositionComponent {
  final String message;
  final Color backgroundColor;
  final double duration;

  double elapsed = 0;
  double opacity = 1.0;

  late RectangleComponent bg;
  late RectangleComponent border;

  NotificationToast({
    required this.message,
    required Vector2 position,
    this.backgroundColor = const Color(0xFF27AE60),
    this.duration = 2.0,
  }) : super(position: position, size: Vector2(300, 60), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Background
    bg = RectangleComponent(
      size: size,
      paint: Paint()..color = backgroundColor.withOpacity(opacity),
    );
    await add(bg);

    // Border
    border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    await add(border);

    // Message text
    final text = TextComponent(
      text: message,
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(text);
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsed += dt;

    // Fade out animation
    if (elapsed >= duration - 0.5) {
      final fadeAlpha = 1 - ((elapsed - (duration - 0.5)) / 0.5);
      opacity = fadeAlpha.clamp(0.0, 1.0);
      // Update opacity of background and border
      if (bg.paint.color.opacity != opacity) {
        bg.paint.color = backgroundColor.withOpacity(opacity);
        border.paint.color = Colors.white.withOpacity(opacity);
      }
    }

    if (elapsed >= duration) {
      removeFromParent();
    }
  }
}
