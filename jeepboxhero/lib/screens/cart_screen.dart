// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../managers/game_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  bool _showReceipt = false;

  @override
  void dispose() {
    _albumController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  void _submitReceipt() {
    final album = _albumController.text.trim().toLowerCase();
    final artist = _artistController.text.trim().toLowerCase();

    if (GameState.cartItems.isEmpty) {
      _showErrorDialog('Cart is empty!', 'Please find an album first.');
      return;
    }

    final cartItem = GameState.cartItems[0];
    final expectedAlbum = (cartItem['album'] as String).toLowerCase();
    final expectedArtist = (cartItem['artist'] as String).toLowerCase();

    if (album == expectedAlbum && artist == expectedArtist) {
      GameState.addRecord({
        'album': cartItem['album'],
        'artist': cartItem['artist'],
        'imagePath': cartItem['imagePath'],
      });
      GameState.clearCart();

      setState(() => _showReceipt = true);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.pop(context, 'purchase_complete');
      });
    } else {
      _showErrorDialog(
        'Not quite right...',
        'Double-check the album and artist name.',
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = GameState.cartItems;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final isLandscape = w > h;
          final scale = isLandscape ? h / 450 : w / 450;

          return Stack(
            children: [
              /// BACKGROUND
              Positioned.fill(
                child: Image.asset(
                  'assets/backgrounds/shop_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              /// TABLE BACKGROUND — covers 80% height max, keeps aspect ratio
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/backgrounds/table_down_right.png',
                  width: w,
                  height: h * 0.8,
                  fit: BoxFit.fitWidth,
                ),
              ),

              /// ALBUM IMAGE ON TABLE
              if (cartItems.isNotEmpty && !_showReceipt)
                Positioned(
                  left: w * 0.08,
                  bottom: h * 0.18,
                  width: w * 0.15,
                  height: w * 0.15,
                  child: Image.asset(
                    cartItems[0]['imagePath'] ??
                        'assets/albums/default_album.png',
                    fit: BoxFit.contain,
                  ),
                ),

              /// RECEIPT IMAGE (AFTER SUCCESS)
              if (_showReceipt && cartItems.isNotEmpty)
                Positioned(
                  right: w * 0.1,
                  bottom: h * 0.22,
                  width: w * 0.18,
                  height: w * 0.22,
                  child: Image.asset(
                    'assets/receipts/udd.png',
                    fit: BoxFit.contain,
                  ),
                ),

              /// MAIN INTERFACE — scrollable to prevent overflow
              if (!_showReceipt)
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.05,
                        vertical: h * 0.02,
                      ),
                      child: Container(
                        width: isLandscape ? w * 0.6 : w * 0.9,
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8DC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.brown, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '📖 RECEIPT BOOK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22 * scale,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                              ),
                            ),
                            SizedBox(height: 6 * scale),
                            Text(
                              'Jeep Box Records',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14 * scale,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Divider(thickness: 2, height: 18 * scale),
                            if (cartItems.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(10 * scale),
                                margin: EdgeInsets.only(bottom: 12 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.brown[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      cartItems[0]['imagePath'] ??
                                          'assets/albums/default_album.png',
                                      width: 55 * scale,
                                      height: 55 * scale,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(width: 10 * scale),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Item in Cart:',
                                            style: TextStyle(
                                              fontSize: 10 * scale,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            cartItems[0]['album'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14 * scale,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'by ${cartItems[0]['artist'] ?? ''}',
                                            style: TextStyle(
                                              fontSize: 12 * scale,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 8 * scale),
                            TextField(
                              controller: _albumController,
                              decoration: const InputDecoration(
                                labelText: 'Album',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 8 * scale),
                            TextField(
                              controller: _artistController,
                              decoration: const InputDecoration(
                                labelText: 'Artist',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12 * scale),
                            ElevatedButton(
                              onPressed: _submitReceipt,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12 * scale,
                                ),
                              ),
                              child: const Text('Complete Purchase'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
