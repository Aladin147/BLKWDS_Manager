import 'package:flutter/material.dart';
import '../theme/blkwds_animations.dart';

/// Animated switcher component for BLKWDS Manager
///
/// Provides smooth transitions between different content states
class BLKWDSAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final BLKWDSSwitcherTransitionType transitionType;
  final Alignment alignment;
  final bool layoutBuilder;

  const BLKWDSAnimatedSwitcher({
    Key? key,
    required this.child,
    this.duration = BLKWDSAnimations.medium,
    this.curve = BLKWDSAnimations.standard,
    this.transitionType = BLKWDSSwitcherTransitionType.fade,
    this.alignment = Alignment.center,
    this.layoutBuilder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        switch (transitionType) {
          case BLKWDSSwitcherTransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case BLKWDSSwitcherTransitionType.scale:
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          case BLKWDSSwitcherTransitionType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          case BLKWDSSwitcherTransitionType.slideDown:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -0.2),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          case BLKWDSSwitcherTransitionType.slideLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.2, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          case BLKWDSSwitcherTransitionType.slideRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.2, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          case BLKWDSSwitcherTransitionType.rotation:
            return RotationTransition(
              turns: Tween<double>(
                begin: 0.1,
                end: 1.0,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
        }
      },
      layoutBuilder: layoutBuilder
          ? (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                alignment: alignment,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            }
          : null,
      child: child,
    );
  }
}

/// Transition types for animated switcher
enum BLKWDSSwitcherTransitionType {
  fade,
  scale,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  rotation,
}

/// Animated content switcher with custom transitions
class BLKWDSContentSwitcher extends StatefulWidget {
  final List<Widget> children;
  final int initialIndex;
  final Duration duration;
  final Curve curve;
  final BLKWDSSwitcherTransitionType transitionType;
  final ValueChanged<int>? onIndexChanged;
  final bool loop;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool pauseAutoPlayOnHover;

  const BLKWDSContentSwitcher({
    Key? key,
    required this.children,
    this.initialIndex = 0,
    this.duration = BLKWDSAnimations.medium,
    this.curve = BLKWDSAnimations.standard,
    this.transitionType = BLKWDSSwitcherTransitionType.fade,
    this.onIndexChanged,
    this.loop = false,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.pauseAutoPlayOnHover = true,
  })  : assert(children.isNotEmpty, 'Children cannot be empty'),
        assert(initialIndex >= 0 && initialIndex < children.length,
            'Initial index must be within the range of children'),
        super(key: key);

  @override
  State<BLKWDSContentSwitcher> createState() => _BLKWDSContentSwitcherState();
}

class _BLKWDSContentSwitcherState extends State<BLKWDSContentSwitcher> {
  late int _currentIndex;
  Timer? _autoPlayTimer;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _setupAutoPlay();
  }

  @override
  void didUpdateWidget(BLKWDSContentSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoPlay != oldWidget.autoPlay ||
        widget.autoPlayInterval != oldWidget.autoPlayInterval) {
      _cancelAutoPlay();
      _setupAutoPlay();
    }
    
    if (widget.children.length != oldWidget.children.length) {
      _currentIndex = _currentIndex.clamp(0, widget.children.length - 1);
    }
  }

  @override
  void dispose() {
    _cancelAutoPlay();
    super.dispose();
  }

  void _setupAutoPlay() {
    if (widget.autoPlay) {
      _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
        if (!widget.pauseAutoPlayOnHover || !_isHovered) {
          _nextContent();
        }
      });
    }
  }

  void _cancelAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _nextContent() {
    setState(() {
      if (_currentIndex < widget.children.length - 1) {
        _currentIndex++;
      } else if (widget.loop) {
        _currentIndex = 0;
      }
      
      if (widget.onIndexChanged != null) {
        widget.onIndexChanged!(_currentIndex);
      }
    });
  }

  void _previousContent() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else if (widget.loop) {
        _currentIndex = widget.children.length - 1;
      }
      
      if (widget.onIndexChanged != null) {
        widget.onIndexChanged!(_currentIndex);
      }
    });
  }

  void _goToContent(int index) {
    if (index >= 0 && index < widget.children.length && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        
        if (widget.onIndexChanged != null) {
          widget.onIndexChanged!(_currentIndex);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isHovered = true,
      onExit: (_) => _isHovered = false,
      child: Stack(
        children: [
          // Content
          BLKWDSAnimatedSwitcher(
            duration: widget.duration,
            curve: widget.curve,
            transitionType: widget.transitionType,
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: widget.children[_currentIndex],
            ),
          ),
          
          // Navigation buttons
          if (widget.children.length > 1)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentIndex > 0 || widget.loop
                        ? _previousContent
                        : null,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  
                  // Next button
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentIndex < widget.children.length - 1 || widget.loop
                        ? _nextContent
                        : null,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          
          // Indicators
          if (widget.children.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.children.length,
                  (index) => GestureDetector(
                    onTap: () => _goToContent(index),
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
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

/// Import for Timer
import 'dart:async';
