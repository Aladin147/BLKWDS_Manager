import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../widgets/blkwds_widgets.dart';

/// MemberFormScreen
/// Screen for adding or editing a member
class MemberFormScreen extends StatefulWidget {
  final Member? member;

  const MemberFormScreen({
    super.key,
    this.member,
  });

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize form fields if editing an existing member
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      if (widget.member!.role != null) {
        _roleController.text = widget.member!.role!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  // Save the member
  void _saveMember() {
    _saveData();
  }

  // Actual save implementation
  Future<void> _saveData() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final member = widget.member != null
          ? widget.member!.copyWith(
              name: _nameController.text,
              role: _roleController.text.isNotEmpty ? _roleController.text : null,
            )
          : Member(
              name: _nameController.text,
              role: _roleController.text.isNotEmpty ? _roleController.text : null,
            );

      if (widget.member != null) {
        // Update existing member
        await DBService.updateMember(member);

        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Member updated successfully',
          );
          NavigationService.instance.goBack();
        }
      } else {
        // Insert new member
        await DBService.insertMember(member);

        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Member added successfully',
          );
          NavigationService.instance.goBack();
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to save member', e, stackTrace);
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
    final isEditing = widget.member != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Member' : 'Add Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          children: [
            // Name field
            BLKWDSFormField(
              controller: _nameController,
              label: 'Name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Role field
            BLKWDSFormField(
              controller: _roleController,
              label: 'Role (Optional)',
              prefixIcon: Icons.work,
            ),
            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: BLKWDSColors.errorRed.withValues(alpha: 20),
                  borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: BLKWDSColors.errorRed,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: BLKWDSColors.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
            ],

            // Save button
            BLKWDSButton(
              label: isEditing ? 'Update Member' : 'Add Member',
              onPressed: _isLoading ? null : _saveMember,
              type: BLKWDSButtonType.primary,
              isLoading: _isLoading,
              icon: isEditing ? Icons.save : Icons.add,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Cancel button
            BLKWDSButton(
              label: 'Cancel',
              onPressed: () => NavigationService.instance.goBack(),
              type: BLKWDSButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
