import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'customer_data.dart';

class Customer extends PositionComponent {
  final CustomerData data;

  Customer({
    required this.data,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(80, 120),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Customer sprite placeholder (replace with actual sprites)
    final body = RectangleComponent(
      size: size,
      paint: Paint()..color = _getPersonalityColor(data.personality),
    );
    await add(body);

    // Name label
    final nameTag = TextComponent(
      text: data.name,
      position: Vector2(size.x / 2, -10),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
        ),
      ),
    );
    await add(nameTag);
  }

  Color _getPersonalityColor(CustomerPersonality personality) {
    switch (personality) {
      case CustomerPersonality.nostalgic:
        return const Color(0xFFE8C547);
      case CustomerPersonality.enthusiastic:
        return const Color(0xFFE74C3C);
      case CustomerPersonality.mysterious:
        return const Color(0xFF6C3483);
      case CustomerPersonality.scholarly:
        return const Color(0xFF1F618D);
      case CustomerPersonality.shy:
        return const Color(0xFFAED6F1);
      case CustomerPersonality.demanding:
        return const Color(0xFF922B21);
    }
  }
}
