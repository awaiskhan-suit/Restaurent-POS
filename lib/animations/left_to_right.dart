// lib/widgets/slide_in_from_left.dart
import 'package:flutter/material.dart';

/// Slides + fades its child in from the left, optionally after a delay.
/// Put it INSIDE a ClipRRect so the child is clipped while it slides.
class SlideInFromLeft extends StatefulWidget {
  const SlideInFromLeft({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.beginOffset = const Offset(-1, 0),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Start position as a fraction of the child's size (-1 = one full width left).
  final Offset beginOffset;

  @override
  State<SlideInFromLeft> createState() => _SlideInFromLeftState();
}

class _SlideInFromLeftState extends State<SlideInFromLeft>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    final total = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);

    // The delay is the first part of the timeline, so no Timer is needed.
    final start = widget.delay.inMilliseconds / total.inMilliseconds;

    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, start + (1 - start) * 0.6, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

