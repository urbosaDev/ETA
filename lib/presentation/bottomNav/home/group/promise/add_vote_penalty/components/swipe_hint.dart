import 'package:flutter/material.dart';

class SwipeHint extends StatelessWidget {
  final IconData icon;
  final String label;

  const SwipeHint({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0, bottom: 16),
        child: Column(
          children: [
            Text(
              '스와이프하면 $label로',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Icon(icon, size: 48, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
