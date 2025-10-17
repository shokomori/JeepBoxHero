import 'package:flutter/material.dart';
import '../encounter1_screen.dart';
import '../../managers/game_state.dart';

class ReceiptTable1Screen extends StatelessWidget {
  const ReceiptTable1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pickedRecord = GameState.cartItems.isNotEmpty ? GameState.cartItems.first : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Table'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Encounter1Screen()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Show cart dialog with picked record
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cart'),
                  content: pickedRecord != null
                      ? Text('Picked Record: ${pickedRecord['album']} by ${pickedRecord['artist']}')
                      : const Text('No record picked.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Receipt clicked logic (expand as needed)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt clicked!')),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/receipts/receipt1.png', width: 300),
              const SizedBox(height: 16),
              const Text('Tap the receipt to interact'),
            ],
          ),
        ),
      ),
    );
  }
}
