// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../managers/game_state.dart';
import '../managers/audio_manager.dart';

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

      // Play purchase SFX: cash register then receipt tear
      try {
        AudioManager().playSfx('sfx_cash_register.mp3');
      } catch (_) {}
      try {
        AudioManager().playSfx('sfx_receipt_tear.mp3');
      } catch (_) {}

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Try Again', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = GameState.cartItems;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/shop_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[300]);
              },
            ),
          ),

          /// TABLE BACKGROUND — properly fitted to avoid cutting
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/backgrounds/table_down_right.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: h * 0.4,
                  color: Colors.brown[200],
                );
              },
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
                cartItems[0]['imagePath'] ?? 'assets/albums/default_album.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.album, size: 40),
                  );
                },
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.brown),
                    ),
                    child: const Icon(Icons.receipt, size: 40),
                  );
                },
              ),
            ),

          /// BACK BUTTON
          Positioned(
            left: 16,
            top: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, size: 28),
              ),
            ),
          ),

          /// MAIN INTERFACE — Receipt Book Form
          if (!_showReceipt)
            SafeArea(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 600,
                    maxHeight: h * 0.85,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: w * 0.05,
                    vertical: h * 0.05,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8DC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.brown[700]!, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 28,
                              color: Colors.brown[700],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'RECEIPT BOOK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jeep Box Records',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.brown[600],
                          ),
                        ),
                        const Divider(thickness: 2, height: 20),

                        // Cart Item Display
                        if (cartItems.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.brown[300]!, width: 2),
                            ),
                            child: Row(
                              children: [
                                // Album cover
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      cartItems[0]['imagePath'] ??
                                          'assets/albums/default_album.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child:
                                              const Icon(Icons.album, size: 32),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Album info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Item in Cart:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        cartItems[0]['album'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'by ${cartItems[0]['artist'] ?? ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Instructions
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.amber[300]!, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.amber[800], size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Fill in the details below to complete the sale',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber[900],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Album input field
                        TextField(
                          controller: _albumController,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'Album Name',
                            labelStyle: TextStyle(color: Colors.brown[700]),
                            hintText: 'Enter album title',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.album,
                                color: Colors.brown[600], size: 22),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.brown[300]!, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.brown[700]!, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Artist input field
                        TextField(
                          controller: _artistController,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'Artist Name',
                            labelStyle: TextStyle(color: Colors.brown[700]),
                            hintText: 'Enter artist name',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.person,
                                color: Colors.brown[600], size: 22),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.brown[300]!, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.brown[700]!, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Submit button
                        ElevatedButton(
                          onPressed: _submitReceipt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Complete Purchase',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          /// SUCCESS ANIMATION OVERLAY
          if (_showReceipt)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Purchase Complete!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Record added to collection',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
