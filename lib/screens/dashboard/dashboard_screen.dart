import 'package:flutter/material.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_constants.dart';
import '../../utils/constants.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';

/// DashboardScreen
/// The main dashboard screen of the app
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data for development
  late List<Gear> _gearList;
  late List<Member> _memberList;
  late List<ActivityLog> _recentActivity;
  
  // Selected member for checkout
  Member? _selectedMember;
  
  // Search query
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    
    // Load mock data
    _gearList = MockData.getSampleGear();
    _memberList = MockData.getSampleMembers();
    _recentActivity = MockData.getSampleActivityLogs();
    
    // Set default selected member
    if (_memberList.isNotEmpty) {
      _selectedMember = _memberList.first;
    }
  }
  
  // Filter gear based on search query
  List<Gear> get _filteredGear {
    if (_searchQuery.isEmpty) {
      return _gearList;
    }
    
    return _gearList.where((gear) {
      return gear.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             gear.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  // Handle gear checkout
  void _handleCheckout(Gear gear) {
    if (_selectedMember == null) {
      _showSnackBar('Please select a member first');
      return;
    }
    
    setState(() {
      // Update gear status
      final index = _gearList.indexWhere((g) => g.id == gear.id);
      if (index != -1) {
        _gearList[index] = gear.copyWith(isOut: true);
      }
      
      // Add activity log
      _recentActivity.insert(0, ActivityLog(
        id: _recentActivity.length + 1,
        gearId: gear.id!,
        memberId: _selectedMember!.id,
        checkedOut: true,
        timestamp: DateTime.now(),
      ));
    });
    
    _showSnackBar('${gear.name} checked out to ${_selectedMember!.name}');
  }
  
  // Handle gear return
  void _handleReturn(Gear gear) {
    setState(() {
      // Update gear status
      final index = _gearList.indexWhere((g) => g.id == gear.id);
      if (index != -1) {
        _gearList[index] = gear.copyWith(isOut: false);
      }
      
      // Add activity log
      _recentActivity.insert(0, ActivityLog(
        id: _recentActivity.length + 1,
        gearId: gear.id!,
        memberId: null,
        checkedOut: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _showSnackBar('${gear.name} returned');
  }
  
  // Show a snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: BLKWDSConstants.toastDuration,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO: Navigate to calendar screen
              _showSnackBar('Calendar screen not implemented yet');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
              _showSnackBar('Settings screen not implemented yet');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Member selector and search bar
          Container(
            color: BLKWDSColors.white,
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Row(
              children: [
                // Member dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<Member>(
                    decoration: const InputDecoration(
                      labelText: 'Select Member',
                    ),
                    value: _selectedMember,
                    items: _memberList.map((member) {
                      return DropdownMenuItem<Member>(
                        value: member,
                        child: Text(member.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMember = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                // Search bar
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Gear',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Container(
            color: BLKWDSColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: BLKWDSConstants.spacingMedium,
              vertical: BLKWDSConstants.spacingSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Gear'),
                  onPressed: () {
                    // TODO: Navigate to add gear screen
                    _showSnackBar('Add gear screen not implemented yet');
                  },
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Booking Panel'),
                  onPressed: () {
                    // TODO: Navigate to booking panel
                    _showSnackBar('Booking panel not implemented yet');
                  },
                ),
              ],
            ),
          ),
          
          // Gear list
          Expanded(
            child: Container(
              color: BLKWDSColors.white.withOpacity(0.9),
              margin: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: _filteredGear.isEmpty
                  ? Center(
                      child: Text(
                        'No gear found',
                        style: BLKWDSTypography.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredGear.length,
                      itemBuilder: (context, index) {
                        final gear = _filteredGear[index];
                        return _buildGearCard(gear);
                      },
                    ),
            ),
          ),
          
          // Recent activity
          Container(
            height: 150,
            color: BLKWDSColors.white,
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: BLKWDSTypography.titleMedium,
                ),
                const SizedBox(height: BLKWDSConstants.spacingSmall),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recentActivity.length,
                    itemBuilder: (context, index) {
                      final activity = _recentActivity[index];
                      return _buildActivityItem(activity);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Build a gear card
  Widget _buildGearCard(Gear gear) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Row(
          children: [
            // Gear thumbnail placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: BLKWDSColors.slateGrey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius / 2),
              ),
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),
            // Gear info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gear.name,
                    style: BLKWDSTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gear.category,
                    style: BLKWDSTypography.bodyMedium,
                  ),
                  if (gear.lastNote != null && gear.lastNote!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${gear.lastNote}',
                      style: BLKWDSTypography.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: gear.isOut
                    ? BLKWDSColors.statusOut.withOpacity(0.2)
                    : BLKWDSColors.statusIn.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                gear.isOut ? 'OUT' : 'IN',
                style: BLKWDSTypography.labelMedium.copyWith(
                  color: gear.isOut
                      ? BLKWDSColors.statusOut
                      : BLKWDSColors.statusIn,
                ),
              ),
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),
            // Action button
            gear.isOut
                ? ElevatedButton(
                    onPressed: () => _handleReturn(gear),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BLKWDSColors.electricMint,
                    ),
                    child: const Text('Return'),
                  )
                : ElevatedButton(
                    onPressed: () => _handleCheckout(gear),
                    child: const Text('Check Out'),
                  ),
          ],
        ),
      ),
    );
  }
  
  // Build an activity item
  Widget _buildActivityItem(ActivityLog activity) {
    // Find gear and member names
    final gear = _gearList.firstWhere(
      (g) => g.id == activity.gearId,
      orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
    );
    
    final member = activity.memberId != null
        ? _memberList.firstWhere(
            (m) => m.id == activity.memberId,
            orElse: () => Member(id: 0, name: 'Unknown'),
          )
        : null;
    
    final String actionText = activity.checkedOut
        ? '${gear.name} checked out to ${member?.name ?? 'Unknown'}'
        : '${gear.name} returned';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            activity.checkedOut ? Icons.logout : Icons.login,
            color: activity.checkedOut
                ? BLKWDSColors.statusOut
                : BLKWDSColors.statusIn,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              actionText,
              style: BLKWDSTypography.bodyMedium,
            ),
          ),
          Text(
            _formatTimestamp(activity.timestamp),
            style: BLKWDSTypography.bodyMedium.copyWith(
              color: BLKWDSColors.slateGrey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  // Format a timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
