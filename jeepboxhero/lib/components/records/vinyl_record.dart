import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'album_data.dart';

class VinylRecord extends PositionComponent with TapCallbacks {
  final AlbumData albumData;
  final VoidCallback? onTap;
  bool isHovered = false;

  VinylRecord({
    required this.albumData,
    required Vector2 position,
    this.onTap,
  }) : super(
          position: position,
          size: Vector2(120, 180),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background card
    final card = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    await add(card);

    // Border
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    await add(border);

    // Album cover placeholder
    final coverBg = RectangleComponent(
      position: Vector2(10, 10),
      size: Vector2(100, 100),
      paint: Paint()..color = _getGenreColor(albumData.genre),
    );
    await add(coverBg);

    // Genre icon/letter
    final genreInitial = TextComponent(
      text: albumData.genre[0].toUpperCase(),
      position: Vector2(60, 60),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(genreInitial);

    // Title text
    final titleText = TextComponent(
      text: _truncate(albumData.title, 15),
      position: Vector2(60, 120),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(titleText);

    // Artist text
    final artistText = TextComponent(
      text: _truncate(albumData.artist, 15),
      position: Vector2(60, 135),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 8,
        ),
      ),
    );
    await add(artistText);

    // Price tag
    final priceText = TextComponent(
      text: '₱${albumData.price.toStringAsFixed(2)}',
      position: Vector2(60, 160),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(priceText);
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Color _getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'pinoy rock':
        return const Color(0xFFE74C3C);
      case 'opm pop':
        return const Color(0xFF3498DB);
      case 'kundiman':
        return const Color(0xFFE8C547);
      case 'folk':
        return const Color(0xFF27AE60);
      case 'rap':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call();
  }

  void onHoverEnter([dynamic _event]) {
    isHovered = true;
  }

  void onHoverExit([dynamic _event]) {
    isHovered = false;
  }

  @override
  void render(Canvas canvas) {
    if (isHovered) {
      canvas.drawRect(
        size.toRect(),
        Paint()
          ..color = Colors.yellow.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
    }
    super.render(canvas);
  }
}
