import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset("assets/images/menu_bg.png", fit: BoxFit.cover),
          ),

          // Semi-transparent golden menu bar
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 250,
              color: Colors.orange.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuButton("CONTINUE", () {
                    // TODO: Continue logic
                  }),
                  const SizedBox(height: 20),
                  _menuButton("NEW GAME", () {
                    // TODO: Start new game
                  }),
                  const SizedBox(height: 20),
                  _menuButton("EXIT", () {
                    // TODO: Exit app
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for buttons
  Widget _menuButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
