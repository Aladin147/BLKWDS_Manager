import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';
import '../theme/blkwds_animations.dart';
import '../theme/blkwds_shadows.dart';

/// Enhanced text field component for BLKWDS Manager
///
/// Provides consistent styling for all text fields in the app with animations
class BLKWDSTextFieldEnhanced extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isRequired;
  final bool isReadOnly;
  final bool isMultiline;
  final String? errorText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final int? maxLength;
  final String? initialValue;
  final bool animateLabel;
  final bool showSuccessState;
  final bool isSuccess;
  final String? helperText;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final bool autofocus;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool showCounter;
  final int? minLines;
  final int? maxLines;
  final bool expands;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final bool enabled;

  const BLKWDSTextFieldEnhanced({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isMultiline = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.maxLength,
    this.initialValue,
    this.animateLabel = true,
    this.showSuccessState = false,
    this.isSuccess = false,
    this.helperText,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.showCounter = false,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autovalidateMode,
    this.validator,
    this.enabled = true,
  });

  @override
  State<BLKWDSTextFieldEnhanced> createState() => _BLKWDSTextFieldEnhancedState();
}

class _BLKWDSTextFieldEnhancedState extends State<BLKWDSTextFieldEnhanced> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<double> _labelAnimation;
  late Animation<double> _shadowAnimation;
  bool _isFocused = false;
  bool _hasText = false;
  bool _isHovered = false;

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

    _hasText = (widget.initialValue?.isNotEmpty ?? false) ||
               (widget.controller?.text.isNotEmpty ?? false);

    if (_hasText || widget.autofocus) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BLKWDSTextFieldEnhanced oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode ?? _focusNode;
      _focusNode.addListener(_handleFocusChange);
    }

    final bool hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) {
      _hasText = hasText;
      if (_hasText) {
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
      } else if (!_hasText) {
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
    if (_isFocused) {
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
    if (_isFocused) {
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
                            color: _isFocused
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
                        color: _isFocused
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

              // Animated text field container
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
                child: TextFormField(
                  controller: widget.controller,
                  initialValue: widget.initialValue,
                  focusNode: _focusNode,
                  readOnly: widget.isReadOnly,
                  maxLines: widget.isMultiline ? widget.maxLines ?? 5 : widget.maxLines ?? 1,
                  minLines: widget.isMultiline ? widget.minLines ?? 3 : widget.minLines ?? 1,
                  keyboardType: widget.isMultiline ? TextInputType.multiline : widget.keyboardType,
                  maxLength: widget.maxLength,
                  style: BLKWDSTypography.bodyMedium,
                  onChanged: (value) {
                    setState(() {
                      _hasText = value.isNotEmpty;
                      if (_hasText) {
                        _animationController.forward();
                      } else if (!_isFocused) {
                        _animationController.reverse();
                      }
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  },
                  obscureText: widget.obscureText,
                  textInputAction: widget.textInputAction,
                  onFieldSubmitted: widget.onSubmitted,
                  autofocus: widget.autofocus,
                  enableSuggestions: widget.enableSuggestions,
                  autocorrect: widget.autocorrect,
                  expands: widget.expands,
                  textCapitalization: widget.textCapitalization,
                  inputFormatters: widget.inputFormatters,
                  autovalidateMode: widget.autovalidateMode,
                  validator: widget.validator,
                  enabled: widget.enabled,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: BLKWDSTypography.bodyMedium.copyWith(
                      color: BLKWDSColors.slateGrey.withValues(alpha: 128), // 0.5 * 255 = 128
                    ),
                    errorText: widget.errorText,
                    errorStyle: BLKWDSTypography.bodySmall.copyWith(
                      color: BLKWDSColors.errorRed,
                    ),
                    helperText: widget.helperText,
                    helperStyle: BLKWDSTypography.bodySmall.copyWith(
                      color: BLKWDSColors.slateGrey,
                    ),
                    filled: true,
                    fillColor: widget.enabled
                        ? BLKWDSColors.inputBackground
                        : BLKWDSColors.inputBackground.withValues(alpha: 200),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: BLKWDSConstants.inputHorizontalPadding,
                      vertical: BLKWDSConstants.inputVerticalPadding,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                      borderSide: BorderSide(
                        color: borderColor,
                        width: _borderAnimation.value,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                      borderSide: BorderSide(
                        color: borderColor,
                        width: _isHovered ? 1.5 : 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                      borderSide: BorderSide(
                        color: borderColor,
                        width: _borderAnimation.value,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                      borderSide: BorderSide(
                        color: BLKWDSColors.errorRed,
                        width: _isHovered ? 1.5 : 1.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                      borderSide: const BorderSide(
                        color: BLKWDSColors.errorRed,
                        width: 2.0,
                      ),
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: _isFocused
                                ? BLKWDSColors.blkwdsGreen
                                : hasError
                                    ? BLKWDSColors.errorRed
                                    : isSuccess
                                        ? BLKWDSColors.electricMint
                                        : BLKWDSColors.slateGrey,
                          )
                        : null,
                    suffixIcon: widget.suffixIcon ??
                        (isSuccess
                            ? const Icon(
                                Icons.check_circle,
                                color: BLKWDSColors.electricMint,
                              )
                            : null),
                    counterText: widget.showCounter ? null : '',
                    labelText: widget.animateLabel && (_isFocused || _hasText)
                        ? widget.label + (widget.isRequired ? ' *' : '')
                        : null,
                    labelStyle: BLKWDSTypography.bodyMedium.copyWith(
                      color: _isFocused
                          ? BLKWDSColors.blkwdsGreen
                          : hasError
                              ? BLKWDSColors.errorRed
                              : isSuccess
                                  ? BLKWDSColors.electricMint
                                  : BLKWDSColors.slateGrey,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
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


