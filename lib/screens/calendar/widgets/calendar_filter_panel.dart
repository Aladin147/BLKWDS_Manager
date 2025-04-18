import 'package:flutter/material.dart';
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
    super.key,
    required this.controller,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: BLKWDSColors.backgroundMedium,
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.deepBlack.withValues(alpha: 40),
            blurRadius: 6,
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
                style: BLKWDSTypography.titleMedium.copyWith(
                  color: BLKWDSColors.textPrimary,
                ),
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
              decoration: InputDecoration(
                labelText: 'Project',
                labelStyle: TextStyle(color: BLKWDSColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                  borderSide: BorderSide(color: BLKWDSColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                  borderSide: BorderSide(color: BLKWDSColors.accentTeal, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.inputHorizontalPadding,
                  vertical: BLKWDSConstants.inputVerticalPadding / 2,
                ),
                filled: true,
                fillColor: BLKWDSColors.inputBackground,
              ),
              dropdownColor: BLKWDSColors.backgroundMedium,
              style: TextStyle(color: BLKWDSColors.textPrimary),
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
              decoration: InputDecoration(
                labelText: 'Member',
                labelStyle: TextStyle(color: BLKWDSColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                  borderSide: BorderSide(color: BLKWDSColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                  borderSide: BorderSide(color: BLKWDSColors.accentTeal, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.inputHorizontalPadding,
                  vertical: BLKWDSConstants.inputVerticalPadding / 2,
                ),
                filled: true,
                fillColor: BLKWDSColors.inputBackground,
              ),
              dropdownColor: BLKWDSColors.backgroundMedium,
              style: TextStyle(color: BLKWDSColors.textPrimary),
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
              decoration: InputDecoration(
                labelText: 'Gear',
                labelStyle: TextStyle(color: BLKWDSColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                  borderSide: BorderSide(color: BLKWDSColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                  borderSide: BorderSide(color: BLKWDSColors.accentTeal, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.inputHorizontalPadding,
                  vertical: BLKWDSConstants.inputVerticalPadding / 2,
                ),
                isDense: true,
                filled: true,
                fillColor: BLKWDSColors.inputBackground,
              ),
              dropdownColor: BLKWDSColors.backgroundMedium,
              style: TextStyle(color: BLKWDSColors.textPrimary),
              isExpanded: true,
              value: selectedGearId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Gear'),
                ),
                ...gear.map((item) {
                  return DropdownMenuItem<int?>(
                    value: item.id,
                    child: Text(
                      '${item.name} (${item.category})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
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
