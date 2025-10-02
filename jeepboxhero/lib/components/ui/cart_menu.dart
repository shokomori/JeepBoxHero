import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../records/album_data.dart';

class CartMenu extends PositionComponent with TapCallbacks {
  final List<AlbumData> items;
  final VoidCallback? onCheckout;
  final VoidCallback? onClose;

  CartMenu({
    required this.items,
    required Vector2 position,
    required Vector2 size,
    this.onCheckout,
    this.onClose,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background
    final bg = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF34495E),
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

    // Header
    final header = TextComponent(
      text: '🛒 Shopping Cart',
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(header);

    // Close button
    final closeBtn = TextComponent(
      text: '✕',
      position: Vector2(size.x - 20, 20),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    await add(closeBtn);

    // Checkout button (if items exist)
    if (items.isNotEmpty) {
      final checkoutBtn = RectangleComponent(
        position: Vector2(20, size.y - 60),
        size: Vector2(size.x - 40, 40),
        paint: Paint()..color = const Color(0xFF27AE60),
      );
      await add(checkoutBtn);

      final total = items.fold<double>(0, (sum, item) => sum + item.price);
      final checkoutText = TextComponent(
        text: 'Proceed to Checkout (₱${total.toStringAsFixed(2)})',
        position: Vector2(size.x / 2, size.y - 40),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      await add(checkoutText);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (items.isEmpty) {
      final painter = TextPainter(
        text: const TextSpan(
          text: 'Cart is empty',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size.x / 2 - painter.width / 2, size.y / 2),
      );
    } else {
      var y = 60.0;
      for (final item in items) {
        _renderCartItem(canvas, item, y);
        y += 60;
      }
    }
  }

  void _renderCartItem(Canvas canvas, AlbumData item, double y) {
    // Item background
    canvas.drawRect(
      Rect.fromLTWH(20, y, size.x - 40, 50),
      Paint()..color = const Color(0xFF2C3E50),
    );

    // Title
    var painter = TextPainter(
      text: TextSpan(
        text: item.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, Offset(30, y + 10));

    // Artist
    painter = TextPainter(
      text: TextSpan(
        text: item.artist,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, Offset(30, y + 28));

    // Price
    painter = TextPainter(
      text: TextSpan(
        text: '₱${item.price.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Color(0xFF27AE60),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, Offset(size.x - painter.width - 30, y + 18));
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapPos = event.localPosition;

    // Check close button
    if (tapPos.x >= size.x - 30 && tapPos.y <= 30) {
      onClose?.call();
      return;
    }

    // Check checkout button
    if (items.isNotEmpty &&
        tapPos.y >= size.y - 60 &&
        tapPos.y <= size.y - 20) {
      onCheckout?.call();
    }
  }
}
