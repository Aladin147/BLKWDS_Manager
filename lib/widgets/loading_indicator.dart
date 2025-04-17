import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A loading indicator widget
///
/// This widget displays a loading indicator with an optional label.
class LoadingIndicator extends StatelessWidget {
  /// The size of the loading indicator
  final double size;

  /// The color of the loading indicator
  final Color? color;

  /// The label to display below the loading indicator
  final String? label;

  /// The text style for the label
  final TextStyle? labelStyle;

  /// Constructor
  const LoadingIndicator({
    Key? key,
    this.size = 24.0,
    this.color,
    this.label,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size / 8,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: labelStyle ?? theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
