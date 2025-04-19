import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/image_service.dart';
import '../../services/contextual_error_handler.dart';
import '../../services/error_type.dart';
import '../../services/error_feedback_level.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';

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

    // Set initial values
    _nameController.text = _controller.name.value;
    _descriptionController.text = _controller.description.value;
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
            NavigationHelper.goBack(result: true);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: 'Add New Gear',
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(
              child: BLKWDSEnhancedLoadingIndicator(),
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
                            child: BLKWDSEnhancedCard(
                              width: double.infinity,
                              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                              backgroundColor: BLKWDSColors.errorRed.withValues(alpha: 20.0),
                              borderColor: BLKWDSColors.errorRed.withValues(alpha: 100.0),
                              child: Row(
                                children: [
                                  BLKWDSEnhancedIconContainer(
                                    icon: Icons.error_outline,
                                    size: BLKWDSEnhancedIconContainerSize.small,
                                    backgroundColor: BLKWDSColors.errorRed.withValues(alpha: 20.0),
                                    iconColor: BLKWDSColors.errorRed,
                                  ),
                                  const SizedBox(width: BLKWDSConstants.spacingMedium),
                                  Expanded(
                                    child: BLKWDSEnhancedText.bodyMedium(
                                      errorMessage,
                                      color: BLKWDSColors.errorRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Name field
                        BLKWDSEnhancedFormField(
                          label: 'Name',
                          isRequired: true,
                          hintText: 'Enter gear name',
                          controller: _nameController,
                          validator: (value) => value == null || value.trim().isEmpty && _formSubmitted
                              ? 'Name is required'
                              : null,
                          onChanged: (value) {
                            _controller.name.value = value;
                          },
                          prefixIcon: Icons.inventory_2,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Category dropdown
                        BLKWDSEnhancedDropdown<String>(
                          label: 'Category',
                          isRequired: true,
                          value: _controller.category.value,
                          hintText: 'Select a category',
                          validator: (value) => value == null || value.isEmpty && _formSubmitted
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
                          prefixIcon: Icons.category,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Description field
                        BLKWDSEnhancedFormField(
                          label: 'Description',
                          hintText: 'Enter gear description',
                          controller: _descriptionController,
                          maxLines: 3,
                          onChanged: (value) {
                            _controller.description.value = value;
                          },
                          prefixIcon: Icons.description,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Serial number field
                        BLKWDSEnhancedFormField(
                          label: 'Serial Number',
                          hintText: 'Enter serial number',
                          controller: _serialNumberController,
                          onChanged: (value) {
                            _controller.serialNumber.value = value;
                          },
                          prefixIcon: Icons.qr_code,
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
                                BLKWDSEnhancedText.labelLarge(
                                  'Thumbnail Image',
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingSmall),
                                BLKWDSEnhancedCard(
                                  onTap: _pickImage,
                                  width: double.infinity,
                                  height: 200,
                                  animateOnHover: true,
                                  backgroundColor: BLKWDSColors.backgroundMedium,
                                  borderColor: BLKWDSColors.slateGrey.withValues(alpha: 100.0),
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
                                          BLKWDSEnhancedIconContainer(
                                            icon: Icons.add_photo_alternate,
                                            size: BLKWDSEnhancedIconContainerSize.large,
                                            backgroundColor: BLKWDSColors.backgroundLight,
                                            backgroundAlpha: BLKWDSColors.alphaLow,
                                            iconColor: BLKWDSColors.slateGrey,
                                          ),
                                          const SizedBox(height: BLKWDSConstants.spacingMedium),
                                          BLKWDSEnhancedText.bodyMedium(
                                            'Click to add an image',
                                            color: BLKWDSColors.textSecondary,
                                          ),
                                        ],
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingLarge),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: BLKWDSEnhancedButton(
                            label: 'Save Gear',
                            onPressed: () {
                              setState(() {
                                _formSubmitted = true;
                              });
                              _saveGear();
                            },
                            type: BLKWDSEnhancedButtonType.primary,
                            icon: Icons.save,
                          ),
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Cancel button
                        SizedBox(
                          width: double.infinity,
                          child: BLKWDSEnhancedButton(
                            label: 'Cancel',
                            onPressed: () => NavigationHelper.goBack(),
                            type: BLKWDSEnhancedButtonType.secondary,
                            icon: Icons.cancel,
                          ),
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
