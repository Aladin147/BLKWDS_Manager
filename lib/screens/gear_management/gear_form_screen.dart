import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../widgets/blkwds_widgets.dart';
// Enhanced widgets are imported via blkwds_widgets.dart

/// GearFormScreen
/// Screen for adding or editing gear
class GearFormScreen extends StatefulWidget {
  final Gear? gear;

  const GearFormScreen({
    super.key,
    this.gear,
  });

  @override
  State<GearFormScreen> createState() => _GearFormScreenState();
}

class _GearFormScreenState extends State<GearFormScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Date
  DateTime? _purchaseDate;

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize form fields if editing an existing gear
    if (widget.gear != null) {
      _nameController.text = widget.gear!.name;
      _categoryController.text = widget.gear!.category;
      if (widget.gear!.serialNumber != null) {
        _serialNumberController.text = widget.gear!.serialNumber!;
      }
      if (widget.gear!.description != null) {
        _descriptionController.text = widget.gear!.description!;
      }
      _purchaseDate = widget.gear!.purchaseDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _serialNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Save the gear
  void _saveGear() {
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
      final gear = widget.gear != null
          ? widget.gear!.copyWith(
              name: _nameController.text,
              category: _categoryController.text,
              serialNumber: _serialNumberController.text.isNotEmpty ? _serialNumberController.text : null,
              description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
              purchaseDate: _purchaseDate,
            )
          : Gear(
              name: _nameController.text,
              category: _categoryController.text,
              serialNumber: _serialNumberController.text.isNotEmpty ? _serialNumberController.text : null,
              description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
              purchaseDate: _purchaseDate,
            );

      if (widget.gear != null) {
        // Update existing gear
        await DBService.updateGear(gear);

        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Gear updated successfully',
          );
          NavigationHelper.goBack();
        }
      } else {
        // Insert new gear
        await DBService.insertGear(gear);

        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Gear added successfully',
          );
          NavigationHelper.goBack();
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to save gear', e, stackTrace);
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

  // Select purchase date
  Future<void> _selectPurchaseDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _purchaseDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gear != null;

    return BLKWDSScaffold(
      title: isEditing ? 'Edit Gear' : 'Add Gear',
      showHomeButton: true,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          children: [
            // Name field
            BLKWDSEnhancedFormField(
              controller: _nameController,
              label: 'Name',
              prefixIcon: Icons.videocam,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Category field
            BLKWDSEnhancedFormField(
              controller: _categoryController,
              label: 'Category',
              prefixIcon: Icons.category,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Serial number field
            BLKWDSEnhancedFormField(
              controller: _serialNumberController,
              label: 'Serial Number (Optional)',
              prefixIcon: Icons.qr_code,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Purchase date field
            GestureDetector(
              onTap: _selectPurchaseDate,
              child: AbsorbPointer(
                child: BLKWDSEnhancedFormField(
                  label: 'Purchase Date (Optional)',
                  prefixIcon: Icons.calendar_today,
                  controller: TextEditingController(
                    text: _purchaseDate != null
                        ? '${_purchaseDate!.year}-${_purchaseDate!.month.toString().padLeft(2, '0')}-${_purchaseDate!.day.toString().padLeft(2, '0')}'
                        : 'Select a date',
                  ),
                ),
              ),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Description field
            BLKWDSEnhancedFormField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              prefixIcon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Error message
            if (_errorMessage != null) ...[
              BLKWDSEnhancedCard(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                backgroundColor: BLKWDSColors.errorRed.withValues(alpha: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: BLKWDSColors.errorRed,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                    Expanded(
                      child: BLKWDSEnhancedText.bodyMedium(
                        _errorMessage!,
                        color: BLKWDSColors.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
            ],

            // Save button
            BLKWDSEnhancedButton(
              label: isEditing ? 'Update Gear' : 'Add Gear',
              onPressed: _isLoading ? null : _saveGear,
              type: BLKWDSEnhancedButtonType.primary,
              isLoading: _isLoading,
              icon: isEditing ? Icons.save : Icons.add,
              backgroundColor: BLKWDSColors.mustardOrange,
              foregroundColor: BLKWDSColors.deepBlack,
              width: double.infinity,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Cancel button
            BLKWDSEnhancedButton(
              label: 'Cancel',
              onPressed: () => NavigationHelper.goBack(),
              type: BLKWDSEnhancedButtonType.secondary,
              foregroundColor: BLKWDSColors.mustardOrange,
              backgroundColor: BLKWDSColors.backgroundMedium,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
