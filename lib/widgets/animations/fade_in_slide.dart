import 'package:flutter/material.dart';

class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delay;
  final double offset;
  final Curve curve;

  const FadeInSlide({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = 0.0,
    this.offset = 30.0,
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  _FadeInSlideState createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _translateY = Tween<double>(
      begin: widget.offset,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translateY.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}
