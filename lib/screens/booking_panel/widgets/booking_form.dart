import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../utils/constants.dart';
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
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late bool _isRecordingStudio;
  late bool _isProductionStudio;
  late List<int> _selectedGearIds;
  late Map<int, int> _assignedGearToMember;

  @override
  void initState() {
    super.initState();
    
    // Initialize form fields
    if (widget.booking != null) {
      // Editing existing booking
      _selectedProjectId = widget.booking!.projectId;
      _startDate = widget.booking!.startDate;
      _startTime = TimeOfDay.fromDateTime(widget.booking!.startDate);
      _endDate = widget.booking!.endDate;
      _endTime = TimeOfDay.fromDateTime(widget.booking!.endDate);
      _isRecordingStudio = widget.booking!.isRecordingStudio;
      _isProductionStudio = widget.booking!.isProductionStudio;
      _selectedGearIds = List.from(widget.booking!.gearIds);
      _assignedGearToMember = Map.from(widget.booking!.assignedGearToMember ?? {});
    } else {
      // Creating new booking
      _selectedProjectId = widget.controller.projectList.value.isNotEmpty ? 
          widget.controller.projectList.value.first.id : null;
      
      final now = DateTime.now();
      _startDate = now;
      _startTime = TimeOfDay.fromDateTime(now);
      
      final tomorrow = now.add(const Duration(days: 1));
      _endDate = tomorrow;
      _endTime = TimeOfDay.fromDateTime(tomorrow);
      
      _isRecordingStudio = false;
      _isProductionStudio = false;
      _selectedGearIds = [];
      _assignedGearToMember = {};
    }
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
      // Create booking object
      final booking = Booking(
        id: widget.booking?.id,
        projectId: _selectedProjectId!,
        startDate: _combineDateAndTime(_startDate, _startTime),
        endDate: _combineDateAndTime(_endDate, _endTime),
        isRecordingStudio: _isRecordingStudio,
        isProductionStudio: _isProductionStudio,
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
          
          // Date and time pickers
          Row(
            children: [
              // Start date and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date & Time *',
                      style: BLKWDSTypography.labelMedium,
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
                        child: Text(
                          DateFormat.yMMMd().format(_startDate),
                          style: BLKWDSTypography.bodyMedium,
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
                        child: Text(
                          _startTime.format(context),
                          style: BLKWDSTypography.bodyMedium,
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
                    Text(
                      'End Date & Time *',
                      style: BLKWDSTypography.labelMedium,
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
                        child: Text(
                          DateFormat.yMMMd().format(_endDate),
                          style: BLKWDSTypography.bodyMedium,
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
                        child: Text(
                          _endTime.format(context),
                          style: BLKWDSTypography.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          
          // Studio checkboxes
          Text(
            'Studio Space',
            style: BLKWDSTypography.labelMedium,
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Recording Studio'),
                  value: _isRecordingStudio,
                  onChanged: (value) {
                    setState(() {
                      _isRecordingStudio = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Production Studio'),
                  value: _isProductionStudio,
                  onChanged: (value) {
                    setState(() {
                      _isProductionStudio = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          
          // Gear selection
          Text(
            'Gear Selection',
            style: BLKWDSTypography.labelMedium,
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: BLKWDSColors.slateGrey.withValues(alpha: 100)),
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
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
            Text(
              'Gear-to-Member Assignment (Optional)',
              style: BLKWDSTypography.labelMedium,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: BLKWDSColors.slateGrey.withValues(alpha: 100)),
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
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
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: BLKWDSConstants.spacingMedium),
              ElevatedButton(
                onPressed: _saveBooking,
                child: Text(widget.booking == null ? 'Create Booking' : 'Update Booking'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
