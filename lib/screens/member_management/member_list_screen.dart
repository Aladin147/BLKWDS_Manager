import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../widgets/blkwds_widgets.dart';

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

  // No role filter - removed to simplify UI

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
        SnackbarService.showError(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Apply search filter only
  void _applyFilters() {
    setState(() {
      _filteredMembers = _members.where((member) {
        // Apply search filter
        final matchesSearch = _searchQuery.isEmpty ||
            member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (member.role?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        return matchesSearch;
      }).toList();
    });
  }

  // Role filtering removed to simplify UI

  // Navigate to member detail screen
  void _navigateToMemberDetail(Member member) async {
    await NavigationHelper.navigateToMemberDetail(member);
    _loadMembers();
  }

  // Navigate to member form screen for adding a new member
  void _navigateToAddMember() async {
    await NavigationHelper.navigateToMemberForm();
    _loadMembers();
  }

  // Navigate to member form screen for editing a member
  void _navigateToEditMember(Member member) async {
    await NavigationHelper.navigateToMemberForm(member: member);
    _loadMembers();
  }

  // Delete a member
  Future<void> _deleteMember(Member member) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BLKWDSEnhancedAlertDialog(
        title: 'Delete Member',
        content: 'Are you sure you want to delete ${member.name}?',
        secondaryActionText: 'Cancel',
        onSecondaryAction: () => Navigator.pop(context, false),
        primaryActionText: 'Delete',
        onPrimaryAction: () => Navigator.pop(context, true),
        isPrimaryDestructive: true,
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
        SnackbarService.showSuccess(
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
                  SnackbarService.showError(
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
        SnackbarService.showError(
          context,
          _errorMessage!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: 'Member Management',
      showHomeButton: true,
      actions: [
        BLKWDSEnhancedButton.icon(
          icon: Icons.refresh,
          onPressed: _loadMembers,
          type: BLKWDSEnhancedButtonType.tertiary,
          backgroundColor: Colors.transparent,
          foregroundColor: BLKWDSColors.white,
        ),
      ],
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
                  child: BLKWDSEnhancedFormField(
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
                // Role filter dropdown removed to simplify UI
              ],
            ),
          ),

          // Member list
          Expanded(
            child: _isLoading
                ? const Center(child: BLKWDSEnhancedLoadingIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BLKWDSEnhancedIconContainer(
                              icon: Icons.error_outline,
                              size: BLKWDSEnhancedIconContainerSize.large,
                              backgroundColor: BLKWDSColors.errorRed.withAlpha(51),
                              iconColor: BLKWDSColors.errorRed,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingMedium),
                            BLKWDSEnhancedText.titleLarge(
                              'Error Loading Members',
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingSmall),
                            BLKWDSEnhancedText.bodyMedium(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingMedium),
                            BLKWDSEnhancedButton(
                              label: 'Retry',
                              onPressed: _loadMembers,
                              type: BLKWDSEnhancedButtonType.primary,
                              icon: Icons.refresh,
                            ),
                          ],
                        ),
                      )
                    : _filteredMembers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BLKWDSEnhancedIconContainer(
                                  icon: Icons.people_outline,
                                  size: BLKWDSEnhancedIconContainerSize.large,
                                  backgroundColor: BLKWDSColors.slateGrey.withAlpha(51),
                                  iconColor: BLKWDSColors.slateGrey,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                BLKWDSEnhancedText.titleLarge(
                                  _members.isEmpty
                                      ? 'No Members Found'
                                      : 'No Members Match Filters',
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                BLKWDSEnhancedButton(
                                  label: 'Add Member',
                                  onPressed: _navigateToAddMember,
                                  type: BLKWDSEnhancedButtonType.primary,
                                  icon: Icons.person_add,
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
      floatingActionButton: BLKWDSEnhancedFloatingActionButton(
        onPressed: _navigateToAddMember,
        tooltip: 'Add Member',
        icon: Icons.person_add,
      ),
    );
  }

  // Build a card for a member
  Widget _buildMemberCard(Member member) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: BLKWDSEnhancedCard(
        onTap: () => _navigateToMemberDetail(member),
        animateOnHover: true,
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Row(
          children: [
            // Member avatar
            MemberAvatarWidget(
              member: member,
              size: 48,
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),
            // Member info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BLKWDSEnhancedText.bodyLarge(
                    member.name,
                  ),
                  if (member.role != null && member.role!.isNotEmpty)
                    BLKWDSEnhancedText.bodyMedium(
                      member.role!,
                      color: BLKWDSColors.textSecondary,
                    ),
                ],
              ),
            ),
            // Action buttons
            Row(
              children: [
                Tooltip(
                  message: 'Edit',
                  child: BLKWDSEnhancedButton.icon(
                    icon: Icons.edit,
                    onPressed: () => _navigateToEditMember(member),
                    type: BLKWDSEnhancedButtonType.tertiary,
                  ),
                ),
                Tooltip(
                  message: 'Delete',
                  child: BLKWDSEnhancedButton.icon(
                    icon: Icons.delete,
                    onPressed: () => _deleteMember(member),
                    type: BLKWDSEnhancedButtonType.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
