import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.brown, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
