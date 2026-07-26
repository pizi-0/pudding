import 'dart:math';

import 'package:flutter/material.dart';

class BouncingWidgetScreen extends StatefulWidget {
  const BouncingWidgetScreen({super.key});

  @override
  State<BouncingWidgetScreen> createState() => _BouncingWidgetScreenState();
}

class _BouncingWidgetScreenState extends State<BouncingWidgetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Widget dimensions
  final double _widgetWidth = 100.0;
  final double _widgetHeight = 60.0;

  // Position coordinates
  double _posX = 0.0;
  double _posY = 0.0;

  // Velocity vectors (pixels per frame step)
  double _velX = 2.0;
  double _velY = 2.0;

  // Visual properties
  Color _widgetColor = Colors.blue;
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    // Endless animation loop to drive the physics update
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(_updatePhysics);
    _controller.repeat();
  }

  void _updatePhysics() {
    // Get total available screen space
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Safe boundaries considering widget dimensions
    final double maxExtentX = screenWidth - _widgetWidth;
    final double maxExtentY = screenHeight - _widgetHeight;

    setState(() {
      // Move the widget
      _posX += _velX;
      _posY += _velY;

      bool bounced = false;

      // Check horizontal collisions
      if (_posX <= 0) {
        _posX = 0;
        _velX = -_velX;
        bounced = true;
      } else if (_posX >= maxExtentX) {
        _posX = maxExtentX;
        _velX = -_velX;
        bounced = true;
      }

      // Check vertical collisions
      if (_posY <= 0) {
        _posY = 0;
        _velY = -_velY;
        bounced = true;
      } else if (_posY >= maxExtentY) {
        _posY = maxExtentY;
        _velY = -_velY;
        bounced = true;
      }

      // Cycle color if a wall was hit
      if (bounced) {
        _changeColor();
      }
    });
  }

  void _changeColor() {
    final random = Random();
    Color nextColor;
    do {
      nextColor = _colors[random.nextInt(_colors.length)];
    } while (nextColor == _widgetColor); // Ensure color actually changes

    _widgetColor = nextColor;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Classic DVD background
      body: Stack(
        children: [
          Positioned(
            left: _posX,
            top: _posY,
            child: Container(
              width: _widgetWidth,
              height: _widgetHeight,
              decoration: BoxDecoration(
                color: _widgetColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'DVD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
