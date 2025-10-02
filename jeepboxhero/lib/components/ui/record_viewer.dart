import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class DialogueBox extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback? onComplete;
  String displayedText = '';
  int currentCharIndex = 0;
  double charDelay = 0.03; // seconds per character
  double elapsed = 0;
  bool isComplete = false;

  DialogueBox({
    required this.text,
    required Vector2 position,
    required Vector2 size,
    this.onComplete,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background box
    final bg = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF2C3E50)
        ..style = PaintingStyle.fill,
    );
    await add(bg);

    // Border
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFFECF0F1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    await add(border);

    // Text will be rendered in render() method
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isComplete) return;

    elapsed += dt;

    if (elapsed >= charDelay && currentCharIndex < text.length) {
      displayedText += text[currentCharIndex];
      currentCharIndex++;
      elapsed = 0;

      if (currentCharIndex >= text.length) {
        isComplete = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render text
    final textPainter = TextPainter(
      text: TextSpan(
        text: displayedText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );

    textPainter.layout(maxWidth: size.x - 40);
    textPainter.paint(canvas, const Offset(20, 20));

    // Show "tap to continue" indicator when complete
    if (isComplete && onComplete != null) {
      final indicator = TextPainter(
        text: const TextSpan(
          text: '▼ Tap to continue',
          style: TextStyle(
            color: Color(0xFFECF0F1),
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      indicator.layout();
      indicator.paint(
        canvas,
        Offset(size.x - indicator.width - 10, size.y - 20),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isComplete) {
      // Skip animation
      displayedText = text;
      currentCharIndex = text.length;
      isComplete = true;
    } else if (onComplete != null) {
      onComplete!();
    }
  }
}
