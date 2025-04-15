import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Standardized checkbox component for BLKWDS Manager
///
/// Provides consistent styling for all checkboxes in the app
class BLKWDSCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool?) onChanged;
  final bool isDisabled;

  const BLKWDSCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : () => onChanged(!value),
      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: BLKWDSConstants.spacingSmall / 2,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: isDisabled ? null : onChanged,
                activeColor: BLKWDSColors.blkwdsGreen,
                checkColor: BLKWDSColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: isDisabled
                      ? BLKWDSColors.slateGrey.withValues(alpha: 128) // 0.5 * 255 = 128
                      : BLKWDSColors.slateGrey,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: BLKWDSConstants.spacingSmall),
            Expanded(
              child: Text(
                label,
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: isDisabled
                      ? BLKWDSColors.slateGrey.withValues(alpha: 128) // 0.5 * 255 = 128
                      : BLKWDSColors.slateGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
