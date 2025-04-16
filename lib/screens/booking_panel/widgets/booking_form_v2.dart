import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';
import '../booking_panel_controller_v2.dart';

/// BookingFormV2
/// Form for creating and editing Booking objects
class BookingFormV2 extends StatefulWidget {
  final BookingPanelControllerV2 controller;
  final Booking? booking;
  final Function(Booking) onSave;
  final VoidCallback onCancel;

  const BookingFormV2({
    super.key,
    required this.controller,
    this.booking,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<BookingFormV2> createState() => _BookingFormV2State();
}

class _BookingFormV2State extends State<BookingFormV2> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _notesController;

  // Form values
  late int _projectId;
  late DateTime _startDate;
  late DateTime _endDate;
  late int? _studioId;
  late List<int> _gearIds;
  late Map<int, int> _assignedGearToMember;

  // UI state
  bool _isLoading = false;
  bool _isStudioBooking = false;
  bool _isGearBooking = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  // Initialize form with booking data or defaults
  void _initializeForm() {
    if (widget.booking != null) {
      // Editing existing booking
      final booking = widget.booking!;
      _titleController = TextEditingController(text: booking.title);
      _notesController = TextEditingController(text: booking.notes);
      _projectId = booking.projectId;
      _startDate = booking.startDate;
      _endDate = booking.endDate;
      _studioId = booking.studioId;
      _gearIds = List.from(booking.gearIds);
      _assignedGearToMember = Map.from(booking.assignedGearToMember ?? {});
      _isStudioBooking = booking.studioId != null;
      _isGearBooking = booking.gearIds.isNotEmpty;
    } else {
      // Creating new booking
      _titleController = TextEditingController();
      _notesController = TextEditingController();
      _projectId = widget.controller.projectList.value.isNotEmpty
          ? widget.controller.projectList.value.first.id!
          : 0;
      _startDate = DateTime.now().add(const Duration(hours: 1));
      _endDate = _startDate.add(const Duration(hours: 2));
      _studioId = null;
      _gearIds = [];
      _assignedGearToMember = {};
      _isStudioBooking = false;
      _isGearBooking = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Save the booking
  void _saveBooking() {
    if (_formKey.currentState!.validate()) {
      final booking = Booking(
        id: widget.booking?.id,
        projectId: _projectId,
        title: _titleController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        startDate: _startDate,
        endDate: _endDate,
        studioId: _isStudioBooking ? _studioId : null,
        gearIds: _isGearBooking ? _gearIds : [],
        assignedGearToMember: _assignedGearToMember.isNotEmpty ? _assignedGearToMember : null,
      );

      widget.onSave(booking);
    }
  }

  // Show date picker
  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final initialTime = TimeOfDay.fromDateTime(initialDate);
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStartDate) {
            _startDate = newDateTime;
            // Ensure end date is after start date
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
            }
          } else {
            _endDate = newDateTime;
            // Ensure start date is before end date
            if (_startDate.isAfter(_endDate)) {
              _startDate = _endDate.subtract(const Duration(hours: 1));
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project dropdown
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Project',
              border: OutlineInputBorder(),
            ),
            value: _projectId,
            items: widget.controller.projectList.value.map((project) {
              return DropdownMenuItem<int>(
                value: project.id!,
                child: Text(project.title),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _projectId = value;
                });
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a project';
              }
              return null;
            },
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Title field
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Date and time pickers
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date & Time',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date & Time',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Booking type selection
          Text(
            'Booking Type',
            style: BLKWDSTypography.titleMedium,
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Studio Booking'),
                  value: _isStudioBooking,
                  onChanged: (value) {
                    setState(() {
                      _isStudioBooking = value ?? false;
                      if (_isStudioBooking && _studioId == null && widget.controller.studioList.value.isNotEmpty) {
                        _studioId = widget.controller.studioList.value.first.id;
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Gear Booking'),
                  value: _isGearBooking,
                  onChanged: (value) {
                    setState(() {
                      _isGearBooking = value ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Studio selection (if studio booking)
          if (_isStudioBooking) ...[
            Text(
              'Studio',
              style: BLKWDSTypography.titleMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Select Studio',
                border: OutlineInputBorder(),
              ),
              value: _studioId,
              items: widget.controller.studioList.value.map((studio) {
                return DropdownMenuItem<int>(
                  value: studio.id,
                  child: Text('${studio.name} (${_getStudioTypeText(studio.type)})'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _studioId = value;
                  });
                }
              },
              validator: (value) {
                if (_isStudioBooking && value == null) {
                  return 'Please select a studio';
                }
                return null;
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
          ],

          // Gear selection (if gear booking)
          if (_isGearBooking) ...[
            Text(
              'Gear',
              style: BLKWDSTypography.titleMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Text(
              'Gear selection will be implemented in a future update',
              style: BLKWDSTypography.bodyMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
          ],

          // Notes field
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: BLKWDSConstants.spacingLarge),

          // Form actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBooking,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Get text for studio type
  String _getStudioTypeText(StudioType type) {
    switch (type) {
      case StudioType.recording:
        return 'Recording';
      case StudioType.production:
        return 'Production';
      case StudioType.hybrid:
        return 'Hybrid';
    }
  }
}
