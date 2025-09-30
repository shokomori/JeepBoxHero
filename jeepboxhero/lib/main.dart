// main.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'jeep_box_game.dart'; // Make sure this file contains the JeepBoxGame class

void main() {
  runApp(const JeepBoxApp());
}

class JeepBoxApp extends StatelessWidget {
  const JeepBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeep Box Hero',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: GameWidget(game: JeepBoxGame()),
      debugShowCheckedModeBanner: false,
    );
  }
}
