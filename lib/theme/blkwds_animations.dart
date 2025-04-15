import 'package:flutter/material.dart';
import 'blkwds_constants.dart';
import 'blkwds_colors.dart';

/// BLKWDS Manager Animation System
///
/// Provides standardized animations for consistent motion throughout the app
class BLKWDSAnimations {
  // Animation Durations
  static const Duration extraShort = Duration(milliseconds: 50);
  static const Duration short = BLKWDSConstants.shortAnimationDuration;
  static const Duration medium = BLKWDSConstants.mediumAnimationDuration;
  static const Duration long = Duration(milliseconds: 300);
  static const Duration extraLong = Duration(milliseconds: 500);

  // Animation Curves
  static const Curve standard = Curves.easeInOut;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOutQuint;
  static const Curve accelerate = Curves.easeInQuint;
  static const Curve sharp = Curves.easeInOutQuart;

  // Hover Animation Scale Factors
  static const double hoverScaleFactor = 1.02;
  static const double pressScaleFactor = 0.98;

  // Elevation Animation Values
  static const double baseElevation = BLKWDSConstants.cardElevation;
  static const double hoverElevation = BLKWDSConstants.cardElevation + 2;
  static const double activeElevation = BLKWDSConstants.cardElevation + 4;

  // Opacity Animation Values
  static const double fadeInStart = 0.0;
  static const double fadeInEnd = 1.0;
  static const double fadeOutStart = 1.0;
  static const double fadeOutEnd = 0.0;

  /// Creates a standard fade transition
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
    Curve curve = standard,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
      child: child,
    );
  }

  /// Creates a standard slide transition
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset beginOffset = const Offset(0.0, 0.1),
    Offset endOffset = Offset.zero,
    Curve curve = standard,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: child,
    );
  }

  /// Creates a standard scale transition
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double beginScale = 0.95,
    double endScale = 1.0,
    Curve curve = standard,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: beginScale,
        end: endScale,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: child,
    );
  }

  /// Creates a combined fade and slide transition
  static Widget fadeSlideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset beginOffset = const Offset(0.0, 0.1),
    Offset endOffset = Offset.zero,
    Curve curve = standard,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: endOffset,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        )),
        child: child,
      ),
    );
  }

  /// Creates a hover animation container
  static Widget hoverAnimationContainer({
    required Widget child,
    required bool isHovered,
    Duration duration = short,
    Curve curve = standard,
    double hoverScale = hoverScaleFactor,
    double baseElevation = 0,
    double hoverElevation = 2,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      transform: Matrix4.identity()..scale(isHovered ? hoverScale : 1.0),
      decoration: BoxDecoration(
        boxShadow: [
          if (baseElevation > 0 || (isHovered && hoverElevation > 0))
            BoxShadow(
              color: BLKWDSColors.deepBlack.withValues(alpha: isHovered ? 100 : 50),
              blurRadius: isHovered ? hoverElevation : baseElevation,
              spreadRadius: isHovered ? hoverElevation / 4 : baseElevation / 4,
            ),
        ],
      ),
      child: child,
    );
  }

  /// Creates a press animation container
  static Widget pressAnimationContainer({
    required Widget child,
    required bool isPressed,
    Duration duration = extraShort,
    Curve curve = sharp,
    double pressScale = pressScaleFactor,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      transform: Matrix4.identity()..scale(isPressed ? pressScale : 1.0),
      child: child,
    );
  }

  /// Creates a shimmer loading effect
  static Widget shimmerLoading({
    required Widget child,
    Color baseColor = const Color(0xFF3A3A3A),
    Color highlightColor = const Color(0xFF4A4A4A),
    Duration duration = extraLong,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

/// Custom page route for consistent page transitions
class BLKWDSPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final BLKWDSPageTransitionType transitionType;

  BLKWDSPageRoute({
    required this.page,
    this.transitionType = BLKWDSPageTransitionType.rightToLeft,
    RouteSettings? settings,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case BLKWDSPageTransitionType.fade:
          return BLKWDSAnimations.fadeTransition(
            animation: animation,
            child: child,
          );
        case BLKWDSPageTransitionType.rightToLeft:
          return BLKWDSAnimations.fadeSlideTransition(
            animation: animation,
            beginOffset: const Offset(0.1, 0.0),
            child: child,
          );
        case BLKWDSPageTransitionType.leftToRight:
          return BLKWDSAnimations.fadeSlideTransition(
            animation: animation,
            beginOffset: const Offset(-0.1, 0.0),
            child: child,
          );
        case BLKWDSPageTransitionType.bottomToTop:
          return BLKWDSAnimations.fadeSlideTransition(
            animation: animation,
            beginOffset: const Offset(0.0, 0.1),
            child: child,
          );
        case BLKWDSPageTransitionType.topToBottom:
          return BLKWDSAnimations.fadeSlideTransition(
            animation: animation,
            beginOffset: const Offset(0.0, -0.1),
            child: child,
          );
        case BLKWDSPageTransitionType.scale:
          return BLKWDSAnimations.scaleTransition(
            animation: animation,
            child: child,
          );
      }
    },
    settings: settings,
  );
}

