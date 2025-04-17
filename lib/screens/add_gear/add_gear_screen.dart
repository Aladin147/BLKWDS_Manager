import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/image_service.dart';
import '../../services/contextual_error_handler.dart';
import '../../services/error_type.dart';
import '../../services/error_feedback_level.dart';
import '../../services/navigation_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_constants.dart';
import '../../utils/constants.dart';
import '../../widgets/blkwds_widgets.dart';
import 'add_gear_controller.dart';

/// AddGearScreen
/// Screen for adding new gear to the inventory
class AddGearScreen extends StatefulWidget {
  const AddGearScreen({super.key});

  @override
  State<AddGearScreen> createState() => _AddGearScreenState();
}

class _AddGearScreenState extends State<AddGearScreen> {
  // Controller for business logic
  final _controller = AddGearController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serialNumberController = TextEditingController();

  // Track if form has been submitted for validation
  bool _formSubmitted = false;

  @override
  void initState() {
    super.initState();

    // Set the context for error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setContext(context);
    });

    // Listen for changes in form values
    _controller.name.addListener(_updateNameField);
    _controller.description.addListener(_updateDescriptionField);
    _controller.serialNumber.addListener(_updateSerialNumberField);

    // Set initial values
    _nameController.text = _controller.name.value;
    _descriptionController.text = _controller.description.value;
    _serialNumberController.text = _controller.serialNumber.value;
  }

  // Update text fields when values change
  void _updateNameField() {
    _nameController.text = _controller.name.value;
  }

  void _updateDescriptionField() {
    _descriptionController.text = _controller.description.value;
  }

  void _updateSerialNumberField() {
    _serialNumberController.text = _controller.serialNumber.value;
  }

  @override
  void dispose() {
    // Clean up controllers
    _controller.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  // Pick an image for the gear
  Future<void> _pickImage() async {
    try {
      final File? imageFile = await ImageService.pickImage();

      if (imageFile != null && mounted) {
        setState(() {
          _controller.setThumbnailPath(imageFile.path);
        });
      }
    } catch (e, stackTrace) {
      // Log the error
      if (mounted) {
        // Use contextual error handler
        ContextualErrorHandler.handleError(
          context,
          e,
          type: ErrorType.fileSystem,
          stackTrace: stackTrace,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }
    }
  }

  // Save gear method is used by the Save button

  // Save gear
  Future<void> _saveGear() async {
    if (_formKey.currentState!.validate()) {
      final success = await _controller.saveGear();

      if (success) {
        // Return to previous screen after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            NavigationService.instance.goBack(result: true);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Gear'),
        backgroundColor: BLKWDSColors.blkwdsGreen,
        foregroundColor: BLKWDSColors.white,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ValueListenableBuilder<String?>(
            valueListenable: _controller.errorMessage,
            builder: (context, errorMessage, _) {
              return Padding(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingLarge),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message
                        if (errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                            margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
                            decoration: BoxDecoration(
                              color: BLKWDSColors.statusOut.withValues(alpha: 50),
                              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                            ),
                            child: Text(
                              errorMessage,
                              style: BLKWDSTypography.bodyMedium.copyWith(
                                color: BLKWDSColors.statusOut,
                              ),
                            ),
                          ),

                        // Name field
                        BLKWDSTextField(
                          label: 'Name',
                          isRequired: true,
                          hintText: 'Enter gear name',
                          controller: _nameController,
                          errorText: _controller.name.value.trim().isEmpty && _formSubmitted
                              ? 'Name is required'
                              : null,
                          onChanged: (value) {
                            _controller.name.value = value;
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Category dropdown
                        BLKWDSDropdown<String>(
                          label: 'Category',
                          isRequired: true,
                          value: _controller.category.value,
                          hintText: 'Select a category',
                          errorText: _controller.category.value.isEmpty && _formSubmitted
                              ? 'Category is required'
                              : null,
                          items: Constants.gearCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _controller.category.value = value;
                            }
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Description field
                        BLKWDSTextField(
                          label: 'Description',
                          hintText: 'Enter gear description',
                          controller: _descriptionController,
                          isMultiline: true,
                          onChanged: (value) {
                            _controller.description.value = value;
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Serial number field
                        BLKWDSTextField(
                          label: 'Serial Number',
                          hintText: 'Enter serial number',
                          controller: _serialNumberController,
                          onChanged: (value) {
                            _controller.serialNumber.value = value;
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Purchase date field
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: _controller.purchaseDate,
                          builder: (context, purchaseDate, _) {
                            return BLKWDSDatePicker(
                              label: 'Purchase Date',
                              selectedDate: purchaseDate,
                              hintText: 'Select purchase date',
                              onDateSelected: (date) {
                                _controller.setPurchaseDate(date);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Image upload
                        ValueListenableBuilder<String?>(
                          valueListenable: _controller.thumbnailPath,
                          builder: (context, thumbnailPath, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thumbnail Image',
                                  style: BLKWDSTypography.labelMedium,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingSmall),
                                InkWell(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: BLKWDSColors.slateGrey.withValues(alpha: 30),
                                      borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                                      border: Border.all(
                                        color: BLKWDSColors.slateGrey.withValues(alpha: 100),
                                      ),
                                    ),
                                    child: thumbnailPath != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                                            child: Image.file(
                                              File(thumbnailPath),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.add_photo_alternate,
                                                size: 48,
                                                color: BLKWDSColors.slateGrey,
                                              ),
                                              const SizedBox(height: BLKWDSConstants.spacingSmall),
                                              Text(
                                                'Click to add an image',
                                                style: BLKWDSTypography.bodyMedium.copyWith(
                                                  color: BLKWDSColors.slateGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingLarge),

                        // Save button
                        BLKWDSButton(
                          label: 'Save Gear',
                          onPressed: () {
                            setState(() {
                              _formSubmitted = true;
                            });
                            _saveGear();
                          },
                          type: BLKWDSButtonType.primary,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Cancel button
                        BLKWDSButton(
                          label: 'Cancel',
                          onPressed: () => NavigationService.instance.goBack(),
                          type: BLKWDSButtonType.secondary,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
