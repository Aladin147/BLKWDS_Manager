import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/log_service.dart';
import '../../services/navigation_helper.dart';
import '../../services/snackbar_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';


import '../../widgets/blkwds_widgets.dart';
import 'booking_list_controller.dart';
import 'booking_panel_controller.dart';
import 'models/booking_list_view_options.dart';
import 'widgets/booking_filter_bar.dart';

import 'widgets/booking_form.dart';
import 'widgets/booking_list_header.dart';
import 'widgets/booking_list_item.dart';

/// BookingListScreen
/// Enhanced screen for displaying and managing bookings
class BookingListScreen extends StatefulWidget {
  final BookingPanelController controller;

  const BookingListScreen({
    super.key,
    required this.controller,
  });

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  // Controllers
  late final BookingListController _listController;

  // State variables
  bool _showEditForm = false;
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _errorMessage;

  // Helper method to show snackbar safely after async operations
  void _showSnackBar(String message, bool isSuccess) {
    if (!mounted) return;

    if (isSuccess) {
      SnackbarService.showSuccess(context, message);
    } else {
      SnackbarService.showError(context, message);
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize list controller
    _listController = BookingListController(widget.controller);
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  // Show edit booking form
  void _showEditBookingForm(Booking booking) {
    setState(() {
      _showEditForm = true;
      _selectedBooking = booking;
    });
  }

  // Hide edit booking form
  void _hideEditBookingForm() {
    setState(() {
      _showEditForm = false;
      _selectedBooking = null;
    });
  }

  // Save booking
  Future<void> _saveBooking(Booking booking) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.controller.updateBooking(booking);

      if (success) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _showEditForm = false;
            _selectedBooking = null;
          });

