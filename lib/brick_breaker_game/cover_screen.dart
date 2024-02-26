import 'package:flutter/material.dart';

class CoverScreen extends StatelessWidget {
  final bool isGameStarted;
  const CoverScreen({super.key, required this.isGameStarted});

  @override
  Widget build(BuildContext context) {
    return isGameStarted
        ? const SizedBox()
        : Container(
            alignment: const Alignment(0, -0.1),
            child: const Text(
              'Tap to play',
              style: TextStyle(color: Colors.deepOrange, fontSize: 30),
            ),
          );
  }
}
