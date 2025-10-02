import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

enum InteractiveType {
  tamagotchi,
  poster,
  stereo,
  plant,
  clock,
}

class InteractiveObject extends PositionComponent with TapCallbacks {
  final InteractiveType type;
  final String description;
  final VoidCallback? onInteract;

  InteractiveObject({
    required this.type,
    required this.description,
    required Vector2 position,
    required Vector2 size,
    this.onInteract,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Object visual representation
    final bg = RectangleComponent(
      size: size,
      paint: Paint()..color = _getObjectColor(),
    );
    await add(bg);

    // Icon
    final icon = TextComponent(
      text: _getObjectIcon(),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
    await add(icon);
  }

  Color _getObjectColor() {
    switch (type) {
      case InteractiveType.tamagotchi:
        return const Color(0xFFE74C3C);
      case InteractiveType.poster:
        return const Color(0xFF3498DB);
      case InteractiveType.stereo:
        return const Color(0xFF2C3E50);
      case InteractiveType.plant:
        return const Color(0xFF27AE60);
      case InteractiveType.clock:
        return const Color(0xFFF39C12);
    }
  }

  String _getObjectIcon() {
    switch (type) {
      case InteractiveType.tamagotchi:
        return '🎮';
      case InteractiveType.poster:
        return '🎸';
      case InteractiveType.stereo:
        return '📻';
      case InteractiveType.plant:
        return '🌿';
      case InteractiveType.clock:
        return '🕐';
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onInteract?.call();
    print('Interacted with: $description');
  }
}