          _showSnackBar('Booking updated successfully', true);
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = widget.controller.errorMessage.value ?? 'Failed to update booking';
            _isLoading = false;
          });

          _showSnackBar(_errorMessage!, false);
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error updating booking', e, stackTrace);
      if (mounted) {
        setState(() {
          _errorMessage = 'Error updating booking: $e';
          _isLoading = false;
        });

        _showSnackBar(_errorMessage!, false);
      }
    }
  }

  // Delete booking
  Future<void> _deleteBooking(Booking booking) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: BLKWDSEnhancedText.titleLarge('Delete Booking'),
        content: BLKWDSEnhancedText.bodyMedium('Are you sure you want to delete this booking?'),
        actions: [
          BLKWDSEnhancedButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            type: BLKWDSEnhancedButtonType.secondary,
          ),
          BLKWDSEnhancedButton(
            label: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            type: BLKWDSEnhancedButtonType.error,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.controller.deleteBooking(booking.id!);

      if (success) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          _showSnackBar('Booking deleted successfully', true);
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = widget.controller.errorMessage.value ?? 'Failed to delete booking';
            _isLoading = false;
          });

          _showSnackBar(_errorMessage!, false);
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error deleting booking', e, stackTrace);
      if (mounted) {
        setState(() {
          _errorMessage = 'Error deleting booking: $e';
          _isLoading = false;
        });

        _showSnackBar(_errorMessage!, false);
      }
    }
  }

  // Navigate to booking detail
  void _navigateToBookingDetail(Booking booking) async {
    final result = await NavigationHelper.service.navigateToBookingDetailFromList(
      booking,
      widget.controller,
    );

    // Refresh data if booking was updated or deleted
    if (result == true) {
      widget.controller.initialize();
    }
  }

  // Show view options dialog
  void _showViewOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: BLKWDSEnhancedText.titleLarge('View Options'),
        content: StatefulBuilder(
          builder: (context, setState) {
            final viewOptions = _listController.viewOptions.value;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grouping options
                  BLKWDSEnhancedText.titleLarge(
                    'Group By',
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingSmall),
                  Wrap(
                    spacing: BLKWDSConstants.spacingSmall,
                    children: BookingGroupBy.values.map((groupBy) {
                      return ChoiceChip(
                        label: BLKWDSEnhancedText.bodyMedium(groupBy.label),
                        selected: viewOptions.groupBy == groupBy,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _listController.updateViewOptions(
                                viewOptions.copyWith(groupBy: groupBy),
                              );
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingMedium),

                  // View density options
                  BLKWDSEnhancedText.titleLarge(
                    'View Density',
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingSmall),
                  Wrap(
                    spacing: BLKWDSConstants.spacingSmall,
                    children: BookingViewDensity.values.map((density) {
                      return ChoiceChip(
                        label: BLKWDSEnhancedText.bodyMedium(density.label),
                        selected: viewOptions.viewDensity == density,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _listController.updateViewOptions(
                                viewOptions.copyWith(viewDensity: density),
                              );
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingMedium),

                  // Other options
                  SwitchListTile(
                    title: BLKWDSEnhancedText.titleLarge('Show Past Bookings'),
                    value: viewOptions.showPastBookings,
                    onChanged: (value) {
                      setState(() {
                        _listController.updateViewOptions(
                          viewOptions.copyWith(showPastBookings: value),
                        );
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: BLKWDSEnhancedText.titleLarge('Show Details'),
                    value: viewOptions.showDetails,
                    onChanged: (value) {
                      setState(() {
                        _listController.updateViewOptions(
                          viewOptions.copyWith(showDetails: value),
                        );
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          BLKWDSEnhancedButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
            type: BLKWDSEnhancedButtonType.secondary,
          ),
        ],
      ),
    );
  }

  // Show save preset dialog
  void _showSavePresetDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: BLKWDSEnhancedText.titleLarge('Save Filter Preset'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            hintText: 'Enter a name for this preset',
          ),
          autofocus: true,
        ),
        actions: [
          BLKWDSEnhancedButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
            type: BLKWDSEnhancedButtonType.secondary,
          ),
          BLKWDSEnhancedButton(
            label: 'Save',
            onPressed: () {
              if (textController.text.isNotEmpty) {
                // Close dialog first
                Navigator.pop(context);

                // Then perform the async operation
                _listController.savePreset(textController.text).then((success) {
                  if (success) {
                    _showSnackBar('Preset saved successfully', true);
                  } else {
                    _showSnackBar('Failed to save preset', false);
                  }
                });
              }
            },
            type: BLKWDSEnhancedButtonType.primary,
          ),
        ],
      ),
    ).then((_) => textController.dispose());
  }

  // Show presets dialog
  void _showPresetsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: BLKWDSEnhancedText.titleLarge('Filter Presets'),
        content: ValueListenableBuilder<List<SavedFilterPreset>>(
          valueListenable: _listController.savedPresets,
          builder: (context, presets, child) {
            if (presets.isEmpty) {
              return BLKWDSEnhancedText.bodyMedium('No saved presets');
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];

                  return ListTile(
                    title: BLKWDSEnhancedText.titleLarge(preset.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Perform the async operation
                        _listController.deletePreset(preset.id).then((success) {
                          if (success) {
                            _showSnackBar('Preset deleted', true);
                          }
                        });
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _listController.applyPreset(preset);
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          BLKWDSEnhancedButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
            type: BLKWDSEnhancedButtonType.secondary,
          ),
        ],
      ),
    );
  }

  // Bulk delete selected bookings
  Future<void> _bulkDeleteBookings() async {
    final selectedCount = _listController.viewState.value.selectedBookingIds.length;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: BLKWDSEnhancedText.titleLarge('Delete Bookings'),
        content: BLKWDSEnhancedText.bodyMedium('Are you sure you want to delete $selectedCount selected bookings?'),
        actions: [
          BLKWDSEnhancedButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            type: BLKWDSEnhancedButtonType.secondary,
          ),
          BLKWDSEnhancedButton(
            label: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            type: BLKWDSEnhancedButtonType.error,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _listController.bulkDeleteBookings();

    if (success) {
      _showSnackBar('Deleted $selectedCount bookings', true);
    } else {
      _showSnackBar('Failed to delete some bookings', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: BLKWDSEnhancedLoadingIndicator(),
      );
    }

    if (_showEditForm) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Booking'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _hideEditBookingForm,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: BookingForm(
              controller: widget.controller,
              booking: _selectedBooking,
              onSave: _saveBooking,
              onCancel: _hideEditBookingForm,
            ),
        ),
      );
    }

    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: Column(
            children: [
              // Filter bar
              BookingFilterBar(
                controller: widget.controller,
                onFilterChanged: () {
                  // This will trigger a rebuild of the list
                  setState(() {});
                },
              ),

              // View options and actions bar
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              ValueListenableBuilder<bool>(
                valueListenable: _listController.isInSelectionMode,
                builder: (context, isInSelectionMode, child) {
                  if (isInSelectionMode) {
                    // Selection mode toolbar
                    return ValueListenableBuilder<BookingListViewState>(
                      valueListenable: _listController.viewState,
                      builder: (context, viewState, child) {
                        final selectedCount = viewState.selectedBookingIds.length;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BLKWDSConstants.spacingMedium,
                            vertical: BLKWDSConstants.spacingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: BLKWDSColors.backgroundLight,
                            borderRadius: BorderRadius.circular(BLKWDSConstants.cardBorderRadius),
                          ),
                          child: Row(
                            children: [
                              BLKWDSEnhancedText.bodyMedium(
                                '$selectedCount selected',
                                isBold: true,
                              ),
                              const Spacer(),
                              BLKWDSEnhancedButton(
                                icon: Icons.delete,
                                label: 'Delete',
                                type: BLKWDSEnhancedButtonType.error,
                                onPressed: selectedCount > 0 ? _bulkDeleteBookings : null,
                              ),
                              const SizedBox(width: BLKWDSConstants.spacingSmall),
                              BLKWDSEnhancedButton(
                                icon: Icons.close,
                                label: 'Cancel',
                                type: BLKWDSEnhancedButtonType.secondary,
                                onPressed: () => _listController.clearSelection(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    // Normal toolbar
                    return Row(
                      children: [
                        // View options button
                        IconButton(
                          icon: const Icon(Icons.view_list),
                          tooltip: 'View Options',
                          onPressed: _showViewOptionsDialog,
                        ),

                        // Save preset button
                        IconButton(
                          icon: const Icon(Icons.save),
                          tooltip: 'Save Preset',
                          onPressed: _showSavePresetDialog,
                        ),

                        // Load preset button
                        IconButton(
                          icon: const Icon(Icons.bookmark),
                          tooltip: 'Load Preset',
                          onPressed: _showPresetsDialog,
                        ),

                        const Spacer(),

                        // Select all button
                        BLKWDSEnhancedButton(
                          icon: Icons.select_all,
                          label: 'Select All',
                          type: BLKWDSEnhancedButtonType.secondary,
                          onPressed: () => _listController.selectAllBookings(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // Booking list
        Expanded(
          child: ValueListenableBuilder<List<BookingGroup>>(
            valueListenable: _listController.groupedBookings,
            builder: (context, groups, child) {
              if (groups.isEmpty) {
                return FallbackWidget.empty(
                  message: 'No bookings in your schedule',
                  icon: Icons.event_busy,
                  onPrimaryAction: () {
                    // Navigate back to parent screen and show create form
                    Navigator.of(context).pop();
                    // Use a post-frame callback to ensure the navigation is complete
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        SnackbarService.showInfo(context, 'Use the + button to create a new booking');
                      }
                    });
                  },
                  primaryActionLabel: 'Create Booking',
                  secondaryActionLabel: 'Learn More',
                  onSecondaryAction: () {
                    SnackbarService.showInfo(
                      context,
                      'Bookings represent scheduled events for your projects, studios, and gear.',
                    );
                  },
                );
              }

              return ValueListenableBuilder<BookingListViewState>(
                valueListenable: _listController.viewState,
                builder: (context, viewState, child) {
                  return ValueListenableBuilder<BookingListViewOptions>(
                    valueListenable: _listController.viewOptions,
                    builder: (context, viewOptions, child) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                        itemCount: groups.length,
                        itemBuilder: (context, groupIndex) {
                          final group = groups[groupIndex];
                          final isExpanded = viewState.expandedGroups.contains(group.id);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group header
                              if (viewOptions.groupBy != BookingGroupBy.none)
                                BookingListHeader(
                                  group: group,
                                  isExpanded: isExpanded,
                                  onToggleExpanded: () => _listController.toggleGroupExpanded(group.id),
                                  onFilterByGroup: viewOptions.groupBy == BookingGroupBy.project
                                      ? () {
                                          // Filter by project
                                          final projectId = int.tryParse(group.id.split('-').last);
                                          if (projectId != null) {
                                            widget.controller.updateFilter(
                                              widget.controller.filter.value.copyWith(
                                                projectId: projectId,
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                ),

                              // Bookings in group
                              if (isExpanded || viewOptions.groupBy == BookingGroupBy.none)
                                ...group.bookings.map((booking) {
                                  final isSelected = viewState.selectedBookingIds.contains(booking.id);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
                                    child: BookingListItem(
                                      booking: booking,
                                      controller: widget.controller,
                                      onEdit: () => _showEditBookingForm(booking),
                                      onDelete: () => _deleteBooking(booking),
                                      onTap: (booking) => _navigateToBookingDetail(booking),
                                      onLongPress: (booking) {
                                        if (booking.id != null) {
                                          _listController.toggleBookingSelected(booking.id!);
                                        }
                                      },
                                      isSelected: isSelected,
                                      viewDensity: viewOptions.viewDensity,
                                      showDetails: viewOptions.showDetails,
                                    ),
                                  );
                                }),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
