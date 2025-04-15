import 'package:flutter/material.dart';
import '../theme/blkwds_animations.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Expandable container component for BLKWDS Manager
///
/// Provides smooth expand/collapse animations for content
class BLKWDSExpandable extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Duration animationDuration;
  final Curve animationCurve;
  final IconData expandIcon;
  final IconData collapseIcon;
  final Color? headerColor;
  final Color? headerTextColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final bool hasBorder;
  final BorderRadius? borderRadius;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final bool animateOnExpand;
  final Widget? headerTrailing;

  const BLKWDSExpandable({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.animationDuration = BLKWDSAnimations.medium,
    this.animationCurve = BLKWDSAnimations.standard,
    this.expandIcon = Icons.keyboard_arrow_down,
    this.collapseIcon = Icons.keyboard_arrow_up,
    this.headerColor,
    this.headerTextColor,
    this.iconColor,
    this.padding,
    this.contentPadding,
    this.hasBorder = true,
    this.borderRadius,
    this.onExpand,
    this.onCollapse,
    this.animateOnExpand = true,
    this.headerTrailing,
  });

  @override
  State<BLKWDSExpandable> createState() => _BLKWDSExpandableState();
}

class _BLKWDSExpandableState extends State<BLKWDSExpandable> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _iconRotation;
  late Animation<double> _contentOpacity;
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _heightFactor = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _contentOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.4, 1.0,
        curve: widget.animationCurve,
      ),
    ));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        if (widget.onExpand != null) {
          widget.onExpand!();
        }
      } else {
        _controller.reverse();
        if (widget.onCollapse != null) {
          widget.onCollapse!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = widget.headerColor ?? BLKWDSColors.deepBlack;
    final headerTextColor = widget.headerTextColor ?? BLKWDSColors.white;
    final iconColor = widget.iconColor ?? BLKWDSColors.electricMint;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(BLKWDSConstants.borderRadius);

    return Container(
      padding: widget.padding,
      decoration: widget.hasBorder
          ? BoxDecoration(
              border: Border.all(
                color: BLKWDSColors.slateGrey.withValues(alpha: 50),
                width: 1.0,
              ),
              borderRadius: borderRadius,
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: widget.hasBorder ? borderRadius : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BLKWDSConstants.spacingMedium,
                vertical: BLKWDSConstants.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: widget.hasBorder
                    ? BorderRadius.only(
                        topLeft: borderRadius.topLeft,
                        topRight: borderRadius.topRight,
                        bottomLeft: _isExpanded ? Radius.zero : borderRadius.bottomLeft,
                        bottomRight: _isExpanded ? Radius.zero : borderRadius.bottomRight,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: BLKWDSTypography.titleSmall.copyWith(
                        color: headerTextColor,
                      ),
                    ),
                  ),
                  if (widget.headerTrailing != null) widget.headerTrailing!,
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  RotationTransition(
                    turns: _iconRotation,
                    child: Icon(
                      widget.expandIcon,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated content
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  height: _heightFactor.value * _getChildHeight(),
                  child: child,
                );
              },
              child: Container(
                key: _childKey,
                padding: widget.contentPadding ?? const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: BLKWDSColors.cardBackground,
                  borderRadius: widget.hasBorder
                      ? BorderRadius.only(
                          bottomLeft: borderRadius.bottomLeft,
                          bottomRight: borderRadius.bottomRight,
                        )
                      : null,
                ),
                child: widget.animateOnExpand
                    ? FadeTransition(
                        opacity: _contentOpacity,
                        child: widget.child,
                      )
                    : widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getChildHeight() {
    final RenderBox? renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      return renderBox.size.height;
    }
    return 0.0;
  }
}

/// Expandable panel group for BLKWDS Manager
///
/// Manages a group of expandable panels with optional single-panel-open behavior
class BLKWDSExpandableGroup extends StatefulWidget {
  final List<BLKWDSExpandablePanel> panels;
  final bool allowMultipleOpen;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsetsGeometry? padding;
  final bool hasBorder;
  final BorderRadius? borderRadius;

  const BLKWDSExpandableGroup({
    super.key,
    required this.panels,
    this.allowMultipleOpen = false,
    this.animationDuration = BLKWDSAnimations.medium,
    this.animationCurve = BLKWDSAnimations.standard,
    this.padding,
    this.hasBorder = true,
    this.borderRadius,
  });

  @override
  State<BLKWDSExpandableGroup> createState() => _BLKWDSExpandableGroupState();
}

class _BLKWDSExpandableGroupState extends State<BLKWDSExpandableGroup> {
  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = List.generate(
      widget.panels.length,
      (index) => widget.panels[index].initiallyExpanded,
    );
  }

  @override
  void didUpdateWidget(BLKWDSExpandableGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.panels.length != oldWidget.panels.length) {
      _expandedStates = List.generate(
        widget.panels.length,
        (index) => index < _expandedStates.length
            ? _expandedStates[index]
            : widget.panels[index].initiallyExpanded,
      );
    }
  }

  void _handlePanelExpand(int index) {
    setState(() {
      if (!widget.allowMultipleOpen) {
        for (int i = 0; i < _expandedStates.length; i++) {
          _expandedStates[i] = i == index;
        }
      } else {
        _expandedStates[index] = true;
      }
    });
  }

  void _handlePanelCollapse(int index) {
    setState(() {
      _expandedStates[index] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        children: List.generate(
          widget.panels.length,
          (index) {
            final panel = widget.panels[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < widget.panels.length - 1
                    ? BLKWDSConstants.spacingMedium
                    : 0,
              ),
              child: BLKWDSExpandable(
                title: panel.title,
                initiallyExpanded: _expandedStates[index],
                animationDuration: widget.animationDuration,
                animationCurve: widget.animationCurve,
                expandIcon: panel.expandIcon,
                collapseIcon: panel.collapseIcon,
                headerColor: panel.headerColor,
                headerTextColor: panel.headerTextColor,
                iconColor: panel.iconColor,
                contentPadding: panel.contentPadding,
                hasBorder: widget.hasBorder,
                borderRadius: widget.borderRadius,
                animateOnExpand: panel.animateOnExpand,
                headerTrailing: panel.headerTrailing,
                child: panel.child,
                onExpand: () {
                  _handlePanelExpand(index);
                  if (panel.onExpand != null) {
                    panel.onExpand!();
                  }
                },
                onCollapse: () {
                  _handlePanelCollapse(index);
                  if (panel.onCollapse != null) {
                    panel.onCollapse!();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Expandable panel data for BLKWDSExpandableGroup
class BLKWDSExpandablePanel {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final IconData expandIcon;
  final IconData collapseIcon;
  final Color? headerColor;
  final Color? headerTextColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool animateOnExpand;
  final Widget? headerTrailing;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;

  BLKWDSExpandablePanel({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.expandIcon = Icons.keyboard_arrow_down,
    this.collapseIcon = Icons.keyboard_arrow_up,
    this.headerColor,
    this.headerTextColor,
    this.iconColor,
    this.contentPadding,
    this.animateOnExpand = true,
    this.headerTrailing,
    this.onExpand,
    this.onCollapse,
  });
}
