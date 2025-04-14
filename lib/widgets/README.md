# BLKWDS Manager UI Components

This directory contains standardized UI components for the BLKWDS Manager application. These components ensure a consistent look and feel across the entire application, reducing cognitive load during development and improving the user experience.

## Available Components

### Buttons (`blkwds_button.dart`)
- Standardized button with primary, secondary, and danger variants
- Supports icons, full-width mode, and disabled state
- Consistent styling with proper padding and border radius

### Text Fields (`blkwds_text_field.dart`)
- Standardized text input field with consistent styling
- Supports required field indicators, error messages, and multiline input
- Consistent label and hint text styling

### Dropdowns (`blkwds_dropdown.dart`)
- Standardized dropdown selector with consistent styling
- Supports required field indicators and error messages
- Consistent label and hint text styling

### Date Picker (`blkwds_date_picker.dart`)
- Standardized date picker with consistent styling
- Supports required field indicators and error messages
- Consistent label and hint text styling

### Time Picker (`blkwds_time_picker.dart`)
- Standardized time picker with consistent styling
- Supports required field indicators and error messages
- Consistent label and hint text styling

### Checkbox (`blkwds_checkbox.dart`)
- Standardized checkbox with consistent styling
- Supports disabled state
- Consistent label styling

### Card (`blkwds_card.dart`)
- Standardized card container with consistent styling
- Supports optional border color and tap action
- Consistent elevation and padding

## Usage

Import the barrel file to access all components:

```dart
import '../../widgets/blkwds_widgets.dart';
```

### Example: Button

```dart
BLKWDSButton(
  label: 'Save',
  onPressed: () {
    // Action here
  },
  type: BLKWDSButtonType.primary,
  isFullWidth: true,
)
```

### Example: Text Field

```dart
BLKWDSTextField(
  label: 'Name',
  isRequired: true,
  hintText: 'Enter your name',
  controller: _nameController,
  errorText: _nameError,
  onChanged: (value) {
    // Handle value change
  },
)
```

### Example: Dropdown

```dart
BLKWDSDropdown<String>(
  label: 'Category',
  isRequired: true,
  value: selectedCategory,
  items: categories.map((category) {
    return DropdownMenuItem<String>(
      value: category,
      child: Text(category),
    );
  }).toList(),
  onChanged: (value) {
    // Handle selection change
  },
)
```

## Design Guidelines

All components follow these design guidelines:

1. **Consistent Spacing**: Using spacing constants from `BLKWDSConstants`
2. **Consistent Colors**: Using color palette from `BLKWDSColors`
3. **Consistent Typography**: Using text styles from `BLKWDSTypography`
4. **Required Field Indicators**: Asterisk (*) for required fields
5. **Error Handling**: Consistent error message display
6. **Accessibility**: Proper contrast and touch target sizes

## Maintenance

When updating these components:

1. Maintain backward compatibility
2. Update this documentation
3. Ensure all variants are properly tested
4. Keep styling consistent with the design system