/// Page transition types
enum BLKWDSPageTransitionType {
  fade,
  rightToLeft,
  leftToRight,
  bottomToTop,
  topToBottom,
  scale,
}

/// Extension to add animation capabilities to Color
extension AnimatedColorExtension on Color {
  /// Creates a gradient with this color
  Gradient toGradient({
    Color? endColor,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      colors: [this, endColor ?? withValues(alpha: 200)],
      begin: begin,
      end: end,
      stops: stops,
    );
  }

  /// Creates a radial gradient with this color
  Gradient toRadialGradient({
    Color? endColor,
    double radius = 0.5,
    AlignmentGeometry center = Alignment.center,
    List<double>? stops,
  }) {
    return RadialGradient(
      colors: [this, endColor ?? withValues(alpha: 200)],
      center: center,
      radius: radius,
      stops: stops,
    );
  }
}

/// Animated loading spinner with BLKWDS branding
class BLKWDSLoadingSpinner extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double strokeWidth;

  const BLKWDSLoadingSpinner({
    super.key,
    this.size = 40.0,
    this.color = BLKWDSColors.electricMint,
    this.duration = const Duration(milliseconds: 1200),
    this.strokeWidth = 3.0,
  });

  @override
  State<BLKWDSLoadingSpinner> createState() => _BLKWDSLoadingSpinnerState();
}

class _BLKWDSLoadingSpinnerState extends State<BLKWDSLoadingSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpinnerPainter(
              animation: _controller,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({
    required this.animation,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate center and radius for the circular progress indicator
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background circle with lower opacity
    paint.color = color.withValues(alpha: 50);
    canvas.drawCircle(center, radius, paint);

    // Draw animated arc
    paint.color = color;
    final startAngle = -0.5 * 3.14; // Start from top
    final sweepAngle = 1.75 * 3.14 * animation.value;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + (animation.value * 4 * 3.14), // Rotate as we animate
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
           color != oldDelegate.color ||
           strokeWidth != oldDelegate.strokeWidth;
  }
}

/// Animated progress indicator with BLKWDS branding
class BLKWDSProgressIndicator extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final Color progressColor;
  final double height;
  final bool isAnimated;
  final Duration animationDuration;
  final Curve animationCurve;

  const BLKWDSProgressIndicator({
    super.key,
    required this.value,
    this.backgroundColor = const Color(0xFF2A2A2A),
    this.progressColor = BLKWDSColors.electricMint,
    this.height = 6.0,
    this.isAnimated = true,
    this.animationDuration = BLKWDSAnimations.medium,
    this.animationCurve = BLKWDSAnimations.emphasized,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final progressWidth = maxWidth * value.clamp(0.0, 1.0);

          return Stack(
            children: [
              // Progress bar
              isAnimated
                  ? AnimatedContainer(
                      duration: animationDuration,
                      curve: animationCurve,
                      width: progressWidth,
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withValues(alpha: 100),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: progressWidth,
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
