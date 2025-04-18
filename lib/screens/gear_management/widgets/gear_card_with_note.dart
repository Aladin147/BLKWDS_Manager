import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../widgets/blkwds_widgets.dart';

/// GearCardWithNote
/// A card widget for displaying gear with an integrated note field for check-in/check-out
class GearCardWithNote extends StatefulWidget {
  final Gear gear;
  final Function(Gear, String?) onCheckout;
  final Function(Gear, String?) onCheckin;
  final Function(Gear)? onEdit;
  final Function(Gear)? onDelete;
  final Function(Gear)? onTap;
  final bool showActions;
  final bool showNote;
  final bool isCompact;

  const GearCardWithNote({
    super.key,
    required this.gear,
    required this.onCheckout,
    required this.onCheckin,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.showActions = true,
    this.showNote = true,
    this.isCompact = false,
  });

  @override
  State<GearCardWithNote> createState() => _GearCardWithNoteState();
}

class _GearCardWithNoteState extends State<GearCardWithNote> {
  final TextEditingController _noteController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      child: BLKWDSEnhancedCard(
        animateOnHover: true,
        onTap: widget.onTap != null ? () => widget.onTap!(widget.gear) : null,
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gear info and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gear thumbnail or category icon
                widget.gear.thumbnailPath != null
                    ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: BLKWDSColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            widget.gear.thumbnailPath!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : CategoryIconWidget(
                        category: widget.gear.category,
                        size: 50,
                        borderRadius: 8,
                      ),

                const SizedBox(width: BLKWDSConstants.spacingMedium),

                // Gear details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BLKWDSEnhancedText.titleLarge(
                        widget.gear.name,
                      ),
                      const SizedBox(height: 4),
                      BLKWDSEnhancedText.bodyMedium(
                        widget.gear.category,
                        color: BLKWDSColors.textSecondary,
                      ),
                      if (widget.gear.serialNumber != null && !widget.isCompact) ...[
                        const SizedBox(height: 4),
                        BLKWDSEnhancedText.labelLarge(
                          'S/N: ${widget.gear.serialNumber}',
                        ),
                      ],
                    ],
                  ),
                ),

                // Status indicator
                BLKWDSEnhancedStatusBadge(
                  text: widget.gear.isOut ? 'OUT' : 'IN',
                  color: widget.gear.isOut
                      ? BLKWDSColors.statusOut
                      : BLKWDSColors.statusIn,
                  icon: widget.gear.isOut ? Icons.logout : Icons.check_circle,
                  hasBorder: true,
                ),
              ],
            ),

            // Last note (if any)
            if (widget.gear.lastNote != null && widget.gear.lastNote!.isNotEmpty && !_isExpanded) ...[
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              Row(
                children: [
                  const Icon(
                    Icons.note,
                    size: 16,
                    color: BLKWDSColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: BLKWDSEnhancedText.bodyMedium(
                      'Last note: ${widget.gear.lastNote}',
                      color: BLKWDSColors.textSecondary,
                      isItalic: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Note field and actions
            if (widget.showNote && _isExpanded) ...[
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              BLKWDSEnhancedCard(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
                backgroundColor: BLKWDSColors.backgroundMedium,
                child: BLKWDSEnhancedFormField(
                  controller: _noteController,
                  label: 'Note (Optional)',
                  hintText: 'Add a note for this action',
                  maxLines: 3,
                  prefixIcon: Icons.note,
                ),
              ),
            ],

            // Action buttons
            if (widget.showActions) ...[
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Toggle note field
                  BLKWDSEnhancedButton(
                    icon: _isExpanded ? Icons.expand_less : Icons.expand_more,
                    label: _isExpanded ? 'Hide Note' : 'Add Note',
                    type: BLKWDSEnhancedButtonType.tertiary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                      vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                        if (!_isExpanded) {
                          _noteController.clear();
                        }
                      });
                    },
                  ),

                  const Spacer(),

                  // Edit button
                  if (widget.onEdit != null)
                    BLKWDSEnhancedButton(
                      icon: Icons.edit,
                      type: BLKWDSEnhancedButtonType.tertiary,
                      padding: const EdgeInsets.all(8),
                      onPressed: () => widget.onEdit!(widget.gear),
                    ),

                  // Delete button
                  if (widget.onDelete != null)
                    BLKWDSEnhancedButton(
                      icon: Icons.delete,
                      type: BLKWDSEnhancedButtonType.tertiary,
                      padding: const EdgeInsets.all(8),
                      onPressed: () => widget.onDelete!(widget.gear),
                    ),

                  const SizedBox(width: BLKWDSConstants.spacingSmall),

                  // Check in/out button
                  widget.gear.isOut
                      ? BLKWDSEnhancedButton(
                          label: 'Check In',
                          icon: Icons.check_circle,
                          type: BLKWDSEnhancedButtonType.secondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                            vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                          ),
                          onPressed: () {
                            final note = _noteController.text.isNotEmpty ? _noteController.text : null;
                            widget.onCheckin(widget.gear, note);
                            setState(() {
                              _isExpanded = false;
                              _noteController.clear();
                            });
                          },
                        )
                      : BLKWDSEnhancedButton(
                          label: 'Check Out',
                          icon: Icons.logout,
                          type: BLKWDSEnhancedButtonType.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                            vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                          ),
                          onPressed: () {
                            final note = _noteController.text.isNotEmpty ? _noteController.text : null;
                            widget.onCheckout(widget.gear, note);
                            setState(() {
                              _isExpanded = false;
                              _noteController.clear();
                            });
                          },
                        ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
