import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/shop/record_shelf.dart';
import '../components/ui/dialogue_box.dart';
import '../components/ui/record_viewer.dart';
import '../components/ui/cart_menu.dart';
import '../components/ui/receipt_book.dart';
import '../components/customer/customer.dart';
import '../components/customer/customer_data.dart';
import '../components/records/album_data.dart';
import '../managers/game_state_manager.dart';

class ShopScreen extends PositionComponent with HasGameRef {
  late RecordShelf recordShelf;
  Customer? currentCustomer;
  DialogueBox? dialogueBox;
  RecordViewer? recordViewer;
  CartMenu? cartMenu;
  ReceiptBook? receiptBook;

  final List<AlbumData> cartItems = [];
  CustomerData? currentCustomerData;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = gameRef.size;

    // Add shop sign
    final shopSign = TextComponent(
      text: '♫ JEEP BOX RECORDS ♫',
      position: Vector2(gameRef.size.x / 2, 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
        ),
      ),
    );
    await add(shopSign);

    // Add cart button (top right)
    _addCartButton();

    // Add record shelves
    recordShelf = RecordShelf(
      position: Vector2(50, 100),
      onRecordTap: _onRecordTapped,
    );
    await add(recordShelf);

    // Spawn first customer after brief delay
    Future.delayed(const Duration(seconds: 2), () {
      spawnCustomer();
    });
  }

  void _addCartButton() {
    final cartBtn = RectangleComponent(
      position: Vector2(gameRef.size.x - 120, 20),
      size: Vector2(100, 40),
      paint: Paint()..color = const Color(0xFF3498DB),
    );
    add(cartBtn);

    final cartText = TextComponent(
      text: '🛒 Cart (${cartItems.length})',
      position: Vector2(gameRef.size.x - 70, 40),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(cartText);
  }

  void _onRecordTapped(AlbumData album) {
    // Show record detail viewer
    recordViewer?.removeFromParent();

    recordViewer = RecordViewer(
      album: album,
      position: Vector2.zero(),
      size: gameRef.size,
      onClose: () {
        recordViewer?.removeFromParent();
        recordViewer = null;
      },
      onAddToCart: () {
        _addToCart(album);
        recordViewer?.removeFromParent();
        recordViewer = null;
      },
    );

    add(recordViewer!);
  }

  void _addToCart(AlbumData album) {
    if (!cartItems.contains(album)) {
      cartItems.add(album);

      // Update cart button display
      children.whereType<RectangleComponent>().forEach((comp) {
        if (comp.position.x > gameRef.size.x - 150) {
          comp.removeFromParent();
        }
      });
      _addCartButton();

      // Show feedback
      showDialogue('Added ${album.title} to cart!', null);

      Future.delayed(const Duration(seconds: 2), () {
        hideDialogue();
      });
    }
  }

  void _openCart() {
    cartMenu?.removeFromParent();

    cartMenu = CartMenu(
      items: cartItems,
      position: Vector2(gameRef.size.x - 320, 70),
      size: Vector2(300, 400),
      onClose: () {
        cartMenu?.removeFromParent();
        cartMenu = null;
      },
      onCheckout: () {
        cartMenu?.removeFromParent();
        cartMenu = null;
        _startCheckout();
      },
    );

    add(cartMenu!);
  }

  void _startCheckout() {
    if (cartItems.isEmpty) return;

    hideDialogue();

    // Show receipt book
    receiptBook = ReceiptBook(
      purchasedAlbums: cartItems,
      position: Vector2(gameRef.size.x / 2 - 200, gameRef.size.y / 2 - 250),
      size: Vector2(400, 500),
      onComplete: () {
        _completeTransaction();
      },
    );

    add(receiptBook!);
  }

  void _completeTransaction() {
    receiptBook?.removeFromParent();
    receiptBook = null;

    // Show customer's after-purchase dialogue
    if (currentCustomerData != null) {
      showDialogue(currentCustomerData!.afterPurchaseDialogue, () {
        _customerLeaves();
      });
    } else {
      _customerLeaves();
    }
  }

  void _customerLeaves() {
    hideDialogue();

    // Animate customer leaving
    currentCustomer?.removeFromParent();
    currentCustomer = null;
    currentCustomerData = null;

    // Clear cart
    cartItems.clear();
    children.whereType<RectangleComponent>().forEach((comp) {
      if (comp.position.x > gameRef.size.x - 150) {
        comp.removeFromParent();
      }
    });
    _addCartButton();

    // Spawn next customer after delay
    Future.delayed(const Duration(seconds: 3), () {
      spawnCustomer();
    });
  }

  void spawnCustomer() {
    final customerData = CustomerDatabase.getRandomCustomer();
    currentCustomerData = customerData;

    currentCustomer = Customer(
      data: customerData,
      position: Vector2(gameRef.size.x / 2, gameRef.size.y - 150),
    );

    add(currentCustomer!);

    // Show intro dialogue
    showDialogue(customerData.intro, () {
      // After intro, show request
      showDialogue(customerData.requestDialogue, null);
    });
  }

  void showDialogue(String text, VoidCallback? onComplete) {
    dialogueBox?.removeFromParent();

    dialogueBox = DialogueBox(
      text: text,
      position: Vector2(20, gameRef.size.y - 120),
      size: Vector2(gameRef.size.x - 40, 100),
      onComplete: onComplete,
    );

    add(dialogueBox!);
  }

  void hideDialogue() {
    dialogueBox?.removeFromParent();
    dialogueBox = null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle tap on cart button (simple collision check)
    // In production, you'd use proper tap detection
  }
}
