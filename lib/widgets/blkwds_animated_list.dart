import 'package:flutter/material.dart';
import '../theme/blkwds_animations.dart';

/// Animated list component for BLKWDS Manager
///
/// Provides staggered animations for list items with customizable animation parameters
class BLKWDSAnimatedList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDuration;
  final Duration itemDuration;
  final Curve curve;
  final Axis direction;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? separator;
  final Widget? emptyWidget;
  final bool animateOnlyOnce;
  final BLKWDSListAnimationType animationType;

  const BLKWDSAnimatedList({
    Key? key,
    required this.children,
    this.staggerDuration = const Duration(milliseconds: 50),
    this.itemDuration = BLKWDSAnimations.medium,
    this.curve = BLKWDSAnimations.standard,
    this.direction = Axis.vertical,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.separator,
    this.emptyWidget,
    this.animateOnlyOnce = true,
    this.animationType = BLKWDSListAnimationType.fadeSlide,
  }) : super(key: key);

  @override
  State<BLKWDSAnimatedList> createState() => _BLKWDSAnimatedListState();
}

class _BLKWDSAnimatedListState extends State<BLKWDSAnimatedList> with SingleTickerProviderStateMixin {
  late List<GlobalKey<_AnimatedListItemState>> _itemKeys;
  bool _hasAnimatedOnce = false;

  @override
  void initState() {
    super.initState();
    _initializeItemKeys();
  }

  @override
  void didUpdateWidget(BLKWDSAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _initializeItemKeys();
    }
  }

  void _initializeItemKeys() {
    _itemKeys = List.generate(
      widget.children.length,
      (index) => GlobalKey<_AnimatedListItemState>(),
    );
    
    // Trigger animations
    if (!_hasAnimatedOnce || !widget.animateOnlyOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (int i = 0; i < _itemKeys.length; i++) {
          Future.delayed(widget.staggerDuration * i, () {
            if (_itemKeys[i].currentState != null && mounted) {
              _itemKeys[i].currentState!.startAnimation();
            }
          });
        }
      });
      _hasAnimatedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    final listItems = List.generate(
      widget.children.length,
      (index) => _AnimatedListItem(
        key: _itemKeys[index],
        child: widget.children[index],
        duration: widget.itemDuration,
        curve: widget.curve,
        direction: widget.direction,
        animationType: widget.animationType,
        skipAnimation: _hasAnimatedOnce && widget.animateOnlyOnce,
      ),
    );

    if (widget.separator != null) {
      final separatedItems = <Widget>[];
      for (int i = 0; i < listItems.length; i++) {
        separatedItems.add(listItems[i]);
        if (i < listItems.length - 1) {
          separatedItems.add(widget.separator!);
        }
      }
      
      return _buildList(separatedItems);
    }

    return _buildList(listItems);
  }

  Widget _buildList(List<Widget> items) {
    if (widget.direction == Axis.vertical) {
      return ListView(
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        children: items,
      );
    } else {
      return ListView(
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        scrollDirection: Axis.horizontal,
        children: items,
      );
    }
  }
}

/// Animation types for list items
enum BLKWDSListAnimationType {
  fade,
  slide,
  scale,
  fadeSlide,
  fadeScale,
}

/// Animated list item
class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Axis direction;
  final BLKWDSListAnimationType animationType;
  final bool skipAnimation;

  const _AnimatedListItem({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
    required this.direction,
    required this.animationType,
    this.skipAnimation = false,
  }) : super(key: key);

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.direction == Axis.vertical
          ? const Offset(0.0, 0.25)
          : const Offset(0.25, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.skipAnimation) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (!_isAnimating && _controller.status != AnimationStatus.completed) {
      _isAnimating = true;
      _controller.forward().then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget animatedChild = widget.child;

    switch (widget.animationType) {
      case BLKWDSListAnimationType.fade:
        animatedChild = FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        );
        break;
      case BLKWDSListAnimationType.slide:
        animatedChild = SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        );
        break;
      case BLKWDSListAnimationType.scale:
        animatedChild = ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        );
        break;
      case BLKWDSListAnimationType.fadeSlide:
        animatedChild = FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
        break;
      case BLKWDSListAnimationType.fadeScale:
        animatedChild = FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
        break;
    }

    return animatedChild;
  }
}

/// Grid version of BLKWDSAnimatedList
class BLKWDSAnimatedGrid extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDuration;
  final Duration itemDuration;
  final Curve curve;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? emptyWidget;
  final bool animateOnlyOnce;
  final BLKWDSListAnimationType animationType;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const BLKWDSAnimatedGrid({
    Key? key,
    required this.children,
    required this.crossAxisCount,
    this.staggerDuration = const Duration(milliseconds: 50),
    this.itemDuration = BLKWDSAnimations.medium,
    this.curve = BLKWDSAnimations.standard,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.emptyWidget,
    this.animateOnlyOnce = true,
    this.animationType = BLKWDSListAnimationType.fadeSlide,
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  @override
  State<BLKWDSAnimatedGrid> createState() => _BLKWDSAnimatedGridState();
}

class _BLKWDSAnimatedGridState extends State<BLKWDSAnimatedGrid> with SingleTickerProviderStateMixin {
  late List<GlobalKey<_AnimatedListItemState>> _itemKeys;
  bool _hasAnimatedOnce = false;

  @override
  void initState() {
    super.initState();
    _initializeItemKeys();
  }

  @override
  void didUpdateWidget(BLKWDSAnimatedGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _initializeItemKeys();
    }
  }

  void _initializeItemKeys() {
    _itemKeys = List.generate(
      widget.children.length,
      (index) => GlobalKey<_AnimatedListItemState>(),
    );
    
    // Trigger animations
    if (!_hasAnimatedOnce || !widget.animateOnlyOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (int i = 0; i < _itemKeys.length; i++) {
          Future.delayed(widget.staggerDuration * i, () {
            if (_itemKeys[i].currentState != null && mounted) {
              _itemKeys[i].currentState!.startAnimation();
            }
          });
        }
      });
      _hasAnimatedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    final gridItems = List.generate(
      widget.children.length,
      (index) => _AnimatedListItem(
        key: _itemKeys[index],
        child: widget.children[index],
        duration: widget.itemDuration,
        curve: widget.curve,
        direction: Axis.vertical,
        animationType: widget.animationType,
        skipAnimation: _hasAnimatedOnce && widget.animateOnlyOnce,
      ),
    );

    return GridView.count(
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      childAspectRatio: widget.childAspectRatio,
      children: gridItems,
    );
  }
}
