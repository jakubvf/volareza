import 'package:flutter/material.dart';

/// A label that animates between two values. Used for displaying credit.
/// Smoothly transitions to green when value increases, red when decreases,
/// and gradually reverts to default color when animation completes.
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
  late Animation<Color?> _colorAnimation;

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

    // Set up color animation
    _setupColorAnimation();

    _controller.forward();
  }

  void _setupColorAnimation() {
    final Color defaultColor = widget.textStyle?.color ?? Colors.black;
    Color targetColor = defaultColor;

    if (widget.endValue > widget.startValue) {
      targetColor = Colors.green;
    } else if (widget.endValue < widget.startValue) {
      targetColor = Colors.red;
    }

    // First half of animation: default color to target color
    // Second half: target color back to default color
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: defaultColor,
          end: targetColor,
        ),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: targetColor,
          end: defaultColor,
        ),
        weight: 90,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedCreditLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endValue != widget.endValue) {
      // Update value animation
      _animation = Tween<double>(
        begin: oldWidget.endValue,
        end: widget.endValue,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      // Update color animation
      _setupColorAnimation();

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
    // Create a new TextStyle that merges the provided style with our animated color
    final TextStyle effectiveStyle = (widget.textStyle ?? const TextStyle())
        .copyWith(color: _colorAnimation.value);

    return Text(
      '${widget.prefix}${_animation.value.toStringAsFixed(widget.decimals)}${widget.suffix}',
      style: effectiveStyle,
    );
  }
}