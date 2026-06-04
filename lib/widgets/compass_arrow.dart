import 'package:flutter/material.dart';
import 'dart:math' as math;

class CompassArrow extends StatelessWidget {
  final double targetBearing;
  final double currentHeading;
  final double size;

  const CompassArrow({
    super.key,
    required this.targetBearing,
    required this.currentHeading,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final angle = ((targetBearing - currentHeading) * math.pi / 180);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Transform.rotate(
            angle: angle,
            child: Icon(Icons.navigation, color: Colors.redAccent, size: size * 0.6),
          ),
        ],
      ),
    );
  }
}
