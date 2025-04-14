import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';
import '../calendar_controller.dart';

/// CalendarFilterPanel
/// Widget for filtering calendar bookings
class CalendarFilterPanel extends StatelessWidget {
  final CalendarController controller;
  final VoidCallback onResetFilters;

  const CalendarFilterPanel({
    Key? key,
    required this.controller,
    required this.onResetFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: BLKWDSColors.white,
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.slateGrey.withValues(alpha: 50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter header
          Row(
            children: [
              Text(
                'Filter Bookings',
                style: BLKWDSTypography.titleMedium,
              ),
              const Spacer(),
              BLKWDSButton(
                label: 'Reset',
                icon: Icons.refresh,
                type: BLKWDSButtonType.secondary,
                isSmall: true,
                onPressed: onResetFilters,
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          
          // Filter options
          Wrap(
            spacing: BLKWDSConstants.spacingMedium,
            runSpacing: BLKWDSConstants.spacingMedium,
            children: [
              // Project filter
              SizedBox(
                width: 200,
                child: _buildProjectFilter(),
              ),
              
              // Member filter
              SizedBox(
                width: 200,
                child: _buildMemberFilter(),
              ),
              
              // Gear filter
              SizedBox(
                width: 200,
                child: _buildGearFilter(),
              ),
              
              // Date range filters
              SizedBox(
                width: 200,
                child: _buildStartDateFilter(context),
              ),
              
              SizedBox(
                width: 200,
                child: _buildEndDateFilter(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build project filter dropdown
  Widget _buildProjectFilter() {
    return ValueListenableBuilder<int?>(
      valueListenable: controller.selectedProjectId,
      builder: (context, selectedProjectId, _) {
        return ValueListenableBuilder<List<Project>>(
          valueListenable: controller.projectList,
          builder: (context, projects, _) {
            return DropdownButtonFormField<int?>(
              decoration: const InputDecoration(
                labelText: 'Project',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.inputHorizontalPadding,
                  vertical: BLKWDSConstants.inputVerticalPadding / 2,
                ),
              ),
              value: selectedProjectId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Projects'),
                ),
                ...projects.map((project) {
                  return DropdownMenuItem<int?>(
                    value: project.id,
                    child: Text(project.title),
                  );
                }),
              ],
              onChanged: (value) {
                controller.selectedProjectId.value = value;
              },
            );
          },
        );
      },
    );
  }

  // Build member filter dropdown
  Widget _buildMemberFilter() {
    return ValueListenableBuilder<int?>(
      valueListenable: controller.selectedMemberId,
      builder: (context, selectedMemberId, _) {
        return ValueListenableBuilder<List<Member>>(
          valueListenable: controller.memberList,
          builder: (context, members, _) {
            return DropdownButtonFormField<int?>(
              decoration: const InputDecoration(
                labelText: 'Member',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.inputHorizontalPadding,
                  vertical: BLKWDSConstants.inputVerticalPadding / 2,
                ),
              ),
              value: selectedMemberId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Members'),
                ),
                ...members.map((member) {
                  return DropdownMenuItem<int?>(
                    value: member.id,
                    child: Text(member.name),
                  );
                }),
              ],
              onChanged: (value) {
                controller.selectedMemberId.value = value;
              },
            );
          },
        );
      },
    );
  }

  // Build gear filter dropdown
  Widget _buildGearFilter() {
    return ValueListenableBuilder<int?>(
      valueListenable: controller.selectedGearId,
      builder: (context, selectedGearId, _) {
        return ValueListenableBuilder<List<Gear>>(
          valueListenable: controller.gearList,
          builder: (context, gear, _) {
            return DropdownButtonFormField<int?>(
              decoration: const InputDecoration(
                labelText: 'Gear',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.inputHorizontalPadding,
                  vertical: BLKWDSConstants.inputVerticalPadding / 2,
                ),
              ),
              value: selectedGearId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Gear'),
                ),
                ...gear.map((item) {
                  return DropdownMenuItem<int?>(
                    value: item.id,
                    child: Text('${item.name} (${item.category})'),
                  );
                }),
              ],
              onChanged: (value) {
                controller.selectedGearId.value = value;
              },
            );
          },
        );
      },
    );
  }

  // Build start date filter
  Widget _buildStartDateFilter(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: controller.filterStartDate,
      builder: (context, startDate, _) {
        return BLKWDSDatePicker(
          label: 'From Date',
          selectedDate: startDate,
          hintText: 'Any start date',
          onDateSelected: (date) {
            controller.filterStartDate.value = date;
          },
        );
      },
    );
  }

  // Build end date filter
  Widget _buildEndDateFilter(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: controller.filterEndDate,
      builder: (context, endDate, _) {
        return BLKWDSDatePicker(
          label: 'To Date',
          selectedDate: endDate,
          hintText: 'Any end date',
          onDateSelected: (date) {
            // Set to end of day
            controller.filterEndDate.value = DateTime(
              date.year,
              date.month,
              date.day,
              23,
              59,
              59,
            );
          },
        );
      },
    );
  }
}
