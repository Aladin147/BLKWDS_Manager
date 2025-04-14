import 'package:flutter/material.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../booking_panel_controller.dart';
import '../models/booking_filter.dart';

/// BookingFilterBar
/// Widget for filtering and searching bookings
class BookingFilterBar extends StatefulWidget {
  final BookingPanelController controller;
  final VoidCallback onFilterChanged;

  const BookingFilterBar({
    super.key,
    required this.controller,
    required this.onFilterChanged,
  });

  @override
  State<BookingFilterBar> createState() => _BookingFilterBarState();
}

class _BookingFilterBarState extends State<BookingFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.controller.filter.value.searchQuery;

    // Listen for changes to the search field
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Handle search field changes
  void _onSearchChanged() {
    final currentFilter = widget.controller.filter.value;
    if (_searchController.text != currentFilter.searchQuery) {
      widget.controller.updateFilter(
        currentFilter.copyWith(searchQuery: _searchController.text),
      );
      widget.onFilterChanged();
    }
  }

  // Toggle filter panel visibility
  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _searchController.text = '';
    });
    widget.controller.resetFilters();
    widget.onFilterChanged();
  }

  // Select a date range
  Future<void> _selectDateRange() async {
    final currentFilter = widget.controller.filter.value;
    final initialDateRange = currentFilter.dateRange ?? DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: BLKWDSColors.blkwdsGreen,
              onPrimary: BLKWDSColors.white,
              surface: BLKWDSColors.white,
              onSurface: BLKWDSColors.slateGrey,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      widget.controller.updateFilter(
        currentFilter.copyWith(dateRange: pickedDateRange),
      );
      widget.onFilterChanged();
    }
  }

  // Select a project
  void _selectProject() {
    final currentFilter = widget.controller.filter.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Project'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.controller.projectList.value.length,
            itemBuilder: (context, index) {
              final project = widget.controller.projectList.value[index];
              final isSelected = currentFilter.projectId == project.id;

              return ListTile(
                title: Text(project.title),
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop();

                  if (isSelected) {
                    // Deselect the project
                    widget.controller.updateFilter(
                      currentFilter.copyWith(clearProjectId: true),
                    );
                  } else {
                    // Select the project
                    widget.controller.updateFilter(
                      currentFilter.copyWith(projectId: project.id),
                    );
                  }

                  widget.onFilterChanged();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Select a member
  void _selectMember() {
    final currentFilter = widget.controller.filter.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Member'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.controller.memberList.value.length,
            itemBuilder: (context, index) {
              final member = widget.controller.memberList.value[index];
              final isSelected = currentFilter.memberId == member.id;

              return ListTile(
                title: Text(member.name),
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop();

                  if (isSelected) {
                    // Deselect the member
                    widget.controller.updateFilter(
                      currentFilter.copyWith(clearMemberId: true),
                    );
                  } else {
                    // Select the member
                    widget.controller.updateFilter(
                      currentFilter.copyWith(memberId: member.id),
                    );
                  }

                  widget.onFilterChanged();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Select a gear item
  void _selectGear() {
    final currentFilter = widget.controller.filter.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gear'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.controller.gearList.value.length,
            itemBuilder: (context, index) {
              final gear = widget.controller.gearList.value[index];
              final isSelected = currentFilter.gearId == gear.id;

              return ListTile(
                title: Text(gear.name),
                subtitle: Text(gear.category),
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop();

                  if (isSelected) {
                    // Deselect the gear
                    widget.controller.updateFilter(
                      currentFilter.copyWith(clearGearId: true),
                    );
                  } else {
                    // Select the gear
                    widget.controller.updateFilter(
                      currentFilter.copyWith(gearId: gear.id),
                    );
                  }

                  widget.onFilterChanged();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Toggle studio filter
  void _toggleStudioFilter(bool isRecording) {
    final currentFilter = widget.controller.filter.value;

    if (isRecording) {
      final newValue = currentFilter.isRecordingStudio == null
          ? true
          : (currentFilter.isRecordingStudio == true ? null : true);

      widget.controller.updateFilter(
        currentFilter.copyWith(isRecordingStudio: newValue),
      );
    } else {
      final newValue = currentFilter.isProductionStudio == null
          ? true
          : (currentFilter.isProductionStudio == true ? null : true);

      widget.controller.updateFilter(
        currentFilter.copyWith(isProductionStudio: newValue),
      );
    }

    widget.onFilterChanged();
  }

  // Change sort order
  void _changeSortOrder(BookingSortOrder sortOrder) {
    final currentFilter = widget.controller.filter.value;

    widget.controller.updateFilter(
      currentFilter.copyWith(sortOrder: sortOrder),
    );

    widget.onFilterChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BookingFilter>(
      valueListenable: widget.controller.filter,
      builder: (context, filter, child) {
        final hasActiveFilters = filter.isActive;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search and filter bar
            Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search bookings...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),

                // Filter button
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: hasActiveFilters
                        ? BLKWDSColors.blkwdsGreen
                        : BLKWDSColors.slateGrey,
                  ),
                  onPressed: _toggleFilters,
                  tooltip: 'Filter',
                ),

                // Sort button
                PopupMenuButton<BookingSortOrder>(
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sort',
                  onSelected: _changeSortOrder,
                  itemBuilder: (context) => BookingSortOrder.values.map((sortOrder) {
                    return PopupMenuItem<BookingSortOrder>(
                      value: sortOrder,
                      child: Row(
                        children: [
                          Icon(
                            filter.sortOrder == sortOrder
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: filter.sortOrder == sortOrder
                                ? BLKWDSColors.blkwdsGreen
                                : BLKWDSColors.slateGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(sortOrder.label),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // Filter panel (expandable)
            if (_showFilters) ...[
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter title and reset button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters',
                            style: BLKWDSTypography.titleSmall,
                          ),
                          if (hasActiveFilters)
                            TextButton.icon(
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Reset All'),
                              onPressed: _resetFilters,
                            ),
                        ],
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingSmall),

                      // Filter options
                      Wrap(
                        spacing: BLKWDSConstants.spacingSmall,
                        runSpacing: BLKWDSConstants.spacingSmall,
                        children: [
                          // Date range filter
                          FilterChip(
                            label: Text(
                              filter.dateRange != null
                                  ? '${filter.dateRange!.start.day}/${filter.dateRange!.start.month} - ${filter.dateRange!.end.day}/${filter.dateRange!.end.month}'
                                  : 'Date Range',
                            ),
                            selected: filter.dateRange != null,
                            onSelected: (_) => _selectDateRange(),
                            avatar: const Icon(Icons.calendar_today),
                          ),

                          // Project filter
                          FilterChip(
                            label: Text(
                              filter.projectId != null
                                  ? widget.controller.getProjectById(filter.projectId!)?.title ?? 'Project'
                                  : 'Project',
                            ),
                            selected: filter.projectId != null,
                            onSelected: (_) => _selectProject(),
                            avatar: const Icon(Icons.work),
                          ),

                          // Member filter
                          FilterChip(
                            label: Text(
                              filter.memberId != null
                                  ? widget.controller.getMemberById(filter.memberId!)?.name ?? 'Member'
                                  : 'Member',
                            ),
                            selected: filter.memberId != null,
                            onSelected: (_) => _selectMember(),
                            avatar: const Icon(Icons.person),
                          ),

                          // Gear filter
                          FilterChip(
                            label: Text(
                              filter.gearId != null
                                  ? widget.controller.getGearById(filter.gearId!)?.name ?? 'Gear'
                                  : 'Gear',
                            ),
                            selected: filter.gearId != null,
                            onSelected: (_) => _selectGear(),
                            avatar: const Icon(Icons.camera_alt),
                          ),

                          // Recording studio filter
                          FilterChip(
                            label: const Text('Recording Studio'),
                            selected: filter.isRecordingStudio == true,
                            onSelected: (_) => _toggleStudioFilter(true),
                            avatar: const Icon(Icons.mic),
                          ),

                          // Production studio filter
                          FilterChip(
                            label: const Text('Production Studio'),
                            selected: filter.isProductionStudio == true,
                            onSelected: (_) => _toggleStudioFilter(false),
                            avatar: const Icon(Icons.videocam),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Active filters summary
            if (hasActiveFilters && !_showFilters) ...[
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Active filters:',
                      style: BLKWDSTypography.labelSmall,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),

                    // Date range chip
                    if (filter.dateRange != null)
                      Chip(
                        label: Text(
                          '${filter.dateRange!.start.day}/${filter.dateRange!.start.month} - ${filter.dateRange!.end.day}/${filter.dateRange!.end.month}',
                          style: BLKWDSTypography.labelSmall,
                        ),
                        onDeleted: () {
                          widget.controller.updateFilter(
                            filter.copyWith(clearDateRange: true),
                          );
                          widget.onFilterChanged();
                        },
                      ),

                    // Project chip
                    if (filter.projectId != null)
                      Chip(
                        label: Text(
                          widget.controller.getProjectById(filter.projectId!)?.title ?? 'Project',
                          style: BLKWDSTypography.labelSmall,
                        ),
                        onDeleted: () {
                          widget.controller.updateFilter(
                            filter.copyWith(clearProjectId: true),
                          );
                          widget.onFilterChanged();
                        },
                      ),

                    // Member chip
                    if (filter.memberId != null)
                      Chip(
                        label: Text(
                          widget.controller.getMemberById(filter.memberId!)?.name ?? 'Member',
                          style: BLKWDSTypography.labelSmall,
                        ),
                        onDeleted: () {
                          widget.controller.updateFilter(
                            filter.copyWith(clearMemberId: true),
                          );
                          widget.onFilterChanged();
                        },
                      ),

                    // Gear chip
                    if (filter.gearId != null)
                      Chip(
                        label: Text(
                          widget.controller.getGearById(filter.gearId!)?.name ?? 'Gear',
                          style: BLKWDSTypography.labelSmall,
                        ),
                        onDeleted: () {
                          widget.controller.updateFilter(
                            filter.copyWith(clearGearId: true),
                          );
                          widget.onFilterChanged();
                        },
                      ),

                    // Studio chips
                    if (filter.isRecordingStudio == true)
                      Chip(
                        label: const Text(
                          'Recording Studio',
                          style: TextStyle(fontSize: 12),
                        ),
                        onDeleted: () {
                          widget.controller.updateFilter(
                            filter.copyWith(isRecordingStudio: null),
                          );
                          widget.onFilterChanged();
                        },
                      ),

                    if (filter.isProductionStudio == true)
                      Chip(
                        label: const Text(
                          'Production Studio',
                          style: TextStyle(fontSize: 12),
                        ),
                        onDeleted: () {
                          widget.controller.updateFilter(
                            filter.copyWith(isProductionStudio: null),
                          );
                          widget.onFilterChanged();
                        },
                      ),

                    // Reset all button
                    TextButton.icon(
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Reset All'),
                      onPressed: _resetFilters,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
