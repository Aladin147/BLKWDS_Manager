# BLKWDS Manager UI Implementation Guide

This guide provides instructions for implementing the standardized UI components in the BLKWDS Manager application.

## Getting Started

1. Import the widgets barrel file:
   ```dart
   import '../../widgets/blkwds_widgets.dart';
   ```

2. Use the standardized components instead of Flutter's built-in components.

## Component Migration Guide

### Buttons

**Before:**
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: BLKWDSColors.mustardOrange,
    padding: const EdgeInsets.symmetric(
      vertical: BLKWDSConstants.buttonVerticalPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        BLKWDSConstants.buttonBorderRadius,
      ),
    ),
  ),
  child: Text('Button Text'),
)
```

**After:**
```dart
BLKWDSButton(
  label: 'Button Text',
  onPressed: () {},
  type: BLKWDSButtonType.primary,
  isFullWidth: true,
)
```

### Text Fields

**Before:**
```dart
TextFormField(
  controller: _controller,
  decoration: const InputDecoration(
    labelText: 'Field Name *',
    hintText: 'Enter field value',
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field is required';
    }
    return null;
  },
  onChanged: (value) {
    // Handle value change
  },
)
```

**After:**
```dart
BLKWDSTextField(
  label: 'Field Name',
  isRequired: true,
  hintText: 'Enter field value',
  controller: _controller,
  errorText: _value.trim().isEmpty && _formSubmitted
      ? 'Field is required'
      : null,
  onChanged: (value) {
    // Handle value change
  },
)
```

### Dropdowns

**Before:**
```dart
DropdownButtonFormField<String>(
  value: selectedValue,
  decoration: const InputDecoration(
    labelText: 'Category *',
  ),
  items: items.map((item) {
    return DropdownMenuItem<String>(
      value: item,
      child: Text(item),
    );
  }).toList(),
  onChanged: (value) {
    // Handle selection change
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    return null;
  },
)
```

**After:**
```dart
BLKWDSDropdown<String>(
  label: 'Category',
  isRequired: true,
  value: selectedValue,
  hintText: 'Select a category',
  errorText: selectedValue.isEmpty && _formSubmitted
      ? 'Category is required'
      : null,
  items: items.map((item) {
    return DropdownMenuItem<String>(
      value: item,
      child: Text(item),
    );
  }).toList(),
  onChanged: (value) {
    // Handle selection change
  },
)
```

### Date Pickers

**Before:**
```dart
InkWell(
  onTap: _pickDate,
  child: InputDecorator(
    decoration: const InputDecoration(
      labelText: 'Date',
      suffixIcon: Icon(Icons.calendar_today),
    ),
    child: Text(
      selectedDate != null
          ? DateFormat.yMMMd().format(selectedDate)
          : 'Select date',
    ),
  ),
)
```

**After:**
```dart
BLKWDSDatePicker(
  label: 'Date',
  selectedDate: selectedDate,
  hintText: 'Select date',
  onDateSelected: (date) {
    // Handle date selection
  },
)
```

## Form Validation Strategy

For form validation, we recommend:

1. Add a `_formSubmitted` boolean to your state:
   ```dart
   bool _formSubmitted = false;
   ```

2. Set it to true when the form is submitted:
   ```dart
   void _submitForm() {
     setState(() {
       _formSubmitted = true;
     });
     
     // Continue with form submission
   }
   ```

3. Use it in your error text conditions:
   ```dart
   errorText: _value.isEmpty && _formSubmitted ? 'Field is required' : null,
   ```

This approach shows errors only after the user attempts to submit the form, providing a better user experience.

## Theming Guidelines

1. Use colors from `BLKWDSColors` for all UI elements
2. Use spacing constants from `BLKWDSConstants` for all margins and padding
3. Use text styles from `BLKWDSTypography` for all text elements

## Testing Your UI

After implementing standardized components, test your UI on:

1. Different screen sizes
2. Light and dark mode (if supported)
3. With different text scaling factors

Report any inconsistencies in the UI audit document.
