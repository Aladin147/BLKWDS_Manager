import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_shadows.dart';
import 'blkwds_enhanced_text.dart';

/// BLKWDSEnhancedCalendarCellType
/// Types of calendar cells
enum BLKWDSEnhancedCalendarCellType {
  normal,
  today,
  selected,
  disabled,
}

/// BLKWDSEnhancedCalendarCell
/// An enhanced calendar cell with consistent styling for BLKWDS Manager
class BLKWDSEnhancedCalendarCell extends StatefulWidget {
  /// The day number to display
  final String dayText;

  /// The type of cell
  final BLKWDSEnhancedCalendarCellType type;

  /// Whether the cell has events
  final bool hasEvents;

  /// The number of events (if known)
  final int? eventCount;

  /// The color of the events markers
  final Color eventColor;

  /// Whether the cell is enabled
  final bool isEnabled;

  /// Whether to animate the cell on hover
  final bool animateOnHover;

  /// Callback when the cell is tapped
  final VoidCallback? onTap;

  /// Constructor
  const BLKWDSEnhancedCalendarCell({
    super.key,
    required this.dayText,
    this.type = BLKWDSEnhancedCalendarCellType.normal,
    this.hasEvents = false,
    this.eventCount,
    this.eventColor = BLKWDSColors.successGreen,
    this.isEnabled = true,
    this.animateOnHover = true,
    this.onTap,
  });

  @override
  State<BLKWDSEnhancedCalendarCell> createState() => _BLKWDSEnhancedCalendarCellState();
}

class _BLKWDSEnhancedCalendarCellState extends State<BLKWDSEnhancedCalendarCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Determine background color based on cell type
    Color backgroundColor;
    Color textColor;

    switch (widget.type) {
      case BLKWDSEnhancedCalendarCellType.today:
        backgroundColor = BLKWDSColors.accentTeal.withValues(alpha: 100);
        textColor = BLKWDSColors.white;
        break;
      case BLKWDSEnhancedCalendarCellType.selected:
        backgroundColor = BLKWDSColors.blkwdsGreen.withValues(alpha: 150);
        textColor = BLKWDSColors.white;
        break;
      case BLKWDSEnhancedCalendarCellType.disabled:
        backgroundColor = BLKWDSColors.backgroundMedium.withValues(alpha: 50);
        textColor = BLKWDSColors.textSecondary.withValues(alpha: 150);
        break;
      case BLKWDSEnhancedCalendarCellType.normal:
      default:
        backgroundColor = _isHovered && widget.isEnabled && widget.animateOnHover
            ? BLKWDSColors.backgroundMedium.withValues(alpha: 150)
            : BLKWDSColors.backgroundMedium.withValues(alpha: 80);
        textColor = widget.isEnabled ? BLKWDSColors.textPrimary : BLKWDSColors.textSecondary;
        break;
    }

    Widget calendarCell = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        boxShadow: _isHovered && widget.isEnabled && widget.animateOnHover
            ? BLKWDSShadows.getShadow(BLKWDSShadows.level1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isEnabled ? widget.onTap : null,
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          splashColor: BLKWDSColors.accentTeal.withValues(alpha: 50),
          highlightColor: BLKWDSColors.accentTeal.withValues(alpha: 30),
          child: Padding(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Day number
                BLKWDSEnhancedText.titleLarge(
                  widget.dayText,
                  color: textColor,
                ),

                // Event indicators
                if (widget.hasEvents) ...[
                  const SizedBox(height: BLKWDSConstants.spacingXSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.eventCount != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BLKWDSConstants.spacingXSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.eventColor,
                            borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadiusRound),
                          ),
                          child: Text(
                            widget.eventCount.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: BLKWDSColors.deepBlack,
                            ),
                          ),
                        ),
                      ] else ...[
                        // Event dots
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.eventColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Add hover animation if requested
    if (widget.animateOnHover && widget.isEnabled) {
      calendarCell = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: BLKWDSConstants.animationDurationShort,
          child: calendarCell,
        ),
      );
    }

    return calendarCell;
  }
}

/// BLKWDSEnhancedCalendarHeader
/// An enhanced calendar header with consistent styling for BLKWDS Manager
class BLKWDSEnhancedCalendarHeader extends StatelessWidget {
  /// The title text to display
  final String title;

  /// Callback when the previous button is pressed
  final VoidCallback? onPrevious;

  /// Callback when the next button is pressed
  final VoidCallback? onNext;

  /// Whether the header is enabled
  final bool isEnabled;

  /// Constructor
  const BLKWDSEnhancedCalendarHeader({
    super.key,
    required this.title,
    this.onPrevious,
    this.onNext,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: BLKWDSColors.backgroundMedium,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: isEnabled ? BLKWDSColors.textSecondary : BLKWDSColors.textSecondary.withValues(alpha: 150),
            onPressed: isEnabled ? onPrevious : null,
            tooltip: 'Previous',
          ),

          // Title
          BLKWDSEnhancedText.titleLarge(
            title,
            color: isEnabled ? BLKWDSColors.textPrimary : BLKWDSColors.textSecondary,
          ),

          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: isEnabled ? BLKWDSColors.textSecondary : BLKWDSColors.textSecondary.withValues(alpha: 150),
            onPressed: isEnabled ? onNext : null,
            tooltip: 'Next',
          ),
        ],
      ),
    );
  }
}
