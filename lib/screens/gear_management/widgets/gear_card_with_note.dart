import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
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
    return BLKWDSCard(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
      child: InkWell(
        onTap: widget.onTap != null ? () => widget.onTap!(widget.gear) : null,
        child: Padding(
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
                        Text(
                          widget.gear.name,
                          style: BLKWDSTypography.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.gear.category,
                          style: BLKWDSTypography.bodyMedium.copyWith(
                            color: BLKWDSColors.textSecondary,
                          ),
                        ),
                        if (widget.gear.serialNumber != null && !widget.isCompact) ...[
                          const SizedBox(height: 4),
                          Text(
                            'S/N: ${widget.gear.serialNumber}',
                            style: BLKWDSTypography.labelSmall,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status indicator
                  BLKWDSStatusBadge(
                    text: widget.gear.isOut ? 'OUT' : 'IN',
                    color: widget.gear.isOut
                        ? BLKWDSColors.statusOut
                        : BLKWDSColors.statusIn,
                    icon: widget.gear.isOut ? Icons.logout : Icons.check_circle,
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
                      child: Text(
                        'Last note: ${widget.gear.lastNote}',
                        style: BLKWDSTypography.bodySmall.copyWith(
                          color: BLKWDSColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
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
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (Optional)',
                    hintText: 'Add a note for this action',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],

              // Action buttons
              if (widget.showActions) ...[
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Toggle note field
                    TextButton.icon(
                      icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                      label: Text(_isExpanded ? 'Hide Note' : 'Add Note'),
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
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () => widget.onEdit!(widget.gear),
                      ),

                    // Delete button
                    if (widget.onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete',
                        onPressed: () => widget.onDelete!(widget.gear),
                      ),

                    const SizedBox(width: BLKWDSConstants.spacingSmall),

                    // Check in/out button
                    widget.gear.isOut
                        ? BLKWDSButton(
                            label: 'Check In',
                            icon: Icons.check_circle,
                            type: BLKWDSButtonType.secondary,
                            isSmall: true,
                            onPressed: () {
                              final note = _noteController.text.isNotEmpty ? _noteController.text : null;
                              widget.onCheckin(widget.gear, note);
                              setState(() {
                                _isExpanded = false;
                                _noteController.clear();
                              });
                            },
                          )
                        : BLKWDSButton(
                            label: 'Check Out',
                            icon: Icons.logout,
                            type: BLKWDSButtonType.primary,
                            isSmall: true,
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
      ),
    );
  }


}
