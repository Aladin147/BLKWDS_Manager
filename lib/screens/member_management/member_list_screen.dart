import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_animations.dart';
import '../../widgets/blkwds_widgets.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';

/// MemberListScreen
/// Displays a list of all members with search and filtering capabilities
class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // List of all members
  List<Member> _members = [];

  // Filtered list of members
  List<Member> _filteredMembers = [];

  // Loading state
  bool _isLoading = true;

  // Error message
  String? _errorMessage;

  // Search query
  String _searchQuery = '';

  // Selected role filter
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  // Load members from the database
  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final members = await DBService.getAllMembers();
      setState(() {
        _members = members;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load members', e, stackTrace);
      setState(() {
        _errorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Apply search and role filters
  void _applyFilters() {
    setState(() {
      _filteredMembers = _members.where((member) {
        // Apply search filter
        final matchesSearch = _searchQuery.isEmpty ||
            member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (member.role?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        // Apply role filter
        final matchesRole = _selectedRole == null ||
            member.role == _selectedRole;

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  // Get unique roles from members
  List<String?> get _uniqueRoles {
    final roles = _members.map((member) => member.role).toSet().toList();
    roles.sort((a, b) {
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    });
    return roles;
  }

  // Navigate to member detail screen
  void _navigateToMemberDetail(Member member) {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: MemberDetailScreen(member: member),
        transitionType: BLKWDSPageTransitionType.rightToLeft,
      ),
    ).then((_) => _loadMembers());
  }

  // Navigate to member form screen for adding a new member
  void _navigateToAddMember() {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: const MemberFormScreen(),
        transitionType: BLKWDSPageTransitionType.bottomToTop,
      ),
    ).then((_) => _loadMembers());
  }

  // Navigate to member form screen for editing a member
  void _navigateToEditMember(Member member) {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: MemberFormScreen(member: member),
        transitionType: BLKWDSPageTransitionType.rightToLeft,
      ),
    ).then((_) => _loadMembers());
  }

  // Delete a member
  Future<void> _deleteMember(Member member) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
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
      await DBService.deleteMember(member.id!);

      // Show success snackbar with undo option
      if (mounted) {
        SnackbarService.showSuccessSnackBar(
          context,
          '${member.name} deleted',
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await DBService.insertMember(member);
                _loadMembers();
              } catch (e, stackTrace) {
                LogService.error('Failed to restore member', e, stackTrace);
                if (mounted) {
                  SnackbarService.showErrorSnackBar(
                    context,
                    'Failed to restore member',
                  );
                }
              }
            },
          ),
        );
      }

      _loadMembers();
    } catch (e, stackTrace) {
      LogService.error('Failed to delete member', e, stackTrace);
      setState(() {
        _errorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          _errorMessage!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadMembers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Row(
              children: [
                // Search field
                Expanded(
                  flex: 3,
                  child: BLKWDSTextField(
                    label: 'Search Members',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                // Role filter dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String?>(
                    decoration: InputDecoration(
                      labelText: 'Filter by Role',
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
                    value: _selectedRole,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Roles'),
                      ),
                      ..._uniqueRoles.map((role) {
                        return DropdownMenuItem<String?>(
                          value: role,
                          child: Text(role ?? 'No Role'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Member list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: BLKWDSColors.errorRed,
                              size: 48,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingMedium),
                            Text(
                              'Error Loading Members',
                              style: BLKWDSTypography.titleLarge,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingSmall),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: BLKWDSTypography.bodyMedium,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingMedium),
                            BLKWDSButton(
                              label: 'Retry',
                              onPressed: _loadMembers,
                              type: BLKWDSButtonType.primary,
                            ),
                          ],
                        ),
                      )
                    : _filteredMembers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  color: BLKWDSColors.slateGrey,
                                  size: 48,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                Text(
                                  _members.isEmpty
                                      ? 'No Members Found'
                                      : 'No Members Match Filters',
                                  style: BLKWDSTypography.titleLarge,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                BLKWDSButton(
                                  label: 'Add Member',
                                  onPressed: _navigateToAddMember,
                                  type: BLKWDSButtonType.primary,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredMembers.length,
                            itemBuilder: (context, index) {
                              final member = _filteredMembers[index];
                              return _buildMemberCard(member);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMember,
        tooltip: 'Add Member',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build a card for a member
  Widget _buildMemberCard(Member member) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: InkWell(
        onTap: () => _navigateToMemberDetail(member),
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: Row(
            children: [
              // Member avatar placeholder
              CircleAvatar(
                radius: 24,
                backgroundColor: BLKWDSColors.accentTeal.withValues(alpha: 50),
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: BLKWDSTypography.titleLarge.copyWith(
                    color: BLKWDSColors.accentTeal,
                  ),
                ),
              ),
              const SizedBox(width: BLKWDSConstants.spacingMedium),
              // Member info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: BLKWDSTypography.titleMedium,
                    ),
                    if (member.role != null && member.role!.isNotEmpty)
                      Text(
                        member.role!,
                        style: BLKWDSTypography.bodyMedium,
                      ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                    onPressed: () => _navigateToEditMember(member),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete',
                    onPressed: () => _deleteMember(member),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
