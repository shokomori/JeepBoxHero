import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../records/album_data.dart';

enum RecordViewMode {
  albumInfo,
  trackList,
  reviews,
}

class RecordViewer extends PositionComponent with TapCallbacks {
  final AlbumData album;
  RecordViewMode currentMode = RecordViewMode.albumInfo;
  final VoidCallback? onClose;
  final VoidCallback? onAddToCart;

  RecordViewer({
    required this.album,
    required Vector2 position,
    required Vector2 size,
    this.onClose,
    this.onAddToCart,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Semi-transparent backdrop
    final backdrop = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.7),
    );
    await add(backdrop);

    // Main content panel
    final panel = RectangleComponent(
      position: Vector2(size.x * 0.1, size.y * 0.1),
      size: Vector2(size.x * 0.8, size.y * 0.8),
      paint: Paint()..color = const Color(0xFFFFF8E7),
    );
    await add(panel);

    // Close button
    final closeBtn = TextComponent(
      text: '✕ Close',
      position: Vector2(size.x * 0.85, size.y * 0.12),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(closeBtn);

    // Add to Cart button
    final cartBtn = RectangleComponent(
      position: Vector2(size.x * 0.1 + 20, size.y * 0.8),
      size: Vector2(200, 40),
      paint: Paint()..color = const Color(0xFF27AE60),
    );
    await add(cartBtn);

    final cartBtnText = TextComponent(
      text: 'Add to Cart (₱${album.price.toStringAsFixed(2)})',
      position: Vector2(size.x * 0.1 + 110, size.y * 0.8 + 20),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(cartBtnText);

    // Tab buttons
    _addTabButton('Info', RecordViewMode.albumInfo, 0);
    _addTabButton('Tracks', RecordViewMode.trackList, 1);
    _addTabButton('Reviews', RecordViewMode.reviews, 2);
  }

  void _addTabButton(String label, RecordViewMode mode, int index) {
    final isActive = currentMode == mode;
    final btn = RectangleComponent(
      position: Vector2(size.x * 0.1 + (index * 120), size.y * 0.15),
      size: Vector2(110, 30),
      paint: Paint()
        ..color = isActive ? const Color(0xFF3498DB) : const Color(0xFFBDC3C7),
    );
    add(btn);

    final btnText = TextComponent(
      text: label,
      position: Vector2(size.x * 0.1 + (index * 120) + 55, size.y * 0.15 + 15),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(btnText);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final contentX = size.x * 0.1 + 20;
    final contentY = size.y * 0.2;
    final contentWidth = size.x * 0.8 - 40;

    switch (currentMode) {
      case RecordViewMode.albumInfo:
        _renderAlbumInfo(canvas, contentX, contentY, contentWidth);
        break;
      case RecordViewMode.trackList:
        _renderTrackList(canvas, contentX, contentY, contentWidth);
        break;
      case RecordViewMode.reviews:
        _renderReviews(canvas, contentX, contentY, contentWidth);
        break;
    }
  }

  void _renderAlbumInfo(Canvas canvas, double x, double y, double width) {
    // Album title
    var painter = TextPainter(
      text: TextSpan(
        text: album.title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, Offset(x, y));
    y += painter.height + 10;

    // Artist
    painter = TextPainter(
      text: TextSpan(
        text: 'by ${album.artist}',
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 18,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, Offset(x, y));
    y += painter.height + 20;

    // Genre and Year
    painter = TextPainter(
      text: TextSpan(
        text: '${album.genre} • ${album.releaseYear}',
        style: const TextStyle(
          color: Color(0xFF3498DB),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, Offset(x, y));
    y += painter.height + 20;

    // Description
    painter = TextPainter(
      text: TextSpan(
        text: album.description,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, Offset(x, y));
    y += painter.height + 20;

    // Artist Bio
    painter = TextPainter(
      text: const TextSpan(
        text: 'About the Artist',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, Offset(x, y));
    y += painter.height + 10;

    painter = TextPainter(
      text: TextSpan(
        text: album.artistBio,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, Offset(x, y));
  }

  void _renderTrackList(Canvas canvas, double x, double y, double width) {
    var painter = TextPainter(
      text: const TextSpan(
        text: 'Track Listing',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, Offset(x, y));
    y += painter.height + 20;

    for (var i = 0; i < album.trackList.length; i++) {
      painter = TextPainter(
        text: TextSpan(
          text: '${i + 1}. ${album.trackList[i]}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: width);
      painter.paint(canvas, Offset(x + 10, y));
      y += painter.height + 5;
    }
  }

  void _renderReviews(Canvas canvas, double x, double y, double width) {
    var painter = TextPainter(
      text: const TextSpan(
        text: 'Reviews',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    painter.paint(canvas, Offset(x, y));
    y += painter.height + 20;

    for (final review in album.reviews) {
      // Stars
      final stars = '★' * review.rating + '☆' * (5 - review.rating);
      painter = TextPainter(
        text: TextSpan(
          text: stars,
          style: const TextStyle(
            color: Color(0xFFF39C12),
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: width);
      painter.paint(canvas, Offset(x, y));
      y += painter.height + 5;

      // Reviewer
      painter = TextPainter(
        text: TextSpan(
          text: '— ${review.reviewer}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: width);
      painter.paint(canvas, Offset(x, y));
      y += painter.height + 5;

      // Review text
      painter = TextPainter(
        text: TextSpan(
          text: '"${review.text}"',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: width);
      painter.paint(canvas, Offset(x + 10, y));
      y += painter.height + 25;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapPos = event.localPosition;

    // Check close button
    if (tapPos.x >= size.x * 0.82 &&
        tapPos.x <= size.x * 0.9 &&
        tapPos.y >= size.y * 0.11 &&
        tapPos.y <= size.y * 0.14) {
      onClose?.call();
      return;
    }

    // Check add to cart button
    if (tapPos.x >= size.x * 0.1 + 20 &&
        tapPos.x <= size.x * 0.1 + 220 &&
        tapPos.y >= size.y * 0.8 &&
        tapPos.y <= size.y * 0.8 + 40) {
      onAddToCart?.call();
      return;
    }

    // Check tab buttons
    for (var i = 0; i < 3; i++) {
      final tabX = size.x * 0.1 + (i * 120);
      if (tapPos.x >= tabX &&
          tapPos.x <= tabX + 110 &&
          tapPos.y >= size.y * 0.15 &&
          tapPos.y <= size.y * 0.15 + 30) {
        currentMode = RecordViewMode.values[i];
        removeAll(children);
        onLoad();
        return;
      }
    }
  }
}
