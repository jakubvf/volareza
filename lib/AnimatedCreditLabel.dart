import 'package:flutter/material.dart';

class AnimatedCreditLabel extends StatefulWidget {
  final double startValue;
  final double endValue;
  final Duration duration;
  final String prefix;
  final String suffix;
  final TextStyle? textStyle;
  final int decimals;

  const AnimatedCreditLabel({
    Key? key,
    required this.startValue,
    required this.endValue,
    this.duration = const Duration(milliseconds: 1500),
    this.prefix = '',
    this.suffix = '',
    this.textStyle,
    this.decimals = 2,
  }) : super(key: key);

  @override
  State<AnimatedCreditLabel> createState() => _AnimatedCreditLabelState();
}

class _AnimatedCreditLabelState extends State<AnimatedCreditLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.startValue,
      end: widget.endValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
      setState(() {});
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCreditLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endValue != widget.endValue) {
      _animation = Tween<double>(
        begin: oldWidget.endValue,
        end: widget.endValue,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.prefix}${_animation.value.toStringAsFixed(widget.decimals)}${widget.suffix}',
      style: widget.textStyle,
    );
  }
}