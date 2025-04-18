import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../services/db_service.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';


import '../../../widgets/blkwds_widgets.dart';
import '../booking_panel_controller.dart';

/// BookingForm
/// Form for creating and editing bookings
class BookingForm extends StatefulWidget {
  final BookingPanelController controller;
  final Booking? booking; // Null for new booking, non-null for editing
  final Function(Booking) onSave;
  final VoidCallback onCancel;

  const BookingForm({
    super.key,
    required this.controller,
    this.booking,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  late int? _selectedProjectId;
  late String? _title;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late int? _selectedStudioId;
  late List<int> _selectedGearIds;
  late Map<int, int> _assignedGearToMember;

  // Text controller for title
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize form fields
    if (widget.booking != null) {
      // Editing existing booking
      _selectedProjectId = widget.booking!.projectId;
      _title = widget.booking!.title;
      _titleController.text = _title ?? '';
      _startDate = widget.booking!.startDate;
      _startTime = TimeOfDay.fromDateTime(widget.booking!.startDate);
      _endDate = widget.booking!.endDate;
      _endTime = TimeOfDay.fromDateTime(widget.booking!.endDate);
      _selectedStudioId = widget.booking!.studioId;
      _selectedGearIds = List.from(widget.booking!.gearIds);
      _assignedGearToMember = Map.from(widget.booking!.assignedGearToMember ?? {});
    } else {
      // Creating new booking
      _selectedProjectId = widget.controller.projectList.value.isNotEmpty ?
          widget.controller.projectList.value.first.id : null;
      _title = null;

      final now = DateTime.now();
      _startDate = now;
      _startTime = TimeOfDay.fromDateTime(now);

      final tomorrow = now.add(const Duration(days: 1));
      _endDate = tomorrow;
      _endTime = TimeOfDay.fromDateTime(tomorrow);

      _selectedStudioId = null;
      _selectedGearIds = [];
      _assignedGearToMember = {};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Combine date and time into a DateTime
  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // Save the booking
  void _saveBooking() {
    if (_formKey.currentState!.validate()) {
      // Get title from controller or use default
      final title = _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Booking for ${widget.controller.getProjectById(_selectedProjectId!)?.title ?? 'Unknown Project'}';

      // Create booking object
      final booking = Booking(
        id: widget.booking?.id,
        projectId: _selectedProjectId!,
        title: title,
        startDate: _combineDateAndTime(_startDate, _startTime),
        endDate: _combineDateAndTime(_endDate, _endTime),
        studioId: _selectedStudioId,
        gearIds: _selectedGearIds,
        assignedGearToMember: _assignedGearToMember.isEmpty ? null : _assignedGearToMember,
      );

      // Call onSave callback
      widget.onSave(booking);
    }
  }

  // Pick a date
  Future<void> _pickDate(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // If end date is before start date, update it
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // Pick a time
  Future<void> _pickTime(bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;

          // If start and end dates are the same and end time is before start time, update it
          if (_startDate.year == _endDate.year &&
              _startDate.month == _endDate.month &&
              _startDate.day == _endDate.day &&
              _endTime.hour < _startTime.hour) {
            _endTime = TimeOfDay(hour: _startTime.hour + 1, minute: _startTime.minute);
          }
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Project dropdown
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Project *',
            ),
            value: _selectedProjectId,
            items: widget.controller.projectList.value.map((project) {
              return DropdownMenuItem<int>(
                value: project.id,
                child: Text(project.title),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProjectId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Project is required';
              }
              return null;
            },
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Title field
          BLKWDSTextField(
            controller: _titleController,
            label: 'Booking Title (Optional)',
            prefixIcon: Icons.title,
            hintText: 'Enter a title for this booking',
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Date and time pickers
          Row(
            children: [
              // Start date and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BLKWDSEnhancedText.labelLarge(
                      'Start Date & Time *',
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    InkWell(
                      onTap: () => _pickDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: BLKWDSEnhancedText.bodyMedium(
                          DateFormat.yMMMd().format(_startDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    InkWell(
                      onTap: () => _pickTime(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.access_time),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: BLKWDSEnhancedText.bodyMedium(
                          _startTime.format(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BLKWDSConstants.spacingMedium),

              // End date and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BLKWDSEnhancedText.labelLarge(
                      'End Date & Time *',
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    InkWell(
                      onTap: () => _pickDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: BLKWDSEnhancedText.bodyMedium(
                          DateFormat.yMMMd().format(_endDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    InkWell(
                      onTap: () => _pickTime(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.access_time),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: BLKWDSEnhancedText.bodyMedium(
                          _endTime.format(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Studio dropdown
          BLKWDSEnhancedText.labelLarge(
            'Studio Space',
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          FutureBuilder<List<Studio>>(
            future: DBService.getAllStudios(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return BLKWDSEnhancedLoadingIndicator();
              }

              if (snapshot.hasError) {
                return BLKWDSEnhancedText.bodyMedium(
                  'Error loading studios: ${snapshot.error}',
                  color: BLKWDSColors.errorRed,
                );
              }

              final studios = snapshot.data ?? [];

              return DropdownButtonFormField<int?>(
                decoration: const InputDecoration(
                  labelText: 'Select Studio (Optional)',
                ),
                value: _selectedStudioId,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...studios.map((studio) {
                    return DropdownMenuItem<int?>(
                      value: studio.id,
                      child: Row(
                        children: [
                          Icon(studio.type.icon, size: 20),
                          const SizedBox(width: BLKWDSConstants.spacingSmall),
                          Text(studio.name),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStudioId = value;
                  });
                },
              );
            },
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Gear selection
          BLKWDSEnhancedText.labelLarge(
            'Gear Selection',
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: BLKWDSColors.backgroundMedium,
              border: Border.all(color: BLKWDSColors.slateGrey.withValues(alpha: 100)),
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: BLKWDSColors.deepBlack.withValues(alpha: 40),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: widget.controller.gearList.value.length,
              itemBuilder: (context, index) {
                final gear = widget.controller.gearList.value[index];
                final isSelected = _selectedGearIds.contains(gear.id);

                return CheckboxListTile(
                  title: Text(gear.name),
                  subtitle: Text(gear.category),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedGearIds.add(gear.id!);
                      } else {
                        _selectedGearIds.remove(gear.id);
                        _assignedGearToMember.remove(gear.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Member assignment (only if gear is selected)
          if (_selectedGearIds.isNotEmpty) ...[
            BLKWDSEnhancedText.labelLarge(
              'Gear-to-Member Assignment (Optional)',
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: BLKWDSColors.backgroundMedium,
                border: Border.all(color: BLKWDSColors.slateGrey.withValues(alpha: 100)),
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: BLKWDSColors.deepBlack.withValues(alpha: 40),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: _selectedGearIds.length,
                itemBuilder: (context, index) {
                  final gearId = _selectedGearIds[index];
                  final gear = widget.controller.getGearById(gearId);
                  final assignedMemberId = _assignedGearToMember[gearId];

                  return ListTile(
                    title: Text(gear?.name ?? 'Unknown Gear'),
                    subtitle: DropdownButton<int?>(
                      value: assignedMemberId,
                      hint: const Text('Assign to member'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...widget.controller.memberList.value.map((member) {
                          return DropdownMenuItem<int?>(
                            value: member.id,
                            child: Text(member.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == null) {
                            _assignedGearToMember.remove(gearId);
                          } else {
                            _assignedGearToMember[gearId] = value;
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
          ],

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BLKWDSEnhancedButton(
                label: 'Cancel',
                onPressed: widget.onCancel,
                type: BLKWDSEnhancedButtonType.secondary,
              ),
              const SizedBox(width: BLKWDSConstants.spacingMedium),
              BLKWDSEnhancedButton(
                label: widget.booking == null ? 'Create Booking' : 'Update Booking',
                onPressed: _saveBooking,
                type: BLKWDSEnhancedButtonType.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
