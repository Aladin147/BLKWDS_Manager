import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/image_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_constants.dart';
import '../../utils/constants.dart';
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

  @override
  void initState() {
    super.initState();

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
    } catch (e) {
      // Use a logger in production code instead of print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: BLKWDSColors.statusOut,
          ),
        );
      }
    }
  }

  // Pick a date for purchase date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.purchaseDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _controller.setPurchaseDate(picked);
    }
  }

  // Save gear
  Future<void> _saveGear() async {
    if (_formKey.currentState!.validate()) {
      final success = await _controller.saveGear();

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gear added successfully'),
              backgroundColor: BLKWDSColors.statusIn,
            ),
          );

          // Return to previous screen after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        }
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
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            hintText: 'Enter gear name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _controller.name.value = value;
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Category dropdown
                        DropdownButtonFormField<String>(
                          value: _controller.category.value,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                          ),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Category is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter gear description',
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            _controller.description.value = value;
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Serial number field
                        TextFormField(
                          controller: _serialNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Serial Number',
                            hintText: 'Enter serial number',
                          ),
                          onChanged: (value) {
                            _controller.serialNumber.value = value;
                          },
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Purchase date field
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: _controller.purchaseDate,
                          builder: (context, purchaseDate, _) {
                            return InkWell(
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Purchase Date',
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  purchaseDate != null
                                      ? DateFormat.yMMMd().format(purchaseDate)
                                      : 'Select purchase date',
                                  style: purchaseDate != null
                                      ? BLKWDSTypography.bodyMedium
                                      : BLKWDSTypography.bodyMedium.copyWith(
                                          color: BLKWDSColors.slateGrey,
                                        ),
                                ),
                              ),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveGear,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BLKWDSColors.blkwdsGreen,
                              foregroundColor: BLKWDSColors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: BLKWDSConstants.spacingMedium,
                              ),
                            ),
                            child: Text(
                              'Save Gear',
                              style: BLKWDSTypography.titleMedium.copyWith(
                                color: BLKWDSColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),

                        // Cancel button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: BLKWDSTypography.bodyLarge.copyWith(
                                color: BLKWDSColors.slateGrey,
                              ),
                            ),
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
