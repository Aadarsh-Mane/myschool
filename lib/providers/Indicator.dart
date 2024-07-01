import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller!);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Dot(animation: _animation, delay: 0),
            Dot(animation: _animation, delay: 0.3),
            Dot(animation: _animation, delay: 0.6),
          ],
        );
      },
    );
  }
}

class Dot extends StatelessWidget {
  final Animation<double>? animation;
  final double delay;

  const Dot({Key? key, this.animation, required this.delay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation!,
        curve: Interval(delay, delay + 0.3, curve: Curves.easeInOut),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: CircleAvatar(
          radius: 3,
          backgroundColor: Colors.grey,
        ),
      ),
    );
  }
}
