import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final int value;
  final bool isStatic;

  const TileWidget({
    super.key,
    required this.value,
    this.isStatic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(4.0), // slightly sharper corners like image
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: value > 100 ? 18 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // All text white
          ),
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFF65D2E9);
      case 4:
        return const Color(0xFF61E383);
      case 8:
        return const Color(0xFFF26786);
      case 16:
        return const Color(0xFF5ABEF6);
      case 32:
        return const Color(0xFFF68D32);
      case 64:
        return const Color(0xFFFA64DF);
      case 128:
        return const Color(0xFFF1D245);
      case 256:
        return const Color(0xFFE25B5B);
      case 512:
        return const Color(0xFF9E5BE2);
      case 1024:
        return const Color(0xFFE25B9E);
      case 2048:
        return const Color(0xFFE2C95B);
      default:
        return const Color(0xFF65D2E9); // fallback to 2 color
    }
  }
}
