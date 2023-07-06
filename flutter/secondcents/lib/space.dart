import 'package:flutter/material.dart';
import 'package:secondcents/schemas/space.dart' as space_schema;

class SpaceWidget extends StatefulWidget {
  const SpaceWidget({super.key});

  @override
  State<SpaceWidget> createState() => _SpaceWidgetState();
}

class _SpaceWidgetState extends State<SpaceWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print("Paint here");
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
