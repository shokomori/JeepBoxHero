import 'package:flutter/material.dart';
import 'package:jeepboxhero/screens/cart_screen.dart';
import 'package:jeepboxhero/managers/game_state.dart';
// import 'package:jeepboxhero/screens/';

class ReceiptTableScreen extends StatefulWidget {
  final int encounterNumber;
  const ReceiptTableScreen({Key? key, required this.encounterNumber}) : super(key: key);

  @override
  State<ReceiptTableScreen> createState() => _ReceiptTableScreenState();
}

class _ReceiptTableScreenState extends State<ReceiptTableScreen> {
  bool _transactionComplete = false;
  int _dialogueIndex = 0;
  bool _showContinue = false;

  void _onPurchaseComplete() {
    setState(() {
      _transactionComplete = true;
      _dialogueIndex = 0;
      _showContinue = false;
    });
    _updateShowContinue();
    // Optionally, pop and notify parent to proceed to next dialogue
    Navigator.pop(context, 'purchase_complete');
  }

  void _updateShowContinue() {
    setState(() {
      _showContinue = !_transactionComplete;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/receipt_table.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/ui/back_arrow.png',
                width: w * 0.055,
                height: w * 0.055,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: w * 0.055,
                  height: w * 0.055,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_back, size: 30),
                ),
              ),
            ),
          ),
          //Top right: Cart icon with badge" section with this
Positioned.fill(
  child: Center(
    child: GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CartScreen(),
          ),
        );
        if (result == 'purchase_complete' && mounted) {
          _onPurchaseComplete();
        } else if (mounted) {
          setState(() {});
        }
      },
      child: Opacity(
        opacity: 0.0, 
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              'assets/ui/cart_icon.png',
              width: w * 0.8, 
              height: w * 0.8,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: w * 0.25,
                  height: w * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.grey[300]!.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    size: 60,
                    color: Colors.white70,
                  ),
                );
              },
            ),
            if (GameState.cartItems.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 26,
                    minHeight: 26,
                  ),
                  child: Text(
                    '${GameState.cartItems.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
