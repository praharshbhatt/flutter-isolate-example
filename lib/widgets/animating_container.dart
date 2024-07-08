

import 'dart:async';

import 'package:flutter/material.dart';

class AnimatingContainer extends StatefulWidget {
  const AnimatingContainer({super.key});

  @override
  State<AnimatingContainer> createState() => _AnimatingContainerState();
}

class _AnimatingContainerState extends State<AnimatingContainer> {
  @override
  void initState() {
    _startAnimation();
    super.initState();
  }

  double _containerSize = 100.0;

  void _startAnimation() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (Timer t) {
      setState(() {
        _containerSize = _containerSize == 100.0 ? 200.0 : 100.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: _containerSize,
      height: _containerSize,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }
}
