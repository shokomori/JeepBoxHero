// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Widget _asset({
    required String assetPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.withOpacity(0.3),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: _asset(
              assetPath: 'assets/backgrounds/shop_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Customer character - larger, no gap with table
          Positioned(
            left: w * 0.20,
            right: w * 0.20,
            top: h * 0.05,
            bottom: h * 0.28,
            child: _asset(
              assetPath: 'assets/characters/tito_ramon.png',
              fit: BoxFit.contain,
            ),
          ),

          // Table - positioned at bottom, smaller and lower
          Positioned(
            left: 0,
            right: 0,
            bottom: -h * 0.05,
            height: h * 0.38,
            child: _asset(
              assetPath: 'assets/ui/table.png',
              fit: BoxFit.fill,
            ),
          ),

          // Folder - bottom left, large and fully on table
          Positioned(
            left: w * 0.03,
            bottom: h * 0.05,
            width: w * 0.38,
            height: h * 0.46,
            child: GestureDetector(
              onTap: () => debugPrint('Folder tapped'),
              child: _asset(
                assetPath: 'assets/ui/closed_folder.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Cash box - far right, massive and extending off screen
          Positioned(
            right: -w * 0.15,
            bottom: -h * 0.03,
            width: w * 0.85,
            height: h * 0.65,
            child: GestureDetector(
              onTap: () => debugPrint('Cash box tapped'),
              child: _asset(
                assetPath: 'assets/ui/cash_box.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Top left icons
          Positioned(
            left: 16,
            top: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => debugPrint('Settings'),
                  child: _asset(
                    assetPath: 'assets/ui/settings_icon.png',
                    width: w * 0.055,
                    height: w * 0.055,
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: () => debugPrint('Tablet'),
                  child: _asset(
                    assetPath: 'assets/ui/tablet_icon.png',
                    width: w * 0.055,
                    height: w * 0.055,
                  ),
                ),
              ],
            ),
          ),

          // Top right icons
          Positioned(
            right: 16,
            top: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => debugPrint('Cart'),
                  child: _asset(
                    assetPath: 'assets/ui/cart_icon.png',
                    width: w * 0.055,
                    height: w * 0.055,
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: () => debugPrint('Records'),
                  child: _asset(
                    assetPath: 'assets/ui/records_icon.png',
                    width: w * 0.055,
                    height: w * 0.055,
                  ),
                ),
              ],
            ),
          ),

          // Back arrow - left middle
          Positioned(
            left: 16,
            top: h * 0.48,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: _asset(
                assetPath: 'assets/ui/back_arrow.png',
                width: w * 0.075,
                height: w * 0.075,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
