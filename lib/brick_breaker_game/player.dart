import 'package:flutter/material.dart';

class Player extends StatelessWidget {
  final double playerX;
  final double playerWidth;
  const Player({super.key, required this.playerX, required this.playerWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment:
          Alignment((2 * playerX + playerWidth) / (2 - playerWidth), 0.95),
      child: Container(
        height: 12,
        width: MediaQuery.sizeOf(context).width * playerWidth / 2,
        decoration: BoxDecoration(
            color: Colors.deepOrange, borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
