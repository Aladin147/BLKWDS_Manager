import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';
import '../theme/blkwds_animations.dart';
import '../theme/blkwds_shadows.dart';

/// Enhanced dropdown component for BLKWDS Manager
///
/// Provides consistent styling for all dropdowns in the app with animations
class BLKWDSDropdownEnhanced<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final bool isRequired;
  final String? errorText;
  final String hintText;
  final bool isDisabled;
  final bool showSuccessState;
  final bool isSuccess;
  final String? helperText;
  final bool animateLabel;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showBorder;
  final EdgeInsetsGeometry? contentPadding;
  final double? dropdownMaxHeight;
  final bool isDense;
  final bool isExpanded;
  final Color? dropdownColor;
  final FocusNode? focusNode;

  const BLKWDSDropdownEnhanced({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.hintText = 'Select an option',
    this.isDisabled = false,
    this.showSuccessState = false,
    this.isSuccess = false,
    this.helperText,
    this.animateLabel = true,
    this.prefixIcon,
    this.suffixIcon,
    this.showBorder = true,
    this.contentPadding,
    this.dropdownMaxHeight,
    this.isDense = false,
    this.isExpanded = true,
    this.dropdownColor,
    this.focusNode,
  });

  @override
  State<BLKWDSDropdownEnhanced<T>> createState() => _BLKWDSDropdownEnhancedState<T>();
}

