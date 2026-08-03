// lib/widgets/swipe_card_stack.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amalay_user/theme/app_colors.dart';

enum SwipeDirection { left, right }

/// Lets the action buttons trigger the same fling animation as a drag.
class SwipeCardController {
  _SwipeCardStackState? _state;

  Future<void> swipe(SwipeDirection direction) async {
    await _state?._flingOut(direction);
  }
}

/// Tinder-style draggable card stack: the top card follows the finger with
/// rotation, LIKE / NOPE stamps fade in with drag direction, and the card
/// behind scales up as the top card leaves.
class SwipeCardStack extends StatefulWidget {
  final Widget topCard;
  final Widget? behindCard;
  final bool enabled;

  /// Called after the fling-out animation completes.
  final void Function(SwipeDirection direction) onSwiped;

  /// Return false to veto a swipe before it animates (e.g. out of likes).
  final bool Function(SwipeDirection direction)? canSwipe;

  final SwipeCardController? controller;

  const SwipeCardStack({
    super.key,
    required this.topCard,
    required this.onSwiped,
    this.behindCard,
    this.enabled = true,
    this.canSwipe,
    this.controller,
  });

  @override
  State<SwipeCardStack> createState() => _SwipeCardStackState();
}

class _SwipeCardStackState extends State<SwipeCardStack>
    with SingleTickerProviderStateMixin {
  static const _flingDuration = Duration(milliseconds: 260);
  static const _springDuration = Duration(milliseconds: 220);

  late final AnimationController _controller;
  Animation<Offset>? _animation;
  Offset _drag = Offset.zero;
  bool _animatingOut = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _controller = AnimationController(vsync: this)
      ..addListener(() {
        if (_animation != null) {
          setState(() => _drag = _animation!.value);
        }
      });
  }

  @override
  void didUpdateWidget(covariant SwipeCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?._state = this;
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) {
      widget.controller?._state = null;
    }
    _controller.dispose();
    super.dispose();
  }

  double get _width => context.size?.width ?? 320;

  /// -1..1 horizontal progress toward a decision.
  double get _progress => (_drag.dx / (_width * 0.5)).clamp(-1.0, 1.0);

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _animatingOut) return;
    setState(() => _drag += details.delta);
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (!widget.enabled || _animatingOut) return;

    final velocityX = details.velocity.pixelsPerSecond.dx;
    final crossedDistance = _drag.dx.abs() > _width * 0.32;
    final flungFast = velocityX.abs() > 900;

    if (crossedDistance || flungFast) {
      final direction = (_drag.dx + velocityX * 0.1) >= 0
          ? SwipeDirection.right
          : SwipeDirection.left;
      await _flingOut(direction);
    } else {
      await _springBack();
    }
  }

  Future<void> _flingOut(SwipeDirection direction) async {
    if (_animatingOut) return;
    if (widget.canSwipe != null && !widget.canSwipe!(direction)) {
      await _springBack();
      return;
    }

    _animatingOut = true;
    final sign = direction == SwipeDirection.right ? 1.0 : -1.0;
    final end = Offset(sign * _width * 1.6, _drag.dy + 40);

    _animation = Tween(begin: _drag, end: end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    );
    _controller.duration = _flingDuration;
    await _controller.forward(from: 0);

    widget.onSwiped(direction);
    if (!mounted) return;
    setState(() {
      _drag = Offset.zero;
      _animation = null;
      _animatingOut = false;
    });
  }

  Future<void> _springBack() async {
    _animation = Tween(begin: _drag, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.duration = _springDuration;
    await _controller.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _drag = Offset.zero;
      _animation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final angle = progress * 0.18;
    final behindScale = 0.94 + 0.06 * progress.abs();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.behindCard != null)
          Transform.scale(
            scale: behindScale.clamp(0.94, 1.0),
            child: widget.behindCard!,
          ),
        Transform.translate(
          offset: _drag,
          child: Transform.rotate(
            angle: angle,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.topCard,
                  // LIKE stamp
                  Positioned(
                    top: 28,
                    left: 24,
                    child: _SwipeStamp(
                      label: 'LIKE',
                      color: AppColors.likeGreen,
                      opacity: progress.clamp(0.0, 1.0),
                      angle: -0.2,
                    ),
                  ),
                  // NOPE stamp
                  Positioned(
                    top: 28,
                    right: 24,
                    child: _SwipeStamp(
                      label: 'NOPE',
                      color: AppColors.nopeRed,
                      opacity: (-progress).clamp(0.0, 1.0),
                      angle: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  final String label;
  final Color color;
  final double opacity;
  final double angle;

  const _SwipeStamp({
    required this.label,
    required this.color,
    required this.opacity,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: math.min(1, opacity * 1.4),
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