class _BLKWDSDropdownEnhancedState<T> extends State<BLKWDSDropdownEnhanced<T>> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<double> _labelAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _rotationAnimation;
  bool _isFocused = false;
  bool _isHovered = false;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: BLKWDSAnimations.short,
    );

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: BLKWDSAnimations.standard,
    ));

    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: BLKWDSAnimations.standard,
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: BLKWDSAnimations.standard,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: BLKWDSAnimations.standard,
    ));

    if (widget.value != null) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BLKWDSDropdownEnhanced<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode ?? _focusNode;
      _focusNode.addListener(_handleFocusChange);
    }

    final bool hasValue = widget.value != null;
    if (hasValue != (oldWidget.value != null)) {
      if (hasValue) {
        _animationController.forward();
      } else if (!_isFocused) {
        _animationController.reverse();
      }
    }
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused) {
        _animationController.forward();
      } else if (widget.value == null) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    final bool isSuccess = widget.showSuccessState && widget.isSuccess;

    // Determine border color based on state
    Color borderColor = BLKWDSColors.inputBorder;
    if (_isFocused || _isOpen) {
      borderColor = BLKWDSColors.blkwdsGreen;
    } else if (hasError) {
      borderColor = BLKWDSColors.errorRed;
    } else if (isSuccess) {
      borderColor = BLKWDSColors.electricMint;
    } else if (_isHovered) {
      borderColor = BLKWDSColors.slateGrey;
    }

    // Determine shadow based on state
    List<BoxShadow> shadows = [];
    if (_isFocused || _isOpen) {
      shadows = BLKWDSShadows.getFocusShadow();
    } else if (hasError) {
      shadows = BLKWDSShadows.getErrorShadow();
    } else if (isSuccess) {
      shadows = BLKWDSShadows.getSuccessShadow();
    } else if (_isHovered) {
      shadows = BLKWDSShadows.getHoverShadow();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated label
              if (widget.animateLabel)
                AnimatedContainer(
                  duration: BLKWDSAnimations.short,
                  height: 20,
                  margin: EdgeInsets.only(
                    bottom: BLKWDSConstants.spacingSmall / 2,
                    left: BLKWDSConstants.spacingSmall / 2,
                  ),
                  child: Transform.scale(
                    scale: 1.0 - (_labelAnimation.value * 0.1),
                    alignment: Alignment.centerLeft,
                    child: Opacity(
                      opacity: 1.0 - (_labelAnimation.value * 0.3),
                      child: RichText(
                        text: TextSpan(
                          text: widget.label,
                          style: BLKWDSTypography.labelMedium.copyWith(
                            color: _isFocused || _isOpen
                                ? BLKWDSColors.blkwdsGreen
                                : hasError
                                    ? BLKWDSColors.errorRed
                                    : isSuccess
                                        ? BLKWDSColors.electricMint
                                        : BLKWDSColors.slateGrey,
                          ),
                          children: widget.isRequired
                              ? [
                                  TextSpan(
                                    text: ' *',
                                    style: BLKWDSTypography.labelMedium.copyWith(
                                      color: BLKWDSColors.errorRed,
                                    ),
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: BLKWDSConstants.spacingSmall / 2,
                    left: BLKWDSConstants.spacingSmall / 2,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: widget.label,
                      style: BLKWDSTypography.labelMedium.copyWith(
                        color: _isFocused || _isOpen
                            ? BLKWDSColors.blkwdsGreen
                            : hasError
                                ? BLKWDSColors.errorRed
                                : isSuccess
                                    ? BLKWDSColors.electricMint
                                    : BLKWDSColors.slateGrey,
                      ),
                      children: widget.isRequired
                          ? [
                              TextSpan(
                                text: ' *',
                                style: BLKWDSTypography.labelMedium.copyWith(
                                  color: BLKWDSColors.errorRed,
                                ),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),

              // Animated dropdown container
              AnimatedContainer(
                duration: BLKWDSAnimations.short,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                  boxShadow: _shadowAnimation.value > 0
                      ? shadows.map((shadow) => BoxShadow(
                          color: shadow.color.withAlpha((shadow.color.a * _shadowAnimation.value).round()),
                          blurRadius: shadow.blurRadius * _shadowAnimation.value,
                          spreadRadius: shadow.spreadRadius * _shadowAnimation.value,
                          offset: shadow.offset,
                        )).toList()
                      : [],
                ),
                child: Focus(
                  focusNode: _focusNode,
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isFocused = hasFocus;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDisabled
                          ? BLKWDSColors.inputBackground.withValues(alpha: 200)
                          : BLKWDSColors.inputBackground,
                      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                      border: widget.showBorder
                          ? Border.all(
                              color: widget.isDisabled
                                  ? borderColor.withValues(alpha: 128)
                                  : borderColor,
                              width: _isFocused || _isOpen || _isHovered
                                  ? _borderAnimation.value
                                  : 1.0,
                            )
                          : null,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<T>(
                          value: widget.value,
                          hint: Text(
                            widget.hintText,
                            style: BLKWDSTypography.bodyMedium.copyWith(
                              color: BLKWDSColors.slateGrey.withValues(alpha: 128), // 0.5 * 255 = 128
                            ),
                          ),
                          isExpanded: widget.isExpanded,
                          isDense: widget.isDense,
                          icon: RotationTransition(
                            turns: _rotationAnimation,
                            child: widget.suffixIcon ??
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: _isFocused || _isOpen
                                      ? BLKWDSColors.blkwdsGreen
                                      : hasError
                                          ? BLKWDSColors.errorRed
                                          : isSuccess
                                              ? BLKWDSColors.electricMint
                                              : BLKWDSColors.slateGrey,
                                ),
                          ),
                          iconSize: 24,
                          elevation: 8,
                          style: BLKWDSTypography.bodyMedium,
                          dropdownColor: widget.dropdownColor ?? BLKWDSColors.white,
                          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                          items: widget.items,
                          onChanged: widget.isDisabled ? null : (T? value) {
                            widget.onChanged(value);
                            setState(() {
                              _isOpen = false;
                              if (value != null) {
                                _animationController.forward();
                              } else if (!_isFocused) {
                                _animationController.reverse();
                              }
                            });
                          },
                          onTap: () {
                            setState(() {
                              _isOpen = true;
                              _animationController.forward();
                            });
                          },
                          menuMaxHeight: widget.dropdownMaxHeight,
                          padding: widget.contentPadding ?? EdgeInsets.symmetric(
                            horizontal: BLKWDSConstants.inputHorizontalPadding,
                            vertical: BLKWDSConstants.inputVerticalPadding / 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Error or helper text
              if (widget.errorText != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: BLKWDSConstants.spacingSmall / 2,
                    left: BLKWDSConstants.spacingSmall,
                  ),
                  child: Text(
                    widget.errorText!,
                    style: BLKWDSTypography.bodySmall.copyWith(
                      color: BLKWDSColors.errorRed,
                    ),
                  ),
                )
              else if (widget.helperText != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: BLKWDSConstants.spacingSmall / 2,
                    left: BLKWDSConstants.spacingSmall,
                  ),
                  child: Text(
                    widget.helperText!,
                    style: BLKWDSTypography.bodySmall.copyWith(
                      color: BLKWDSColors.slateGrey,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
